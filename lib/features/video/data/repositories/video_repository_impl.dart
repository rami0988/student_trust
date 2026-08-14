import 'package:injectable/injectable.dart';

import '../../../../core/repositories/base_repository_impl.dart';
import '../../../../core/utils/request_result.dart';
import '../../domain/entities/video_stream_info.dart';
import '../../domain/repositories/video_repository.dart';
import '../data_sources/video_remote_data_source.dart';
import '../models/video_stream_info_model.dart';

@LazySingleton(as: VideoRepository)
class VideoRepositoryImpl extends BaseRepositoryImpl implements VideoRepository {
  final VideoRemoteDataSource _videoRemoteDataSource;

  VideoRepositoryImpl(this._videoRemoteDataSource) : super('VideoRepository');

  @override
  Future<RequestResult<VideoStreamInfo>> resolveStream(String lessonId, {String? streamEndpoint}) => execute(
    () => _videoRemoteDataSource.resolveStream(lessonId, streamEndpoint: streamEndpoint),
    converter: (VideoStreamInfoModel model) => model.toDomain(),
  );
}
