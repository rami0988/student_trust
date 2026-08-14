import '../../../../core/repositories/base_repository.dart';
import '../../../../core/utils/request_result.dart';
import '../entities/chapter.dart';

abstract class ChaptersRepository extends BaseRepository {
  Future<RequestResult<List<Chapter>>> getChapters(String subjectId);
}
