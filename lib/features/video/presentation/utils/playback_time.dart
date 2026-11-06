/// How a playback speed changes a lesson's watch time. Pure arithmetic, kept
/// apart from widgets so it can be unit tested.
enum SpeedEffect { faster, normal, slower }

class PlaybackTime {
  PlaybackTime._();

  /// Speeds offered in the speed picker (better_player caps speed at 2.0).
  static const List<double> speeds = [0.75, 1.0, 1.25, 1.5, 2.0];

  /// The speed suggested to a student watching at normal speed.
  static const double suggestedSpeed = 1.25;

  /// Wall-clock time needed to watch [content] at [speed].
  static Duration atSpeed(Duration content, double speed) {
    if (speed <= 0) return content;
    return Duration(microseconds: (content.inMicroseconds / speed).round());
  }

  /// Time saved by watching [content] at [speed]; negative when slower.
  static Duration saved(Duration content, double speed) => content - atSpeed(content, speed);

  static SpeedEffect effectOf(double speed) {
    if (speed > 1) return SpeedEffect.faster;
    if (speed < 1) return SpeedEffect.slower;
    return SpeedEffect.normal;
  }

  /// "0.75×", "1×", "1.5×" — trailing zeros dropped.
  static String speedLabel(double speed) {
    final String number = speed == speed.roundToDouble() ? speed.toStringAsFixed(0) : speed.toString();
    return '$number×';
  }

  /// [speedLabel] wrapped in Unicode left-to-right isolates, for placing
  /// inside a sentence. Without them the neutral "×" follows the Arabic
  /// sentence direction and renders before the number ("×1.25").
  static String speedLabelInText(double speed) => '$_lri${speedLabel(speed)}$_pdi';

  static final String _lri = String.fromCharCode(0x2066); // LEFT-TO-RIGHT ISOLATE
  static final String _pdi = String.fromCharCode(0x2069); // POP DIRECTIONAL ISOLATE
}
