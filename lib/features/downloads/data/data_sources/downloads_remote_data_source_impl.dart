import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/error_handler.dart';
import '../../../../core/network/endpoints.dart';
import 'downloads_remote_data_source.dart';

/// Raw-JSON backend (no envelope) — talks to [Dio] directly instead of
/// extending BaseRemoteDataSourceImpl. See auth feature's data source for
/// the full rationale.
@LazySingleton(as: DownloadsRemoteDataSource)
class DownloadsRemoteDataSourceImpl implements DownloadsRemoteDataSource {
  final Dio _dio;

  DownloadsRemoteDataSourceImpl(this._dio);

  @override
  Future<void> registerDownload({required String lessonId, required String deviceUuid, required int chunkCount}) async {
    try {
      await _dio.post(
        Endpoints.registerDownload,
        data: {'lessonId': lessonId, 'deviceUuid': deviceUuid, 'chunkCount': chunkCount},
      );
    } catch (error) {
      throw ErrorHandler.handleExceptionError(error);
    }
  }

  @override
  Future<bool> validateDownload(String lessonId) async {
    try {
      final Response<dynamic> response = await _dio.get(Endpoints.validateDownload(lessonId));
      final dynamic data = response.data;
      if (data is Map && data.containsKey('isValid')) {
        return data['isValid'] == true;
      }
      return response.statusCode == 200;
    } catch (error) {
      throw ErrorHandler.handleExceptionError(error);
    }
  }
}
