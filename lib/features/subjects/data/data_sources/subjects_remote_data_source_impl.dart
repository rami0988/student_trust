import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/error_handler.dart';
import '../../../../core/network/endpoints.dart';
import '../models/subject_model.dart';
import 'subjects_remote_data_source.dart';

/// Raw-JSON backend (no envelope) — talks to [Dio] directly instead of
/// extending BaseRemoteDataSourceImpl. See auth feature's data source for
/// the full rationale.
@LazySingleton(as: SubjectsRemoteDataSource)
class SubjectsRemoteDataSourceImpl implements SubjectsRemoteDataSource {
  final Dio _dio;

  SubjectsRemoteDataSourceImpl(this._dio);

  @override
  Future<List<SubjectModel>> getSubjects() async {
    try {
      final Response<List<dynamic>> response = await _dio.get(Endpoints.subjects);
      final List<dynamic> list = response.data ?? [];
      return list.map((e) => SubjectModel.fromJson(e as Map<String, dynamic>)).toList();
    } catch (error) {
      throw ErrorHandler.handleExceptionError(error);
    }
  }
}
