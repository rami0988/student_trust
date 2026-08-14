import '../../domain/entities/video_stream_info.dart';

class VideoStreamInfoModel {
  final String url;
  final bool isBunny;
  final String? thumbnailUrl;
  final String? expiresAt;

  VideoStreamInfoModel({required this.url, required this.isBunny, this.thumbnailUrl, this.expiresAt});

  VideoStreamInfo toDomain() => VideoStreamInfo(url: url, isBunny: isBunny, thumbnailUrl: thumbnailUrl, expiresAt: expiresAt);
}
