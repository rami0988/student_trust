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

/// Arguments needed to (re)start a lesson download, remembered so a paused
/// download can be resumed without the caller passing them again.
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
@lazySingleton
class DownloadCubit extends Cubit<DownloadState> {
  final EncryptedDownloadService _service;
  final DownloadsRepository _downloadsRepository;
  final DeviceService _deviceService;

  final Map<String, _DownloadArgs> _args = {};

  DownloadCubit(this._service, this._downloadsRepository, this._deviceService) : super(DownloadState.initial());

  bool isDownloaded(String lessonId) => _service.isDownloaded(lessonId);

  /// Starts (or restarts) downloading a lesson video.
  Future<void> startDownload({
    required String lessonId,
    required String videoUrl,
    String title = '',
    int durationSeconds = 0,
    String? thumbnailUrl,
  }) async {
    _args[lessonId] = _DownloadArgs(videoUrl, title, durationSeconds, thumbnailUrl);
    await _run(lessonId);
  }

  /// Pauses an in-progress download (keeps the partial file).
  void pauseDownload(String lessonId) => _service.pause(lessonId);

  /// Resumes a paused download from where it stopped.
  Future<void> resumeDownload(String lessonId) async {
    if (!_args.containsKey(lessonId)) return;
    await _run(lessonId);
  }

  /// Cancels a download (running or paused) and drops the partial file.
  Future<void> cancelDownload(String lessonId) async {
    if (_service.isActive(lessonId)) {
      // The running loop will clean up and resolve to `canceled`.
      _service.cancel(lessonId);
    } else {
      // Paused / not running: remove leftovers directly.
      await _service.deleteLesson(lessonId);
      _remove(lessonId);
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

  Future<void> _run(String lessonId) async {
    final _DownloadArgs? args = _args[lessonId];
    if (args == null) return;

    _put(lessonId, DownloadItemStatus.downloading, progress: state.of(lessonId)?.progress ?? 0);

    try {
      final String studentId = await SharedPreferencesHelper.getSecuredString(LocalStorageKeys.userId);
      final String accessToken = await SharedPreferencesHelper.getSecuredString(LocalStorageKeys.accessToken);
      final String deviceUuid = await _deviceService.getDeviceUuid();

      final DownloadOutcome outcome = await _service.downloadLesson(
        lessonId: lessonId,
        videoUrl: args.videoUrl,
        studentId: studentId,
        deviceUuid: deviceUuid,
        accessToken: accessToken,
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
      _put(lessonId, DownloadItemStatus.failed, error: ErrorHandler.handleFailureError(error).statusMessage);
    }
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
