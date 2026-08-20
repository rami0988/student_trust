import 'package:injectable/injectable.dart';

import '../../../../core/models/paginated_result.dart';
import '../../../../core/repositories/base_repository_impl.dart';
import '../../../../core/utils/request_result.dart';
import '../../domain/entities/subject.dart';
import '../../domain/repositories/subjects_repository.dart';
import '../data_sources/subjects_remote_data_source.dart';
import '../models/subject_model.dart';

@LazySingleton(as: SubjectsRepository)
class SubjectsRepositoryImpl extends BaseRepositoryImpl implements SubjectsRepository {
  final SubjectsRemoteDataSource _subjectsRemoteDataSource;

  SubjectsRepositoryImpl(this._subjectsRemoteDataSource) : super('SubjectsRepository');

  @override
  Future<RequestResult<PaginatedResult<Subject>>> getSubjects({int page = 1, int limit = 50}) => execute(
    () => _subjectsRemoteDataSource.getSubjects(page: page, limit: limit),
    converter: (PaginatedResult<SubjectModel> page) => page.map((m) => m.toDomain()),
  );

  @override
  Future<RequestResult<List<Subject>>> getAllSubjects() => executeAllPages<Subject, SubjectModel>(
    (page) => _subjectsRemoteDataSource.getSubjects(page: page, limit: 100),
    converter: (m) => m.toDomain(),
  );
}
