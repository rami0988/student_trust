import '../../domain/entities/video_stream_info.dart';

class VideoStreamInfoModel {
  final String url;
  final bool isBunny;
  final String? thumbnailUrl;
  final String? expiresAt;
  final String? resolution;
  final Map<String, String> renditions;

  VideoStreamInfoModel({
    required this.url,
    required this.isBunny,
    this.thumbnailUrl,
    this.expiresAt,
    this.resolution,
    this.renditions = const {},
  });

  /// Reads the backend's `renditions` map, skipping anything malformed.
  static Map<String, String> parseRenditions(dynamic raw) {
    if (raw is! Map) return const {};
    final Map<String, String> out = {};
    raw.forEach((key, value) {
      if (key != null && value is String && value.isNotEmpty) out[key.toString()] = value;
    });
    return out;
  }

  VideoStreamInfo toDomain() => VideoStreamInfo(
    url: url,
    isBunny: isBunny,
    thumbnailUrl: thumbnailUrl,
    expiresAt: expiresAt,
    resolution: resolution,
    renditions: renditions,
  );
}
