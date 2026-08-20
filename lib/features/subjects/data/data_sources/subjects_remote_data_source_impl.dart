import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/error_handler.dart';
import '../../../../core/models/pagination_model.dart';
import '../../../../core/models/paginated_result.dart';
import '../../../../core/network/endpoints.dart';
import '../models/subject_model.dart';
import 'subjects_remote_data_source.dart';

/// Raw-JSON backend (no envelope) — talks to [Dio] directly instead of
/// extending BaseRemoteDataSourceImpl. See auth feature's data source for
/// the full rationale.
///
/// The subjects list is paginated server-side (`{data, pagination}`) — see
/// studentController.getSubjects.
@LazySingleton(as: SubjectsRemoteDataSource)
class SubjectsRemoteDataSourceImpl implements SubjectsRemoteDataSource {
  final Dio _dio;

  SubjectsRemoteDataSourceImpl(this._dio);

  @override
  Future<PaginatedResult<SubjectModel>> getSubjects({int page = 1, int limit = 50}) async {
    try {
      final Response<Map<String, dynamic>> response = await _dio.get(
        Endpoints.subjects,
        queryParameters: {'page': page, 'limit': limit},
      );
      final List<dynamic> list = (response.data?['data'] as List<dynamic>?) ?? [];
      final List<SubjectModel> items = list.map((e) => SubjectModel.fromJson(e as Map<String, dynamic>)).toList();
      final Map<String, dynamic>? rawPagination = response.data?['pagination'] as Map<String, dynamic>?;
      final PaginationModel pagination = rawPagination != null
          ? PaginationModel.fromJson(rawPagination)
          : PaginationModel(page: page, limit: limit, total: items.length, totalPages: 1, hasNextPage: false, hasPrevPage: false);
      return PaginatedResult(items, pagination);
    } catch (error) {
      throw ErrorHandler.handleExceptionError(error);
    }
  }
}
