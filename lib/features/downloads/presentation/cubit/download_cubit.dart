import 'dart:async';
import 'dart:collection';
import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:dio/dio.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/error_handler.dart';
import '../../../../core/error/failures.dart';
import '../../../../core/event_bus/account_deactivated_event.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/services/device_service.dart';
import '../../../../core/utils/local_storage_keys.dart';
import '../../../../core/utils/shared_preferences_helper.dart';
import '../../../../generated/l10n.dart';
import '../../data/local/download_records_store.dart';
import '../../data/models/download_record.dart';
import '../../data/services/download_engine.dart';
import '../../data/services/encrypted_download_service.dart';
import '../../data/services/storage_guard.dart';
import '../../domain/entities/download_item.dart';
import '../../domain/repositories/downloads_repository.dart';
import 'download_state.dart';

/// Owns all lesson downloads for the whole app. Registered as a singleton and
/// provided above the navigator, so a download keeps running when the student
/// leaves the lessons screen and moves elsewhere in the app.
///
/// **Persistent.** Every requested download is a [DownloadRecord] from the
/// moment it is asked for until it finishes or is cancelled. After an app
/// kill, [restore] rebuilds the queue from those records: interrupted
/// downloads resume from the bytes already on disk, paused ones stay paused,
/// and nothing is lost. (Before, the queue lived only in memory and the
/// partial file was deleted on the next launch.)
///
/// **Queued.** At most [_maxConcurrent] transfer at a time; the rest wait in
/// [DownloadItemStatus.queued] — a dozen parallel streams on one weak
/// connection starve each other and mostly time out.
///
/// **Network-aware.** A transfer that fails because the device is offline
/// becomes [DownloadItemStatus.waitingForNetwork] instead of failed, and
/// resumes by itself when connectivity returns. Cellular and Wi-Fi are both
/// allowed; nothing here restricts the network type.
///
/// **Smooth.** Engine progress arrives once per network chunk — hundreds of
/// times a second on Wi-Fi. It is throttled to one state emission per
/// [progressInterval], which is all a progress ring needs.
@lazySingleton
class DownloadCubit extends Cubit<DownloadState> {
  final DownloadEngine _engine;
  final EncryptedDownloadService _service;
  final DownloadRecordsStore _records;
  final DownloadsRepository _downloadsRepository;
  final DeviceService _deviceService;
  final ConnectivityService _connectivity;

  DownloadCubit(
    this._engine,
    this._service,
    this._records,
    this._downloadsRepository,
    this._deviceService,
    this._connectivity,
    EventBus eventBus,
  ) : super(DownloadState.initial()) {
    // Policy: a deactivated account keeps nothing on the device.
    _deactivationSub = eventBus.on<AccountDeactivatedEvent>().listen((_) => purgeAll());
  }

  /// Two at a time keeps a decent connection busy without splitting a weak one
  /// so thin that neither transfer survives.
  static const int _maxConcurrent = 2;

  /// Minimum gap between progress emissions for one lesson (~4 per second).
  static const Duration progressInterval = Duration(milliseconds: 250);

  /// The record's byte count is persisted this often while downloading — the
  /// partial file on disk is the real resume point, this only lets the UI show
  /// sensible progress right after a restart. Rare, because Hive writes cost.
  static const Duration _checkpointInterval = Duration(seconds: 5);

  /// Time source, swappable in tests so throttling and speed are deterministic.
  @visibleForTesting
  static DateTime Function() clock = DateTime.now;

  /// Lessons waiting for a free slot, in the order the student asked for them.
  final Queue<String> _queue = Queue<String>();

  /// Lessons whose `_run` future is currently in flight.
  final Set<String> _running = {};

  final Map<String, _ProgressTracker> _trackers = {};

  StreamSubscription<AccountDeactivatedEvent>? _deactivationSub;

  /// Live only while some download is waiting for the network — the
  /// connectivity stream polls reachability every few seconds, which is not
  /// worth paying for when nothing is waiting.
  StreamSubscription<bool>? _onlineSub;

