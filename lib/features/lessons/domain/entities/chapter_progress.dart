import 'package:equatable/equatable.dart';

import 'lesson.dart';

/// Lessons-list filters.
enum LessonFilter { all, inProgress, completed, downloaded }

/// What the chapter hero's main button does.
enum ResumeKind {
  /// A lesson was left part-way: continue it.
  resume,

  /// Some lessons are done; play the first one not started yet.
  next,

  /// Nothing watched yet: start with the first lesson.
  start,

  /// Everything is done: watch the first lesson again.
  rewatch,
}

/// A student's progress through one chapter, derived from its lessons.
class ChapterProgress extends Equatable {
  final int lessonCount;
  final int completedCount;
  final Duration totalDuration;

  /// Share of the chapter watched, 0–1 (by watch time when durations are
  /// known, by completed lessons otherwise).
  final double fraction;

  /// The lesson the hero's button plays, or null for an empty chapter.
  final Lesson? resumeLesson;
  final ResumeKind resumeKind;

  const ChapterProgress({
    required this.lessonCount,
    required this.completedCount,
    required this.totalDuration,
    required this.fraction,
    required this.resumeLesson,
    required this.resumeKind,
  });

  /// [lessonCount] defaults to `lessons.length`; pass the server total when
  /// only the first page is loaded.
  factory ChapterProgress.fromLessons(List<Lesson> lessons, {int? lessonCount}) {
    int completed = 0;
    int totalSeconds = 0;
    int watchedSeconds = 0;
    for (final Lesson lesson in lessons) {
      final int length = lesson.durationSeconds;
      totalSeconds += length;
      if (lesson.progress.isCompleted) {
        completed++;
        watchedSeconds += length;
      } else {
        watchedSeconds += lesson.progress.positionSeconds.clamp(0, length);
      }
    }
    final int count = lessonCount ?? lessons.length;
    final double fraction = totalSeconds > 0
        ? watchedSeconds / totalSeconds
        : (count > 0 ? completed / count : 0);

    Lesson? resume;
    ResumeKind kind = ResumeKind.start;
    final Iterable<Lesson> inProgress = lessons.where(isInProgress);
    if (inProgress.isNotEmpty) {
      resume = inProgress.first;
      kind = ResumeKind.resume;
    } else {
      final Iterable<Lesson> notDone = lessons.where((l) => !l.progress.isCompleted);
      if (notDone.isNotEmpty) {
        resume = notDone.first;
        kind = completed > 0 ? ResumeKind.next : ResumeKind.start;
      } else if (lessons.isNotEmpty) {
        resume = lessons.first;
        kind = ResumeKind.rewatch;
      }
    }

    return ChapterProgress(
      lessonCount: count,
      completedCount: completed,
      totalDuration: Duration(seconds: totalSeconds),
      fraction: fraction.clamp(0.0, 1.0),
      resumeLesson: resume,
      resumeKind: kind,
    );
  }

  /// Started but not finished.
  static bool isInProgress(Lesson lesson) => !lesson.progress.isCompleted && lesson.progress.positionSeconds > 0;

  static bool matches(Lesson lesson, LessonFilter filter, Set<String> downloadedIds) => switch (filter) {
    LessonFilter.all => true,
    LessonFilter.inProgress => isInProgress(lesson),
    LessonFilter.completed => lesson.progress.isCompleted,
    LessonFilter.downloaded => downloadedIds.contains(lesson.id),
  };

  static List<Lesson> filter(List<Lesson> lessons, LessonFilter filter, Set<String> downloadedIds) =>
      lessons.where((l) => matches(l, filter, downloadedIds)).toList();

  @override
  List<Object?> get props => [lessonCount, completedCount, totalDuration, fraction, resumeLesson, resumeKind];
}
