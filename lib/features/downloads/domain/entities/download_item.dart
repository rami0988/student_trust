import 'package:equatable/equatable.dart';

enum DownloadItemStatus { downloading, paused, completed, failed, deleted }

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

  bool get isBusy => status == DownloadItemStatus.downloading || status == DownloadItemStatus.paused;

  @override
  List<Object?> get props => [lessonId, status, progress, error];
}
