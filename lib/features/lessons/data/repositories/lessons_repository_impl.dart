import 'package:injectable/injectable.dart';

import '../../../../core/repositories/base_repository_impl.dart';
import '../../../../core/utils/request_result.dart';
import '../../domain/entities/lesson.dart';
import '../../domain/repositories/lessons_repository.dart';
import '../data_sources/lessons_remote_data_source.dart';
import '../models/lesson_model.dart';

@LazySingleton(as: LessonsRepository)
class LessonsRepositoryImpl extends BaseRepositoryImpl implements LessonsRepository {
  final LessonsRemoteDataSource _lessonsRemoteDataSource;

  LessonsRepositoryImpl(this._lessonsRemoteDataSource) : super('LessonsRepository');

  @override
  Future<RequestResult<List<Lesson>>> getLessons(String chapterId) => execute(
    () => _lessonsRemoteDataSource.getLessons(chapterId),
    converter: (List<LessonModel> models) => models.map((m) => m.toDomain()).toList(),
  );

  @override
  Future<void> saveProgress(String lessonId, int positionSeconds, bool isCompleted) =>
      _lessonsRemoteDataSource.saveProgress(lessonId, positionSeconds, isCompleted);
}
