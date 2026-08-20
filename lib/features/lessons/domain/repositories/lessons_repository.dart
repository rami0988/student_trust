import '../../../../core/models/paginated_result.dart';
import '../../../../core/repositories/base_repository.dart';
import '../../../../core/utils/request_result.dart';
import '../entities/lesson.dart';

abstract class LessonsRepository extends BaseRepository {
  Future<RequestResult<PaginatedResult<Lesson>>> getLessons(String chapterId, {int page = 1, int limit = 50});

  /// Persists playback position. Called periodically while a lesson plays.
  /// Throws on failure — the caller (video feature) treats a transient error
  /// as ignorable rather than surfacing it to the student.
  Future<void> saveProgress(String lessonId, int positionSeconds, bool isCompleted);
}
