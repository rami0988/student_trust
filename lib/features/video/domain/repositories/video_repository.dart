import '../../../../core/repositories/base_repository.dart';
import '../../../../core/utils/request_result.dart';
import '../entities/video_stream_info.dart';

abstract class VideoRepository extends BaseRepository {
  /// Resolves how a lesson should be played online.
  ///
  /// [streamEndpoint] overrides the default lesson endpoint — used for
  /// worksheet solution videos (`/worksheets/videos/:id/stream`).
  Future<RequestResult<VideoStreamInfo>> resolveStream(String lessonId, {String? streamEndpoint});
}
