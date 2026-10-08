import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/app_enums.dart';
import '../../../../core/utils/local_storage_keys.dart';
import '../../../../core/utils/shared_preferences_helper.dart';
import '../../../../generated/l10n.dart';
import '../../../downloads/data/services/encrypted_download_service.dart';
import '../../../downloads/data/services/offline_crypto.dart';
import '../../../downloads/data/services/offline_media_server.dart';
import '../../../downloads/domain/repositories/downloads_repository.dart';
import '../../domain/entities/video_stream_info.dart';
import '../../domain/repositories/video_repository.dart';
import 'video_state.dart';

@injectable
class VideoCubit extends Cubit<VideoState> {
  final VideoRepository _videoRepository;
  final EncryptedDownloadService _downloadService;
  final DownloadsRepository _downloadsRepository;
  final OfflineMediaServer _mediaServer;

  VideoCubit(this._videoRepository, this._downloadService, this._downloadsRepository, this._mediaServer)
    : super(VideoState.initial());

  /// The lesson currently registered with [_mediaServer], released on close.
  String? _servedLessonId;
  StreamSubscription<String>? _corruptionSub;

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
      // Stream the encrypted download through the loopback server: playback
      // starts immediately and seeks freely, and no plaintext copy is written.
      final OfflinePlaybackSource source = await _downloadService.prepareOfflinePlayback(
        lessonId: lessonId,
        studentId: studentId,
        deviceUuid: deviceUuid,
      );
      final Uri url = await _mediaServer.serve(source);
      _servedLessonId = lessonId;
      _watchForCorruption(lessonId);
      _emitLocalReady(url.toString(), savedPosition: savedPosition);
    } catch (error) {
      // The 7-day grace window expired — try a one-off online re-validation.
      // Within the window playback is fully offline and never reaches here.
      // Past the 30-day hard cap: the service has already purged the files.
      if (error.toString().contains('LICENSE_EXPIRED')) {
        emit(
          state.rebuild(
            (b) => b
              ..status = Status.failure
              ..failure = LicenseExpiredFailure(S.current.downloadExpired),
          ),
        );
        return;
      }
      if (allowRevalidate && error.toString().contains('VALIDATION_REQUIRED')) {
        bool valid = false;
        bool revoked = false;
        try {
          final result = await _downloadsRepository.validateDownload(lessonId);
          valid = result.fold(
            success: (isValid) => isValid,
            failure: (failure) {
              // The server definitively said "no longer entitled" — distinct
              // from simply being offline, which keeps the lesson locked.
              revoked = failure is NotSubscribedFailure || failure is AccountInactiveFailure;
              return false;
            },
          );
        } catch (_) {
          // No internet: keep valid=false so the clear "connect once"
          // message below is shown instead of a raw network error.
        }
        if (revoked) {
          // Policy: an ended subscription keeps nothing on the device.
          // (An inactive account is purged wholesale via
          // AccountDeactivatedEvent; this covers a single lost subject.)
          try {
            await _downloadService.deleteLesson(lessonId);
          } catch (_) {}
          emit(
            state.rebuild(
              (b) => b
                ..status = Status.failure
                ..failure = NotSubscribedFailure(S.current.subscriptionEndedDownloadRemoved),
            ),
          );
          return;
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
              ..failure = MediaCorruptedFailure(S.current.downloadCorrupted),
          ),
        );
        return;
      }
      rethrow;
    }
  }

  /// A chunk failing its integrity check mid-playback means the download is
  /// damaged: drop it (so the lesson offers a fresh download) and say so,
  /// rather than leaving the student on a frozen frame.
  void _watchForCorruption(String lessonId) {
    _corruptionSub?.cancel();
    _corruptionSub = _mediaServer.corruptedLessons.where((id) => id == lessonId).listen((_) async {
      await _corruptionSub?.cancel();
      _corruptionSub = null;
      await _mediaServer.release(lessonId);
      _servedLessonId = null;
      try {
        await _downloadService.markDamaged(lessonId);
      } catch (_) {}
      if (isClosed) return;
      emit(
        state.rebuild(
          (b) => b
            ..status = Status.failure
            ..failure = MediaCorruptedFailure(S.current.mediaCorrupted),
        ),
      );
    });
  }

  /// [url] is the loopback media-server address for the downloaded lesson.
  void _emitLocalReady(String url, {required int savedPosition}) {
    final VideoState next = state.rebuild(
      (b) => b
        ..status = Status.success
        ..isProcessing = false
        ..failure = null
        ..videoUrl = url
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

  @override
  Future<void> close() async {
    await _corruptionSub?.cancel();
    final String? served = _servedLessonId;
    _servedLessonId = null;
    // Stops serving the lesson; the server shuts down (and its token dies)
    // once nothing is playing.
    if (served != null) await _mediaServer.release(served);
    return super.close();
  }

  /// Called when native screen-recording detection fires.
  void screenRecordingDetected() => emit(state.rebuild((b) => b..isRecordingDetected = true));

  /// Restores playback once recording stops.
  void resumeVideo() {
    final VideoState? last = _lastReady;
    if (last != null) emit(last.rebuild((b) => b..isRecordingDetected = false));
  }
}
