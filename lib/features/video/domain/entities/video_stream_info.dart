import 'package:equatable/equatable.dart';

/// Resolved playback source for an online lesson.
class VideoStreamInfo extends Equatable {
  /// The URL the player should use.
  final String url;

  /// True when [url] is a BunnyCDN signed URL (production), false when it is
  /// the backend streaming endpoint (development).
  final bool isBunny;

  /// BunnyCDN thumbnail (production only), else null.
  final String? thumbnailUrl;

  /// ISO expiry of the signed URL (production only), else null.
  final String? expiresAt;

  /// Rendition [url] points at (e.g. "480p"), when the backend reports it.
  final String? resolution;

  /// Every encoded rendition → its signed URL (e.g. {"720p": …, "480p": …}),
  /// best first. Empty on older backends or when Bunny's status was unknown.
  final Map<String, String> renditions;

  const VideoStreamInfo({
    required this.url,
    required this.isBunny,
    this.thumbnailUrl,
    this.expiresAt,
    this.resolution,
    this.renditions = const {},
  });

  @override
  List<Object?> get props => [url, isBunny, thumbnailUrl, expiresAt, resolution, renditions];
}
