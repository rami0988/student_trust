import '../../../../core/models/paginated_result.dart';
import '../models/chapter_model.dart';

abstract class ChaptersRemoteDataSource {
  Future<PaginatedResult<ChapterModel>> getChapters(String subjectId, {int page = 1, int limit = 50});
}
