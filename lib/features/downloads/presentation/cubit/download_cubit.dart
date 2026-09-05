import 'dart:async';
import 'dart:collection';

import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/error_handler.dart';
import '../../../../core/services/device_service.dart';
import '../../../../core/utils/local_storage_keys.dart';
import '../../../../core/utils/shared_preferences_helper.dart';
import '../../data/services/encrypted_download_service.dart';
import '../../domain/entities/download_item.dart';
import '../../domain/repositories/downloads_repository.dart';
import 'download_state.dart';

/// Arguments needed to (re)start a lesson download, remembered so a paused or
/// queued download can be resumed without the caller passing them again.
class _DownloadArgs {
  final String videoUrl;
  final String title;
  final int durationSeconds;
  final String? thumbnailUrl;
  const _DownloadArgs(this.videoUrl, this.title, this.durationSeconds, this.thumbnailUrl);
}

/// Owns all lesson downloads for the whole app. Registered as a singleton and
/// provided above the navigator, so a download keeps running when the student
/// leaves the lessons screen and moves elsewhere in the app.
///
/// Downloads are **queued**, not run all at once: a student who taps download
/// on ten lessons would otherwise open ten streams that starve each other on
/// a weak connection and mostly time out. At most [_maxConcurrent] transfer at
/// a time; the rest wait in [DownloadItemStatus.queued] and start as slots
/// free up.
@lazySingleton
class DownloadCubit extends Cubit<DownloadState> {
  final EncryptedDownloadService _service;
  final DownloadsRepository _downloadsRepository;
  final DeviceService _deviceService;

  /// Two at a time keeps a decent connection busy without splitting a weak one
  /// so thin that neither transfer survives.
  static const int _maxConcurrent = 2;

  final Map<String, _DownloadArgs> _args = {};

  /// Lessons waiting for a free slot, in the order the student asked for them.
  final Queue<String> _queue = Queue<String>();

  /// Lessons whose `_run` future is currently in flight.
  final Set<String> _running = {};

  DownloadCubit(this._service, this._downloadsRepository, this._deviceService) : super(DownloadState.initial());

  bool isDownloaded(String lessonId) => _service.isDownloaded(lessonId);

  /// Number of downloads waiting for a slot — drives the "N in queue" hint.
  int get queuedCount => _queue.length;

  /// Starts (or restarts) downloading a lesson video. Runs immediately if a
  /// slot is free, otherwise joins the queue.
  Future<void> startDownload({
    required String lessonId,
    required String videoUrl,
    String title = '',
    int durationSeconds = 0,
    String? thumbnailUrl,
  }) async {
    _args[lessonId] = _DownloadArgs(videoUrl, title, durationSeconds, thumbnailUrl);
    _enqueue(lessonId);
  }

  /// Pauses an in-progress download (keeps the partial file). A download still
  /// waiting in the queue is simply pulled out of it.
  void pauseDownload(String lessonId) {
    if (_service.isActive(lessonId)) {
      _service.pause(lessonId);
      return;
    }
    if (_queue.remove(lessonId)) {
      _put(lessonId, DownloadItemStatus.paused);
      _pump();
    }
  }

  /// Resumes a paused download from where it stopped (re-queues it).
  Future<void> resumeDownload(String lessonId) async {
    if (!_args.containsKey(lessonId)) return;
    _enqueue(lessonId);
  }

  /// Cancels a download (running, queued or paused) and drops the partial file.
  Future<void> cancelDownload(String lessonId) async {
    _queue.remove(lessonId);
    if (_service.isActive(lessonId)) {
      // The running loop will clean up and resolve to `canceled`.
      _service.cancel(lessonId);
    } else {
      // Queued / paused / not running: remove leftovers directly.
      await _service.deleteLesson(lessonId);
      _remove(lessonId);
      _pump();
    }
    _args.remove(lessonId);
  }

  /// Deletes a completed download.
  Future<void> deleteDownload(String lessonId) async {
    try {
      await _service.deleteLesson(lessonId);
      _put(lessonId, DownloadItemStatus.deleted, progress: 0);
      _args.remove(lessonId);
    } catch (error) {
      _put(lessonId, DownloadItemStatus.failed, error: ErrorHandler.handleFailureError(error).statusMessage);
    }
  }

  /// Deletes every completed download at once. Returns how many were removed.
  Future<int> deleteAllDownloads() async {
    final int removed = await _service.deleteAll();
    // Drop the completed entries from in-session state too, so any visible
    // list stops showing them as available.
    final Map<String, DownloadItem> next = {...state.items}
      ..removeWhere((_, item) => item.status == DownloadItemStatus.completed);
    emit(state.rebuild((b) => b..items = next));
    return removed;
  }

