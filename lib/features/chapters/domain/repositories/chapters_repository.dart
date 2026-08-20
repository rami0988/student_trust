import '../../../../core/models/paginated_result.dart';
import '../../../../core/repositories/base_repository.dart';
import '../../../../core/utils/request_result.dart';
import '../entities/chapter.dart';

abstract class ChaptersRepository extends BaseRepository {
  Future<RequestResult<PaginatedResult<Chapter>>> getChapters(String subjectId, {int page = 1, int limit = 50});
}