  bool _restored = false;

  bool isDownloaded(String lessonId) => _service.isDownloaded(lessonId);

  /// Number of downloads waiting for a slot — drives the "N in queue" hint.
  int get queuedCount => _queue.length;

  // --- Startup ----------------------------------------------------------------

  /// Rebuilds in-session state from the persistent records, once, at startup.
  /// Must run after `EncryptedDownloadService.reconcileOnStartup`.
  Future<void> restore() async {
    if (_restored) return;
    _restored = true;

    for (final String lessonId in _service.expiredOnLastReconcile) {
      _put(lessonId, DownloadItemStatus.expired, error: LicenseExpiredFailure(S.current.downloadExpired).statusMessage);
    }

    final List<DownloadRecord> records = await _records.recoverAfterRestart();
    for (final DownloadRecord record in records) {
      // Finished just before the app was killed: the lesson is complete, only
      // the record removal didn't happen.
      if (_service.isDownloaded(record.lessonId)) {
        await _records.remove(record.lessonId);
        continue;
      }
      final double progress = record.totalBytes > 0
          ? (record.bytesReceived / record.totalBytes * 0.85).clamp(0.0, 0.85)
          : 0;
      switch (record.status) {
        case DownloadRecordStatus.queued:
        case DownloadRecordStatus.downloading: // already rewritten to queued
          _putFromRecord(record, DownloadItemStatus.queued, progress: progress);
          _enqueue(record.lessonId);
        case DownloadRecordStatus.paused:
          _putFromRecord(record, DownloadItemStatus.paused, progress: progress);
        case DownloadRecordStatus.waitingForNetwork:
          _putFromRecord(record, DownloadItemStatus.waitingForNetwork, progress: progress, error: record.error);
        case DownloadRecordStatus.failed:
          _putFromRecord(record, DownloadItemStatus.failed, progress: progress, error: record.error);
      }
    }
    _syncOnlineWatch();
  }

  // --- Commands ---------------------------------------------------------------

  /// Starts (or restarts) downloading a lesson. Persisted immediately, then
  /// runs when a slot is free.
  Future<void> startDownload({
    required String lessonId,
    required String videoUrl,
    String title = '',
    int durationSeconds = 0,
    String? thumbnailUrl,
  }) async {
    final DownloadRecord? existing = _records.get(lessonId);
    if (existing == null) {
      await _records.put(
        DownloadRecord.queued(
          lessonId: lessonId,
          videoUrl: videoUrl,
          title: title,
          durationSeconds: durationSeconds,
          thumbnailUrl: thumbnailUrl,
          now: clock(),
        ),
      );
    } else {
      // Retrying a failed/paused/waiting one keeps its record (and partial).
      await _records.transition(lessonId, DownloadRecordStatus.queued);
    }
    _enqueue(lessonId);
  }

  /// Pauses an in-progress download (keeps the partial file). A queued or
  /// network-waiting download is simply taken out of line.
  Future<void> pauseDownload(String lessonId) async {
    if (_engine.isActive(lessonId)) {
      _engine.pause(lessonId); // _run records the outcome
      return;
    }
    final bool wasQueued = _queue.remove(lessonId);
    final DownloadItemStatus? status = state.of(lessonId)?.status;
    if (wasQueued || status == DownloadItemStatus.waitingForNetwork) {
      await _records.transition(lessonId, DownloadRecordStatus.paused);
      _put(lessonId, DownloadItemStatus.paused);
      _syncOnlineWatch();
      _pump();
    }
  }

  /// Resumes a paused (or failed) download from where it stopped.
  Future<void> resumeDownload(String lessonId) async {
    if (_records.get(lessonId) == null) return;
    await _records.transition(lessonId, DownloadRecordStatus.queued);
    _enqueue(lessonId);
  }

