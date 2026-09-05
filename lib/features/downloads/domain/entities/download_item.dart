import 'package:equatable/equatable.dart';

/// [queued] means the student asked for it but a concurrency slot isn't free
/// yet — a dozen taps must not open a dozen competing streams on one weak
/// connection, which is how they all end up failing.
enum DownloadItemStatus { queued, downloading, paused, completed, failed, deleted }

/// The current state of a single lesson's download.
class DownloadItem extends Equatable {
  final String lessonId;
  final DownloadItemStatus status;
  final double progress;
  final String? error;

  const DownloadItem({required this.lessonId, required this.status, this.progress = 0, this.error});

  DownloadItem copyWith({DownloadItemStatus? status, double? progress, String? error}) {
    return DownloadItem(lessonId: lessonId, status: status ?? this.status, progress: progress ?? this.progress, error: error);
  }

  bool get isBusy =>
      status == DownloadItemStatus.queued || status == DownloadItemStatus.downloading || status == DownloadItemStatus.paused;

  @override
  List<Object?> get props => [lessonId, status, progress, error];
}
