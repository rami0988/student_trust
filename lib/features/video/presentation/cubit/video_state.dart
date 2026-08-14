import 'package:built_value/built_value.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/app_enums.dart';

part 'video_state.g.dart';

abstract class VideoState implements Built<VideoState, VideoStateBuilder> {
  Status get status;
  Failure? get failure;

  String? get videoUrl;
  bool get isLocal;

  /// For online (dev streaming) sources we attach the bearer token so the
  /// player can authenticate its Range requests. Null for BunnyCDN / local.
  String? get authToken;
  int get savedPosition;

  /// BunnyCDN thumbnail + signed-URL expiry (production online only).
  String? get thumbnailUrl;
  String? get expiresAt;

  /// The video exists but BunnyCDN hasn't finished transcoding it — shown as
  /// a friendly "processing, try again shortly" screen with a retry, distinct
  /// from [Status.failure].
  bool get isProcessing;

  /// Native screen-recording detection fired; playback is paused behind a
  /// full-screen warning until it stops.
  bool get isRecordingDetected;

  VideoState._();
  factory VideoState([void Function(VideoStateBuilder) updates]) = _$VideoState;

  factory VideoState.initial() => VideoState(
    (b) => b
      ..status = Status.initial
      ..failure = null
      ..videoUrl = null
      ..isLocal = false
      ..authToken = null
      ..savedPosition = 0
      ..thumbnailUrl = null
      ..expiresAt = null
      ..isProcessing = false
      ..isRecordingDetected = false,
  );

  bool get isReady => status.isSuccess && videoUrl != null;
}
