import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/app_enums.dart';
import '../../../../core/utils/local_storage_keys.dart';
import '../../../../core/utils/shared_preferences_helper.dart';
import '../../../../generated/l10n.dart';
import '../../../downloads/data/services/encrypted_download_service.dart';
import '../../../downloads/domain/repositories/downloads_repository.dart';
import '../../domain/entities/video_stream_info.dart';
import '../../domain/repositories/video_repository.dart';
import 'video_state.dart';

@injectable
class VideoCubit extends Cubit<VideoState> {
  final VideoRepository _videoRepository;
  final EncryptedDownloadService _downloadService;
  final DownloadsRepository _downloadsRepository;

  VideoCubit(this._videoRepository, this._downloadService, this._downloadsRepository) : super(VideoState.initial());

  VideoState? _lastReady;

  /// Custom stream endpoint (worksheet solution videos); null for lessons.
  String? _streamEndpoint;

  Future<void> loadVideo({
    required String lessonId,
    required bool isOffline,
    required String studentId,
    required String deviceUuid,
    int savedPosition = 0,
    String? streamEndpoint,
  }) async {
    emit(
      state.rebuild(
        (b) => b
          ..status = Status.loading
          ..isProcessing = false
          ..failure = null,
      ),
    );
    _streamEndpoint = streamEndpoint;

    if (isOffline) {
      try {
        await _loadOffline(
          lessonId: lessonId,
          studentId: studentId,
          deviceUuid: deviceUuid,
          savedPosition: savedPosition,
          allowRevalidate: true,
        );
      } catch (error) {
        emit(
          state.rebuild(
            (b) => b
              ..status = Status.failure
              ..failure = GeneralFailure(error.toString()),
          ),
        );
      }
      return;
    }

    final result = await _videoRepository.resolveStream(lessonId, streamEndpoint: streamEndpoint);
    await result.fold(
      success: (info) async => _emitReady(info, savedPosition: savedPosition),
      failure: (failure) async => emit(
        state.rebuild(
          (b) => b
            ..status = Status.failure
            ..isProcessing = failure is VideoProcessingFailure
            ..failure = failure,
        ),
      ),
    );
  }

  /// Re-resolves the online stream URL without resetting playback position.
  /// Used when a BunnyCDN signed URL expires mid-playback (token refresh).
  Future<void> refreshVideoUrl(String lessonId, {int savedPosition = 0}) async {
    if (state.isLocal) return; // offline never expires
    final int position = savedPosition > 0 ? savedPosition : state.savedPosition;

    final result = await _videoRepository.resolveStream(lessonId, streamEndpoint: _streamEndpoint);
    await result.fold(
      success: (info) async => _emitReady(info, savedPosition: position),
      // Keep the current player on a transient failure.
      failure: (_) async {},
    );
  }

  Future<void> _emitReady(VideoStreamInfo info, {required int savedPosition}) async {
    final String? token = info.isBunny ? null : await SharedPreferencesHelper.getSecuredString(LocalStorageKeys.accessToken);
    final VideoState next = state.rebuild(
      (b) => b
        ..status = Status.success
        ..isProcessing = false
        ..failure = null
        ..videoUrl = info.url
        ..isLocal = false
        ..authToken = token
        ..savedPosition = savedPosition
        ..thumbnailUrl = info.thumbnailUrl
        ..expiresAt = info.expiresAt,
    );
    _lastReady = next;
    emit(next);
  }

  Future<void> _loadOffline({
    required String lessonId,
    required String studentId,
    required String deviceUuid,
    required int savedPosition,
    required bool allowRevalidate,
  }) async {
    try {
      final String path = await _downloadService.getOfflineVideoPath(lessonId: lessonId, studentId: studentId, deviceUuid: deviceUuid);
      _emitLocalReady(path, savedPosition: savedPosition);
    } catch (error) {
      // The 7-day grace window expired — try a one-off online re-validation.
      // Within the window playback is fully offline and never reaches here.
      if (allowRevalidate && error.toString().contains('VALIDATION_REQUIRED')) {
        bool valid = false;
        try {
          final result = await _downloadsRepository.validateDownload(lessonId);
          valid = result.fold(success: (isValid) => isValid, failure: (_) => false);
        } catch (_) {
          // No internet: keep valid=false so the clear "connect once"
          // message below is shown instead of a raw network error.
        }
        if (valid) {
          await _downloadService.markValidated(lessonId);
          await _loadOffline(
            lessonId: lessonId,
            studentId: studentId,
            deviceUuid: deviceUuid,
            savedPosition: savedPosition,
            allowRevalidate: false,
          );
          return;
        }
        emit(
          state.rebuild(
            (b) => b
              ..status = Status.failure
              ..failure = GeneralFailure(S.current.validationRequired),
          ),
        );
        return;
      }
      // The download is present in metadata but unusable on disk (missing or
      // undecryptable chunks). The service has already dropped it, so tell the
      // student to download it again rather than surfacing a raw exception.
      if (error.toString().contains('DOWNLOAD_CORRUPTED')) {
        emit(
          state.rebuild(
            (b) => b
              ..status = Status.failure
              ..failure = GeneralFailure(S.current.downloadCorrupted),
          ),
        );
        return;
      }
      rethrow;
    }
  }

  void _emitLocalReady(String path, {required int savedPosition}) {
    final VideoState next = state.rebuild(
      (b) => b
        ..status = Status.success
        ..isProcessing = false
        ..failure = null
        ..videoUrl = 'file://$path'
        ..isLocal = true
        ..authToken = null
        ..savedPosition = savedPosition
        ..thumbnailUrl = null
        ..expiresAt = null,
    );
    _lastReady = next;
    emit(next);
  }

  /// Surfaces a playback failure the player couldn't recover from by
  /// re-resolving the URL. Without this the page would sit on a dead player
  /// with no message, since a decode/codec error never resolves itself.
  void reportPlaybackFailure(String message) {
    emit(
      state.rebuild(
        (b) => b
          ..status = Status.failure
          ..isProcessing = false
          ..failure = GeneralFailure(message),
      ),
    );
  }

  /// Called when native screen-recording detection fires.
  void screenRecordingDetected() => emit(state.rebuild((b) => b..isRecordingDetected = true));

  /// Restores playback once recording stops.
  void resumeVideo() {
    final VideoState? last = _lastReady;
    if (last != null) emit(last.rebuild((b) => b..isRecordingDetected = false));
  }
}
