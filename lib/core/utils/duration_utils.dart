/// Helpers for formatting video durations / progress. Shared across the
/// lessons and video features.
abstract class DurationUtils {
  DurationUtils._();

  /// Formats [seconds] as `mm:ss` or `h:mm:ss`.
  static String format(int seconds) {
    final Duration d = Duration(seconds: seconds);
    final int h = d.inHours;
    final int m = d.inMinutes.remainder(60);
    final int s = d.inSeconds.remainder(60);
    String two(int n) => n.toString().padLeft(2, '0');
    if (h > 0) {
      return '$h:${two(m)}:${two(s)}';
    }
    return '${two(m)}:${two(s)}';
  }

  /// Returns playback progress in the range 0.0–1.0.
  static double ratio(int positionSeconds, int totalSeconds) {
    if (totalSeconds <= 0) return 0;
    final double r = positionSeconds / totalSeconds;
    if (r.isNaN || r.isInfinite) return 0;
    return r.clamp(0.0, 1.0);
  }
}
