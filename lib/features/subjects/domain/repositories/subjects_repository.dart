import '../../../../core/models/paginated_result.dart';
import '../../../../core/repositories/base_repository.dart';
import '../../../../core/utils/request_result.dart';
import '../entities/subject.dart';

abstract class SubjectsRepository extends BaseRepository {
  Future<RequestResult<PaginatedResult<Subject>>> getSubjects({int page = 1, int limit = 50});

  /// Loops every backend page and concatenates them — used only by
  /// [SubjectsCubit.searchSubjects], since the endpoint has no server-side
  /// `?search=` and a query must be able to reach further than whatever page
  /// happens to be loaded.
  Future<RequestResult<List<Subject>>> getAllSubjects();
}
