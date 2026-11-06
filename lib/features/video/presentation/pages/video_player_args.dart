class VideoPlayerArgs {
  final String lessonId;
  final String lessonTitle;
  final String studentName;
  final String studentPhone;
  final bool isOffline;
  final int savedPosition;

  /// Lesson description shown under the title (null/empty hides it).
  final String? description;

  /// Custom stream endpoint (worksheet solution videos); null for lessons.
  final String? streamEndpoint;

  /// Whether playback position is persisted (lessons only — worksheet videos
  /// have no video_progress row).
  final bool trackProgress;

  /// Known length of the lesson, used before the player reports its own
  /// (time-saved estimate, watch progress). 0 when unknown.
  final int durationSeconds;

  /// Position in the chapter ("Lesson 2 of 6"); null hides the line.
  final int? lessonNumber;
  final int? lessonCount;
  final String? chapterTitle;

  /// Total length of the chapter, for "across the whole chapter you save …".
  /// Only passed when the whole chapter is known (not a partial page).
  final int? chapterDurationSeconds;

  /// Whether the lesson is downloaded to this device (shows the badge).
  final bool isDownloaded;

  /// Lesson thumbnail: the zoom mini-map's picture of the frame.
  final String? thumbnailUrl;

  /// The following lesson, for the "Up next" card; null hides it.
  final VideoPlayerArgs? nextLesson;

  const VideoPlayerArgs({
    required this.lessonId,
    required this.lessonTitle,
    required this.studentName,
    required this.studentPhone,
    this.isOffline = false,
    this.savedPosition = 0,
    this.description,
    this.streamEndpoint,
    this.trackProgress = true,
    this.durationSeconds = 0,
    this.lessonNumber,
    this.lessonCount,
    this.chapterTitle,
    this.chapterDurationSeconds,
    this.isDownloaded = false,
    this.thumbnailUrl,
    this.nextLesson,
  });
}
