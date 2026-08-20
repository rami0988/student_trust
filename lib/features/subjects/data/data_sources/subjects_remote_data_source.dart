import '../../../../core/models/paginated_result.dart';
import '../models/subject_model.dart';

abstract class SubjectsRemoteDataSource {
  Future<PaginatedResult<SubjectModel>> getSubjects({int page = 1, int limit = 50});
}