  /// Repairs anything an app kill left half-finished, then clears the matching
  /// in-session entries. Safe to call more than once.
  Future<void> reconcile() async {
    await _service.reconcileOnStartup();
  }

  // --- Queue ----------------------------------------------------------------

  void _enqueue(String lessonId) {
    if (_running.contains(lessonId) || _queue.contains(lessonId)) return;
    _queue.add(lessonId);
    // Show the wait explicitly rather than leaving a dead-looking button: a
    // queued download that reported nothing is why "nothing happens" bugs get
    // reported.
    _put(lessonId, DownloadItemStatus.queued, progress: state.of(lessonId)?.progress ?? 0);
    _pump();
  }

  /// Starts as many queued downloads as there are free slots.
  void _pump() {
    while (_running.length < _maxConcurrent && _queue.isNotEmpty) {
      final String lessonId = _queue.removeFirst();
      if (!_args.containsKey(lessonId)) continue; // cancelled while waiting
      _running.add(lessonId);
      unawaited(
        _run(lessonId).whenComplete(() {
          _running.remove(lessonId);
          _pump(); // a slot just freed up
        }),
      );
    }
  }

  Future<void> _run(String lessonId) async {
    final _DownloadArgs? args = _args[lessonId];
    if (args == null) return;

    _put(lessonId, DownloadItemStatus.downloading, progress: state.of(lessonId)?.progress ?? 0);

    try {
      final String studentId = await SharedPreferencesHelper.getSecuredString(LocalStorageKeys.userId);
      final String deviceUuid = await _deviceService.getDeviceUuid();

      final DownloadOutcome outcome = await _service.downloadLesson(
        lessonId: lessonId,
        videoUrl: args.videoUrl,
        studentId: studentId,
        deviceUuid: deviceUuid,
        // Read fresh on every attempt, never captured once: a download can run
        // (or sit paused) far longer than an access token's 15-minute life, so
        // a token snapshotted here would be stale by the time it's used.
        accessToken: () => SharedPreferencesHelper.getSecuredString(LocalStorageKeys.accessToken),
        title: args.title,
        durationSeconds: args.durationSeconds,
        thumbnailUrl: args.thumbnailUrl,
        onProgress: (p) {
          // Ignore late progress ticks after a pause/cancel took effect.
          if (state.of(lessonId)?.status == DownloadItemStatus.downloading) {
            _put(lessonId, DownloadItemStatus.downloading, progress: p.clamp(0.0, 1.0));
          }
        },
      );

      switch (outcome) {
        case DownloadOutcome.completed:
          // Best-effort backend registration (don't fail if offline).
          try {
            await _downloadsRepository.registerDownload(
              lessonId: lessonId,
              deviceUuid: deviceUuid,
              chunkCount: _service.chunkCount(lessonId) ?? 0,
            );
          } catch (_) {}
          _put(lessonId, DownloadItemStatus.completed, progress: 1);
          _args.remove(lessonId);
        case DownloadOutcome.paused:
          _put(lessonId, DownloadItemStatus.paused);
        case DownloadOutcome.canceled:
          _remove(lessonId);
          _args.remove(lessonId);
      }
    } catch (error) {
      // The service already retried transient failures and cleaned up any
      // unusable partial, so reaching here means a real, reportable failure.
      // Keep the last known progress so the student sees where it stopped.
      _put(lessonId, DownloadItemStatus.failed, error: _messageFor(error));
    }
  }

  /// Turns a download failure into something a student can act on. An
  /// incomplete transfer is by far the most common one and deserves better
  /// than a generic network error.
  String _messageFor(Object error) {
    if (error is IncompleteDownloadException) return 'انقطع التحميل قبل اكتماله — أعد المحاولة';
    // Not the student's fault and not retryable right now — say so, instead of
    // "couldn't download the video", which invites pointless retries.
    if (error is VideoProcessingException) return 'الفيديو قيد المعالجة، حاول لاحقاً';
    return ErrorHandler.handleFailureError(error).statusMessage;
  }

  // --- State helpers --------------------------------------------------------

  void _put(String lessonId, DownloadItemStatus status, {double? progress, String? error}) {
    final DownloadItem? existing = state.of(lessonId);
    final DownloadItem next = DownloadItem(lessonId: lessonId, status: status, progress: progress ?? existing?.progress ?? 0, error: error);
    emit(state.rebuild((b) => b..items = {...state.items, lessonId: next}));
  }

  void _remove(String lessonId) {
    if (!state.items.containsKey(lessonId)) return;
    final Map<String, DownloadItem> next = {...state.items}..remove(lessonId);
    emit(state.rebuild((b) => b..items = next));
  }
}
