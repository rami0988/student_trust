import 'package:equatable/equatable.dart';

/// Lifecycle of a single lesson download.
///
/// [queued] means the student asked for it but a concurrency slot isn't free
/// yet — a dozen taps must not open a dozen competing streams on one weak
/// connection, which is how they all end up failing.
///
/// [waitingForNetwork] means the connection dropped completely: the download
/// is not failed, it resumes by itself (from the bytes already on disk) as
/// soon as the device is back online.
///
/// [expired] means a completed download outlived its 30-day offline lifetime
/// and was removed; the lesson can simply be downloaded again.
enum DownloadItemStatus { queued, downloading, paused, waitingForNetwork, completed, failed, deleted, expired }

/// The current state of a single lesson's download.
class DownloadItem extends Equatable {
  final String lessonId;
  final DownloadItemStatus status;

  /// Overall completion 0..1 (transfer is the first 85%, encryption the rest).
  final double progress;
  final String? error;

  /// Shown in the downloads page's in-progress list.
  final String title;

  /// Bytes on disk and the advertised total (0 when not yet known).
  final int bytesReceived;
  final int totalBytes;

  /// Smoothed transfer speed; 0 when idle or unknown.
  final double speedBytesPerSecond;

  const DownloadItem({
    required this.lessonId,
    required this.status,
    this.progress = 0,
    this.error,
    this.title = '',
    this.bytesReceived = 0,
    this.totalBytes = 0,
    this.speedBytesPerSecond = 0,
  });

  /// [error] is replaced, not merged: omit it to clear the previous one.
  DownloadItem copyWith({
    DownloadItemStatus? status,
    double? progress,
    String? error,
    String? title,
    int? bytesReceived,
    int? totalBytes,
    double? speedBytesPerSecond,
  }) {
    return DownloadItem(
      lessonId: lessonId,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      error: error,
      title: title ?? this.title,
      bytesReceived: bytesReceived ?? this.bytesReceived,
      totalBytes: totalBytes ?? this.totalBytes,
      speedBytesPerSecond: speedBytesPerSecond ?? this.speedBytesPerSecond,
    );
  }

  bool get isBusy =>
      status == DownloadItemStatus.queued ||
      status == DownloadItemStatus.downloading ||
      status == DownloadItemStatus.paused ||
      status == DownloadItemStatus.waitingForNetwork;

  /// Estimated time left, or null when it can't be estimated honestly (size
  /// unknown, no speed yet, or past the transfer into encryption).
  Duration? get remaining {
    if (status != DownloadItemStatus.downloading) return null;
    if (totalBytes <= 0 || speedBytesPerSecond <= 0 || bytesReceived >= totalBytes) return null;
    final double seconds = (totalBytes - bytesReceived) / speedBytesPerSecond;
    return Duration(seconds: seconds.ceil());
  }

  @override
  List<Object?> get props => [lessonId, status, progress, error, title, bytesReceived, totalBytes, speedBytesPerSecond];
}
