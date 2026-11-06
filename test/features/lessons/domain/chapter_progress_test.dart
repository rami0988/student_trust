import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_template/features/lessons/domain/entities/chapter_progress.dart';
import 'package:mobile_template/features/lessons/domain/entities/lesson.dart';
import 'package:mobile_template/features/lessons/domain/entities/progress.dart';

Lesson _lesson(String id, {int duration = 600, int position = 0, bool completed = false}) => Lesson(
  id: id,
  chapterId: 'c1',
  title: id,
  durationSeconds: duration,
  progress: Progress(positionSeconds: position, isCompleted: completed),
);

void main() {
  group('ChapterProgress.fromLessons', () {
    test('counts, total length and watch-time fraction', () {
      final ChapterProgress p = ChapterProgress.fromLessons([
        _lesson('a', completed: true),
        _lesson('b', position: 300),
        _lesson('c'),
        _lesson('d'),
      ]);
      expect(p.lessonCount, 4);
      expect(p.completedCount, 1);
      expect(p.totalDuration, const Duration(minutes: 40));
      expect(p.fraction, closeTo(900 / 2400, 1e-9));
    });

    test('resumes the lesson left part-way', () {
      final ChapterProgress p = ChapterProgress.fromLessons([_lesson('a', completed: true), _lesson('b', position: 120), _lesson('c')]);
      expect(p.resumeLesson?.id, 'b');
      expect(p.resumeKind, ResumeKind.resume);
    });

    test('next not-started lesson after completed ones', () {
      final ChapterProgress p = ChapterProgress.fromLessons([_lesson('a', completed: true), _lesson('b')]);
      expect(p.resumeLesson?.id, 'b');
      expect(p.resumeKind, ResumeKind.next);
    });

    test('start when nothing is watched, rewatch when all done', () {
      expect(ChapterProgress.fromLessons([_lesson('a'), _lesson('b')]).resumeKind, ResumeKind.start);
      final ChapterProgress done = ChapterProgress.fromLessons([_lesson('a', completed: true), _lesson('b', completed: true)]);
      expect(done.resumeKind, ResumeKind.rewatch);
      expect(done.resumeLesson?.id, 'a');
      expect(done.fraction, 1);
    });

    test('a position past the end never counts for more than the lesson', () {
      final ChapterProgress p = ChapterProgress.fromLessons([_lesson('a', duration: 100, position: 500)]);
      expect(p.fraction, 1);
    });

    test('falls back to completed share without durations, and uses the server total', () {
      final ChapterProgress p = ChapterProgress.fromLessons([_lesson('a', duration: 0, completed: true), _lesson('b', duration: 0)], lessonCount: 4);
      expect(p.lessonCount, 4);
      expect(p.fraction, 0.25);
    });

    test('empty chapter has nothing to resume', () {
      final ChapterProgress p = ChapterProgress.fromLessons(const []);
      expect(p.resumeLesson, isNull);
      expect(p.fraction, 0);
    });
  });

  group('filters', () {
    final List<Lesson> lessons = [_lesson('a', completed: true), _lesson('b', position: 60), _lesson('c')];

    test('each filter selects the right lessons', () {
      expect(ChapterProgress.filter(lessons, LessonFilter.all, {}).length, 3);
      expect(ChapterProgress.filter(lessons, LessonFilter.inProgress, {}).map((l) => l.id), ['b']);
      expect(ChapterProgress.filter(lessons, LessonFilter.completed, {}).map((l) => l.id), ['a']);
      expect(ChapterProgress.filter(lessons, LessonFilter.downloaded, {'c'}).map((l) => l.id), ['c']);
    });
  });
}
