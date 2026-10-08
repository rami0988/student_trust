/// Lifecycle of a download that has been requested but is not finished yet.
///
/// Persisted, so it survives an app kill: on the next launch a record left in
/// [downloading] or [queued] is resumed automatically, [paused] stays paused
/// until the student resumes it, and [waitingForNetwork] resumes as soon as
/// the connection returns. A finished download is no longer a record — it
/// moves to the completed-downloads metadata the offline library reads.
///
/// APPEND-ONLY: values are persisted by index through the generated Hive
/// adapter. Reordering or removing one would silently remap stored records.
enum DownloadRecordStatus { queued, downloading, paused, waitingForNetwork, failed }

/// A persisted, in-flight lesson download: everything needed to resume it
/// after a restart, plus the last progress figures for the UI.
class DownloadRecord {
  final String lessonId;

  /// The backend stream endpoint for the lesson (not the signed CDN URL,
  /// which expires — it is re-resolved on every attempt).
  final String videoUrl;
  final String title;
  final int durationSeconds;
  final String? thumbnailUrl;

  final DownloadRecordStatus status;

  /// Bytes of the partial file on disk at the last checkpoint, and the full
  /// size the server advertised (0 until known).
  final int bytesReceived;
  final int totalBytes;

  /// Last failure shown to the student, kept so a failed download still
  /// explains itself after a restart.
  final String? error;

  final DateTime createdAt;
  final DateTime updatedAt;

  const DownloadRecord({
    required this.lessonId,
    required this.videoUrl,
    required this.title,
    required this.durationSeconds,
    required this.thumbnailUrl,
    required this.status,
    required this.bytesReceived,
    required this.totalBytes,
    required this.error,
    required this.createdAt,
    required this.updatedAt,
  });

  /// A newly requested download, queued for a free slot.
  factory DownloadRecord.queued({
    required String lessonId,
    required String videoUrl,
    String title = '',
    int durationSeconds = 0,
    String? thumbnailUrl,
    DateTime? now,
  }) {
    final DateTime at = now ?? DateTime.now();
    return DownloadRecord(
      lessonId: lessonId,
      videoUrl: videoUrl,
      title: title,
      durationSeconds: durationSeconds,
      thumbnailUrl: thumbnailUrl,
      status: DownloadRecordStatus.queued,
      bytesReceived: 0,
      totalBytes: 0,
      error: null,
      createdAt: at,
      updatedAt: at,
    );
  }

  /// [error] is replaced, not merged: pass it to set one, omit it to clear.
  DownloadRecord copyWith({
    DownloadRecordStatus? status,
    int? bytesReceived,
    int? totalBytes,
    String? error,
    DateTime? updatedAt,
  }) {
    return DownloadRecord(
      lessonId: lessonId,
      videoUrl: videoUrl,
      title: title,
      durationSeconds: durationSeconds,
      thumbnailUrl: thumbnailUrl,
      status: status ?? this.status,
      bytesReceived: bytesReceived ?? this.bytesReceived,
      totalBytes: totalBytes ?? this.totalBytes,
      error: error,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