  /// Cancels a download (running, queued, waiting or paused) and drops the
  /// partial file.
  Future<void> cancelDownload(String lessonId) async {
    _queue.remove(lessonId);
    if (_engine.isActive(lessonId)) {
      // The running loop deletes the files; _run removes the record.
      _engine.cancel(lessonId);
    } else {
      await _service.deleteLesson(lessonId);
      await _records.remove(lessonId);
      _trackers.remove(lessonId);
      _remove(lessonId);
      _syncOnlineWatch();
      _pump();
    }
  }

  /// Deletes a completed download.
  Future<void> deleteDownload(String lessonId) async {
    try {
      await _service.deleteLesson(lessonId);
      await _records.remove(lessonId);
      _put(lessonId, DownloadItemStatus.deleted, progress: 0);
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

  /// Removes every download — finished, partial, queued — and every record.
  /// Runs automatically on [AccountDeactivatedEvent].
  Future<void> purgeAll() async {
    _queue.clear();
    for (final String lessonId in _running.toList()) {
      _engine.cancel(lessonId);
    }
    await _records.clear();
    await _service.purgeEverything();
    _trackers.clear();
    _onlineSub?.cancel();
    _onlineSub = null;
    if (!isClosed) emit(DownloadState.initial());
  }

  /// Repairs anything an app kill left half-finished. Safe to call more than
  /// once; pending downloads (with a record) keep their partial files.
  Future<void> reconcile() async {
    await _service.reconcileOnStartup(isTracked: _records.contains);
  }

  // --- Queue ------------------------------------------------------------------

  void _enqueue(String lessonId) {
    if (_running.contains(lessonId) || _queue.contains(lessonId)) return;
    _queue.add(lessonId);
    // Show the wait explicitly rather than leaving a dead-looking button: a
    // queued download that reported nothing is why "nothing happens" bugs get
    // reported.
    final DownloadRecord? record = _records.get(lessonId);
    _put(lessonId, DownloadItemStatus.queued, progress: state.of(lessonId)?.progress ?? 0, title: record?.title);
    _syncOnlineWatch();
    _pump();
  }

  /// Starts as many queued downloads as there are free slots.
  void _pump() {
    while (_running.length < _maxConcurrent && _queue.isNotEmpty) {
      final String lessonId = _queue.removeFirst();
      if (_records.get(lessonId) == null) continue; // cancelled while waiting
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
    final DownloadRecord? record = await _records.transition(lessonId, DownloadRecordStatus.downloading);
    if (record == null) return;

    _put(lessonId, DownloadItemStatus.downloading, progress: state.of(lessonId)?.progress ?? 0, title: record.title);
    _trackers[lessonId] = _ProgressTracker(clock(), record.bytesReceived);

    try {
      final String studentId = await SharedPreferencesHelper.getSecuredString(LocalStorageKeys.userId);
      final String deviceUuid = await _deviceService.getDeviceUuid();

      final DownloadOutcome outcome = await _engine.start(
        DownloadRequest(
          lessonId: lessonId,
          videoUrl: record.videoUrl,
          studentId: studentId,
          deviceUuid: deviceUuid,
          // Read fresh on every attempt, never captured once: a download can
          // run (or sit paused) far longer than an access token's 15 minutes.
          accessToken: () => SharedPreferencesHelper.getSecuredString(LocalStorageKeys.accessToken),
          title: record.title,
          durationSeconds: record.durationSeconds,
          thumbnailUrl: record.thumbnailUrl,
        ),
        onProgress: (p) => _onProgress(lessonId, p),
      );

      final _ProgressTracker? tracker = _trackers.remove(lessonId);
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
          await _records.remove(lessonId);
          _put(lessonId, DownloadItemStatus.completed, progress: 1);
        case DownloadOutcome.paused:
          await _records.transition(
            lessonId,
            DownloadRecordStatus.paused,
            bytesReceived: tracker?.bytes,
            totalBytes: tracker?.total,
          );
          _put(lessonId, DownloadItemStatus.paused, speedBytesPerSecond: 0);
        case DownloadOutcome.canceled:
          await _records.remove(lessonId);
          _remove(lessonId);
      }
    } catch (error) {
      final _ProgressTracker? tracker = _trackers.remove(lessonId);
      // The engine already retried transient failures in place. A network
      // failure with no internet at all is a wait, not a failure: park it and
      // resume automatically when the connection returns.
      if (_isNetworkError(error) && !await _connectivity.hasInternet()) {
        final Failure waiting = NetworkUnavailableFailure(S.current.waitingForNetwork);
        await _records.transition(
          lessonId,
          DownloadRecordStatus.waitingForNetwork,
          bytesReceived: tracker?.bytes,
          totalBytes: tracker?.total,
          error: waiting.statusMessage,
        );
        _put(lessonId, DownloadItemStatus.waitingForNetwork, error: waiting.statusMessage, speedBytesPerSecond: 0);
        _syncOnlineWatch();
        return;
      }
      final String message = failureFor(error).statusMessage;
      await _records.transition(
        lessonId,
        DownloadRecordStatus.failed,
        bytesReceived: tracker?.bytes,
        totalBytes: tracker?.total,
        error: message,
      );
      // Keep the last known progress so the student sees where it stopped.
      _put(lessonId, DownloadItemStatus.failed, error: message, speedBytesPerSecond: 0);
    }
  }

  // --- Progress ---------------------------------------------------------------

  void _onProgress(String lessonId, TransferProgress p) {
    final _ProgressTracker? tracker = _trackers[lessonId];
    if (tracker == null) return;
    final DateTime now = clock();
    tracker.observe(now, p.bytesReceived, p.totalBytes);

    final bool finished = p.fraction >= 1.0;
    if (!finished && now.difference(tracker.lastEmit) < progressInterval) return;
    tracker.lastEmit = now;

    // Ignore late ticks after a pause/cancel took effect.
    if (state.of(lessonId)?.status != DownloadItemStatus.downloading) return;
    _put(
      lessonId,
      DownloadItemStatus.downloading,
      progress: p.fraction.clamp(0.0, 1.0),
      bytesReceived: p.bytesReceived,
      totalBytes: p.totalBytes,
      speedBytesPerSecond: tracker.speed,
    );

    if (now.difference(tracker.lastCheckpoint) >= _checkpointInterval) {
      tracker.lastCheckpoint = now;
      unawaited(
        _records.transition(
          lessonId,
          DownloadRecordStatus.downloading,
          bytesReceived: p.bytesReceived,
          totalBytes: p.totalBytes,
        ),
      );
    }
  }

  // --- Network waiting --------------------------------------------------------

  /// Keeps a connectivity subscription alive exactly while something waits.
  void _syncOnlineWatch() {
    final bool anyWaiting = state.items.values.any((i) => i.status == DownloadItemStatus.waitingForNetwork);
    if (anyWaiting && _onlineSub == null) {
      _onlineSub = _connectivity.isOnline.listen((online) {
        if (online) unawaited(_resumeWaiting());
      });
    } else if (!anyWaiting && _onlineSub != null) {
      _onlineSub!.cancel();
      _onlineSub = null;
    }
  }

  Future<void> _resumeWaiting() async {
    final List<String> waiting = state.items.values
        .where((i) => i.status == DownloadItemStatus.waitingForNetwork)
        .map((i) => i.lessonId)
        .toList();
    for (final String lessonId in waiting) {
      await _records.transition(lessonId, DownloadRecordStatus.queued);
      _enqueue(lessonId);
    }
  }

  // --- Errors -----------------------------------------------------------------

  /// Connection-level failures (as opposed to the server answering "no").
  static bool _isNetworkError(Object error) {
    if (error is SocketException || error is HttpException || error is TlsException || error is TimeoutException) {
      return true;
    }
    if (error is IncompleteDownloadException) return true;
    if (error is DioException) {
      if (error.response != null) return false; // the server answered
      return error.type != DioExceptionType.cancel && error.type != DioExceptionType.badCertificate;
    }
    return false;
  }

  /// Maps a download error to its typed [Failure]. Download-specific errors
  /// are mapped here rather than in `ErrorHandler`, because `core/` must not
  /// import a feature's service types.
  @visibleForTesting
  static Failure failureFor(Object error) {
    if (error is InsufficientStorageException) return InsufficientStorageFailure(S.current.insufficientStorage);
    if (error is IncompleteDownloadException) return NetworkFailure(S.current.downloadIncomplete, null);
    // Not the student's fault and not retryable right now — say so, instead of
    // "couldn't download the video", which invites pointless retries.
    if (error is VideoProcessingException) return const VideoProcessingFailure();
    return ErrorHandler.handleFailureError(error);
  }

  // --- State helpers ----------------------------------------------------------

  void _putFromRecord(DownloadRecord record, DownloadItemStatus status, {required double progress, String? error}) {
    _put(
      record.lessonId,
      status,
      progress: progress,
      error: error,
      title: record.title,
      bytesReceived: record.bytesReceived,
      totalBytes: record.totalBytes,
    );
  }

  void _put(
    String lessonId,
    DownloadItemStatus status, {
    double? progress,
    String? error,
    String? title,
    int? bytesReceived,
    int? totalBytes,
    double? speedBytesPerSecond,
  }) {
    if (isClosed) return;
    final DownloadItem? existing = state.of(lessonId);
    final DownloadItem next = DownloadItem(
      lessonId: lessonId,
      status: status,
      progress: progress ?? existing?.progress ?? 0,
      error: error,
      title: title ?? existing?.title ?? '',
      bytesReceived: bytesReceived ?? existing?.bytesReceived ?? 0,
      totalBytes: totalBytes ?? existing?.totalBytes ?? 0,
      speedBytesPerSecond: speedBytesPerSecond ?? existing?.speedBytesPerSecond ?? 0,
    );
    emit(state.rebuild((b) => b..items = {...state.items, lessonId: next}));
  }

  void _remove(String lessonId) {
    if (isClosed || !state.items.containsKey(lessonId)) return;
    final Map<String, DownloadItem> next = {...state.items}..remove(lessonId);
    emit(state.rebuild((b) => b..items = next));
  }

  @override
  Future<void> close() async {
    await _deactivationSub?.cancel();
    await _onlineSub?.cancel();
    return super.close();
  }
}

/// Per-download throttling and speed bookkeeping.
class _ProgressTracker {
  /// Minimum spacing between speed samples — shorter windows are pure noise.
  static const Duration _sampleWindow = Duration(milliseconds: 500);

  /// Exponential smoothing factor: higher reacts faster, lower is steadier.
  static const double _alpha = 0.3;

  DateTime lastEmit = DateTime.fromMillisecondsSinceEpoch(0);
  DateTime lastCheckpoint;
  DateTime _sampleAt;
  int _sampleBytes;

  int bytes;
  int total = 0;
  double speed = 0;

  _ProgressTracker(DateTime now, this.bytes) : lastCheckpoint = now, _sampleAt = now, _sampleBytes = bytes;

  void observe(DateTime now, int receivedBytes, int totalBytes) {
    bytes = receivedBytes;
    if (totalBytes > 0) total = totalBytes;
    final int elapsedMs = now.difference(_sampleAt).inMilliseconds;
    if (elapsedMs < _sampleWindow.inMilliseconds) return;
    final double instant = (receivedBytes - _sampleBytes) * 1000 / elapsedMs;
    // A resume can restart the byte count lower than the last sample; that
    // isn't negative speed, just a new baseline.
    if (instant >= 0) speed = speed == 0 ? instant : (_alpha * instant + (1 - _alpha) * speed);
    _sampleAt = now;
    _sampleBytes = receivedBytes;
  }
}
