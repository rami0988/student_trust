class VideoPlayerArgs {
  final String lessonId;
  final String lessonTitle;
  final String studentName;
  final String studentPhone;
  final bool isOffline;
  final int savedPosition;

  /// Custom stream endpoint (worksheet solution videos); null for lessons.
  final String? streamEndpoint;

  /// Whether playback position is persisted (lessons only — worksheet videos
  /// have no video_progress row).
  final bool trackProgress;

  const VideoPlayerArgs({
    required this.lessonId,
    required this.lessonTitle,
    required this.studentName,
    required this.studentPhone,
    this.isOffline = false,
    this.savedPosition = 0,
    this.streamEndpoint,
    this.trackProgress = true,
  });
}
