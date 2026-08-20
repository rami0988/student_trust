import '../../../../core/models/paginated_result.dart';
import '../models/lesson_model.dart';

abstract class LessonsRemoteDataSource {
  Future<PaginatedResult<LessonModel>> getLessons(String chapterId, {int page = 1, int limit = 50});
  Future<void> saveProgress(String lessonId, int positionSeconds, bool isCompleted);
}
