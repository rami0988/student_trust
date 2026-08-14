import 'package:injectable/injectable.dart';

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
  Future<RequestResult<List<Subject>>> getSubjects() => execute(
    () => _subjectsRemoteDataSource.getSubjects(),
    converter: (List<SubjectModel> models) => models.map((m) => m.toDomain()).toList(),
  );
}
