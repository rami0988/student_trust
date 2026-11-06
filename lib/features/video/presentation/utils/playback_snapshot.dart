import 'package:flutter/foundation.dart';

/// The bits of the native player's state the custom controls draw. Copied
/// out of better_player's `VideoPlayerValue` so widgets don't depend on the
/// plugin's types and can be built in tests.
@immutable
class PlaybackSnapshot {
  final Duration position;
  final Duration duration;

  /// End of the buffered range that contains [position] (≥ [position]).
  final Duration bufferedEnd;
  final bool isPlaying;
  final bool isBuffering;

  const PlaybackSnapshot({
    this.position = Duration.zero,
    this.duration = Duration.zero,
    this.bufferedEnd = Duration.zero,
    this.isPlaying = false,
    this.isBuffering = false,
  });

  static const PlaybackSnapshot empty = PlaybackSnapshot();

  double get playedFraction => _fraction(position);
  double get bufferedFraction => _fraction(bufferedEnd);
  Duration get remaining => duration > position ? duration - position : Duration.zero;

  double _fraction(Duration d) {
    if (duration.inMilliseconds <= 0) return 0;
    return (d.inMilliseconds / duration.inMilliseconds).clamp(0.0, 1.0);
  }

  @override
  bool operator ==(Object other) =>
      other is PlaybackSnapshot &&
      other.position == position &&
      other.duration == duration &&
      other.bufferedEnd == bufferedEnd &&
      other.isPlaying == isPlaying &&
      other.isBuffering == isBuffering;

  @override
  int get hashCode => Object.hash(position, duration, bufferedEnd, isPlaying, isBuffering);
}
