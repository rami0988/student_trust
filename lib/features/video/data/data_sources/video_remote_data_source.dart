import '../models/video_stream_info_model.dart';

abstract class VideoRemoteDataSource {
  Future<VideoStreamInfoModel> resolveStream(String lessonId, {String? streamEndpoint});
}
