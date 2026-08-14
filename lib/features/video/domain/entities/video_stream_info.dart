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

  const VideoStreamInfo({required this.url, required this.isBunny, this.thumbnailUrl, this.expiresAt});

  @override
  List<Object?> get props => [url, isBunny, thumbnailUrl, expiresAt];
}
