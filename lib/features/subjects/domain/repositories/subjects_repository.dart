import '../../../../core/repositories/base_repository.dart';
import '../../../../core/utils/request_result.dart';
import '../entities/subject.dart';

abstract class SubjectsRepository extends BaseRepository {
  Future<RequestResult<List<Subject>>> getSubjects();
}
