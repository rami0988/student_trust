import '../models/lesson_model.dart';

abstract class LessonsRemoteDataSource {
  Future<List<LessonModel>> getLessons(String chapterId);
  Future<void> saveProgress(String lessonId, int positionSeconds, bool isCompleted);
}
