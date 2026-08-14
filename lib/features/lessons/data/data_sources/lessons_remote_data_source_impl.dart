import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/error_handler.dart';
import '../../../../core/network/endpoints.dart';
import '../models/lesson_model.dart';
import 'lessons_remote_data_source.dart';

/// Raw-JSON backend (no envelope) — talks to [Dio] directly instead of
/// extending BaseRemoteDataSourceImpl. See auth feature's data source for
/// the full rationale.
@LazySingleton(as: LessonsRemoteDataSource)
class LessonsRemoteDataSourceImpl implements LessonsRemoteDataSource {
  final Dio _dio;

  LessonsRemoteDataSourceImpl(this._dio);

  @override
  Future<List<LessonModel>> getLessons(String chapterId) async {
    try {
      final Response<List<dynamic>> response = await _dio.get(Endpoints.lessons(chapterId));
      final List<dynamic> list = response.data ?? [];
      return list.map((e) => LessonModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (error) {
      throw ErrorHandler.handleExceptionError(error);
    }
  }

  @override
  Future<void> saveProgress(String lessonId, int positionSeconds, bool isCompleted) async {
    try {
      await _dio.post(
        Endpoints.progress,
        data: {'lessonId': lessonId, 'positionSeconds': positionSeconds, 'isCompleted': isCompleted},
      );
    } catch (error) {
      throw ErrorHandler.handleExceptionError(error);
    }
  }
}
