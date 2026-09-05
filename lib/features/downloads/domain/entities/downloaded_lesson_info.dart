import 'package:equatable/equatable.dart';

/// Display info for a single downloaded lesson, read from local metadata.
class DownloadedLessonInfo extends Equatable {
  final String lessonId;
  final String title;
  final int durationSeconds;
  final DateTime? downloadedAt;

  /// Local path of the cached thumbnail (jpg), or null when none was saved.
  final String? thumbPath;

  /// On-disk size of the video. 0 for downloads saved before size tracking
  /// existed — the UI treats that as "unknown" rather than "empty".
  final int sizeBytes;

  const DownloadedLessonInfo({
    required this.lessonId,
    required this.title,
    required this.durationSeconds,
    required this.downloadedAt,
    this.thumbPath,
    this.sizeBytes = 0,
  });

  @override
  List<Object?> get props => [lessonId, title, durationSeconds, downloadedAt, thumbPath, sizeBytes];
}
