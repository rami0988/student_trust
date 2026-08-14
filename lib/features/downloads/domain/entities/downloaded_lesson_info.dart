import 'package:equatable/equatable.dart';

/// Display info for a single downloaded lesson, read from local metadata.
class DownloadedLessonInfo extends Equatable {
  final String lessonId;
  final String title;
  final int durationSeconds;
  final DateTime? downloadedAt;

  /// Local path of the cached thumbnail (jpg), or null when none was saved.
  final String? thumbPath;

  const DownloadedLessonInfo({
    required this.lessonId,
    required this.title,
    required this.durationSeconds,
    required this.downloadedAt,
    this.thumbPath,
  });

  @override
  List<Object?> get props => [lessonId, title, durationSeconds, downloadedAt, thumbPath];
}
