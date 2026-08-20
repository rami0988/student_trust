import 'package:injectable/injectable.dart';

import '../../../../core/models/paginated_result.dart';
import '../../../../core/repositories/base_repository_impl.dart';
import '../../../../core/utils/request_result.dart';
import '../../domain/entities/lesson.dart';
import '../../domain/repositories/lessons_repository.dart';
import '../data_sources/lessons_remote_data_source.dart';

@LazySingleton(as: LessonsRepository)
class LessonsRepositoryImpl extends BaseRepositoryImpl implements LessonsRepository {
  final LessonsRemoteDataSource _lessonsRemoteDataSource;

  LessonsRepositoryImpl(this._lessonsRemoteDataSource) : super('LessonsRepository');

  @override
  Future<RequestResult<PaginatedResult<Lesson>>> getLessons(String chapterId, {int page = 1, int limit = 50}) => execute(
    () => _lessonsRemoteDataSource.getLessons(chapterId, page: page, limit: limit),
    converter: (page) => page.map((m) => m.toDomain()),
  );

  @override
  Future<void> saveProgress(String lessonId, int positionSeconds, bool isCompleted) =>
      _lessonsRemoteDataSource.saveProgress(lessonId, positionSeconds, isCompleted);
}
