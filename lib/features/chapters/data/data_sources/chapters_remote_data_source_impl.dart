import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/error_handler.dart';
import '../../../../core/network/endpoints.dart';
import '../models/chapter_model.dart';
import 'chapters_remote_data_source.dart';

/// Raw-JSON backend (no envelope) — talks to [Dio] directly instead of
/// extending BaseRemoteDataSourceImpl. See auth feature's data source for
/// the full rationale.
@LazySingleton(as: ChaptersRemoteDataSource)
class ChaptersRemoteDataSourceImpl implements ChaptersRemoteDataSource {
  final Dio _dio;

  ChaptersRemoteDataSourceImpl(this._dio);

  @override
  Future<List<ChapterModel>> getChapters(String subjectId) async {
    try {
      final Response<List<dynamic>> response = await _dio.get(Endpoints.chapters(subjectId));
      final List<dynamic> list = response.data ?? [];
      return list.map((e) => ChapterModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (error) {
      throw ErrorHandler.handleExceptionError(error);
    }
  }
}
