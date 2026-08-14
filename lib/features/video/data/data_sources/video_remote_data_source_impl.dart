import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/error_handler.dart';
import '../../../../core/network/endpoints.dart';
import '../models/video_stream_info_model.dart';
import 'video_remote_data_source.dart';

/// Raw-JSON backend (no envelope) — talks to [Dio] directly instead of
/// extending BaseRemoteDataSourceImpl. See auth feature's data source for
/// the full rationale.
@LazySingleton(as: VideoRemoteDataSource)
class VideoRemoteDataSourceImpl implements VideoRemoteDataSource {
  final Dio _dio;

  VideoRemoteDataSourceImpl(this._dio);

  /// Detection strategy: request a tiny range (`bytes=0-1`). The production
  /// backend ignores the range and returns JSON `{ mode: 'bunnycdn', directUrl,
  /// thumbnailUrl, expiresAt }`, while the development backend replies with a
  /// `206` video chunk. A `Map` with `mode == 'bunnycdn'` means BunnyCDN;
  /// anything else means the backend is streaming and we play the endpoint URL.
  @override
  Future<VideoStreamInfoModel> resolveStream(String lessonId, {String? streamEndpoint}) async {
    try {
      final String endpoint = streamEndpoint ?? Endpoints.videoStream(lessonId);
      final Response<dynamic> response = await _dio.get(
        endpoint,
        options: Options(
          responseType: ResponseType.json,
          headers: {'Range': 'bytes=0-1'},
          validateStatus: (status) => status != null && status < 400,
        ),
      );

      final dynamic data = response.data;
      if (data is Map && data['mode'] == 'bunnycdn' && data['directUrl'] != null) {
        // Production — play directly from BunnyCDN's signed URL.
        return VideoStreamInfoModel(
          url: data['directUrl'].toString(),
          isBunny: true,
          thumbnailUrl: data['thumbnailUrl']?.toString(),
          expiresAt: data['expiresAt']?.toString(),
        );
      }

      // Development — the player requests this URL with Range headers itself.
      return VideoStreamInfoModel(url: '${_dio.options.baseUrl}$endpoint', isBunny: false);
    } catch (error) {
      throw ErrorHandler.handleExceptionError(error);
    }
  }
}
