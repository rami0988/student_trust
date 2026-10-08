import 'package:injectable/injectable.dart';

import 'encrypted_download_service.dart';

export 'encrypted_download_service.dart' show DownloadOutcome;

/// Everything an engine needs to fetch, verify and encrypt one lesson.
class DownloadRequest {
  final String lessonId;

  /// Backend stream endpoint; the engine resolves it to a signed CDN URL.
  final String videoUrl;
  final String studentId;
  final String deviceUuid;

  /// Re-read before every attempt — a transfer can outlive an access token.
  final Future<String> Function() accessToken;
  final String title;
  final int durationSeconds;
  final String? thumbnailUrl;

  const DownloadRequest({
    required this.lessonId,
    required this.videoUrl,
    required this.studentId,
    required this.deviceUuid,
    required this.accessToken,
    this.title = '',
    this.durationSeconds = 0,
    this.thumbnailUrl,
  });
}

/// A progress report from an engine.
class TransferProgress {
  /// Overall completion, 0..1 — transfer is the first 85%, encryption the rest.
  final double fraction;

  /// Bytes of the video on disk so far, and the advertised total (0 if unknown).
  final int bytesReceived;
  final int totalBytes;

  const TransferProgress({required this.fraction, required this.bytesReceived, required this.totalBytes});
}

/// Transfers one lesson to encrypted local storage.
///
/// The seam between WHAT should be downloaded (the cubit's persistent queue)
/// and HOW bytes get to disk. Phase 1 ships [DartDownloadEngine] (in-process
/// Dio). Phase 3 can register a native background engine behind this same
/// interface without the queue, records, or UI changing.
abstract class DownloadEngine {
  /// Runs the download to completion, pause, or cancellation. Throws on a
  /// real failure after the engine's own retries.
  Future<DownloadOutcome> start(DownloadRequest request, {required void Function(TransferProgress) onProgress});

  /// Stops [lessonId], keeping the partial for a later [start] to resume.
  void pause(String lessonId);

  /// Stops [lessonId] and deletes everything it wrote.
  void cancel(String lessonId);

  bool isActive(String lessonId);
}

/// In-process engine on top of [EncryptedDownloadService]: Range-resumed Dio
/// transfer, size-verified, encrypted in a background isolate.
///
/// Since Phase 3 this is the FALLBACK engine (non-mobile platforms, tests, and
/// `--dart-define=DOWNLOAD_ENGINE=dart` for debugging); production Android/iOS
/// use `NativeDownloadEngine`. See `download_engine_module.dart`.
@lazySingleton
class DartDownloadEngine implements DownloadEngine {
  final EncryptedDownloadService _service;

  DartDownloadEngine(this._service);

  @override
  Future<DownloadOutcome> start(DownloadRequest request, {required void Function(TransferProgress) onProgress}) {
    int received = 0;
    int total = 0;
    return _service.downloadLesson(
      lessonId: request.lessonId,
      videoUrl: request.videoUrl,
      studentId: request.studentId,
      deviceUuid: request.deviceUuid,
      accessToken: request.accessToken,
      title: request.title,
      durationSeconds: request.durationSeconds,
      thumbnailUrl: request.thumbnailUrl,
      onBytes: (r, t) {
        received = r;
        total = t;
      },
      onProgress: (fraction) =>
          onProgress(TransferProgress(fraction: fraction, bytesReceived: received, totalBytes: total)),
    );
  }

  @override
  void pause(String lessonId) => _service.pause(lessonId);

  @override
  void cancel(String lessonId) => _service.cancel(lessonId);

  @override
  bool isActive(String lessonId) => _service.isActive(lessonId);
}
