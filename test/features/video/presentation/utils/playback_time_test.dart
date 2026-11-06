import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_template/features/video/presentation/utils/playback_snapshot.dart';
import 'package:mobile_template/features/video/presentation/utils/playback_time.dart';

void main() {
  const Duration lesson = Duration(minutes: 24, seconds: 10); // 1450s

  group('PlaybackTime', () {
    test('at 1.25× a 24:10 lesson takes 19:20 and saves 4:50', () {
      expect(PlaybackTime.atSpeed(lesson, 1.25), const Duration(minutes: 19, seconds: 20));
      expect(PlaybackTime.saved(lesson, 1.25), const Duration(minutes: 4, seconds: 50));
    });

    test('at 2× half the time is saved', () {
      expect(PlaybackTime.saved(lesson, 2), const Duration(minutes: 12, seconds: 5));
    });

    test('slower speeds give a negative saving (extra time)', () {
      expect(PlaybackTime.saved(lesson, 0.75).isNegative, isTrue);
      expect(PlaybackTime.atSpeed(lesson, 0.75).inSeconds, 1933);
    });

    test('normal speed saves nothing; a bad speed is treated as normal', () {
      expect(PlaybackTime.saved(lesson, 1), Duration.zero);
      expect(PlaybackTime.atSpeed(lesson, 0), lesson);
    });

    test('effectOf classifies speeds', () {
      expect(PlaybackTime.effectOf(1.5), SpeedEffect.faster);
      expect(PlaybackTime.effectOf(1), SpeedEffect.normal);
      expect(PlaybackTime.effectOf(0.75), SpeedEffect.slower);
    });

    test('speedLabel drops trailing zeros', () {
      expect(PlaybackTime.speedLabel(1), '1×');
      expect(PlaybackTime.speedLabel(2.0), '2×');
      expect(PlaybackTime.speedLabel(1.25), '1.25×');
      expect(PlaybackTime.speedLabel(0.75), '0.75×');
    });

    test('speedLabelInText isolates the label so "×" stays after the number in Arabic', () {
      final String label = PlaybackTime.speedLabelInText(1.25);
      expect(label.codeUnits.first, 0x2066); // LEFT-TO-RIGHT ISOLATE
      expect(label.codeUnits.last, 0x2069); // POP DIRECTIONAL ISOLATE
      expect(label.substring(1, label.length - 1), '1.25×');
    });

    test('offers 0.75× to 2× and suggests a speed it offers', () {
      expect(PlaybackTime.speeds, [0.75, 1.0, 1.25, 1.5, 2.0]);
      expect(PlaybackTime.speeds, contains(PlaybackTime.suggestedSpeed));
    });
  });

  group('PlaybackSnapshot', () {
    test('fractions and remaining time', () {
      const PlaybackSnapshot snap = PlaybackSnapshot(
        position: Duration(seconds: 25),
        duration: Duration(seconds: 100),
        bufferedEnd: Duration(seconds: 40),
      );
      expect(snap.playedFraction, 0.25);
      expect(snap.bufferedFraction, 0.4);
      expect(snap.remaining, const Duration(seconds: 75));
    });

    test('unknown duration gives zero fractions, never NaN', () {
      const PlaybackSnapshot snap = PlaybackSnapshot(position: Duration(seconds: 5));
      expect(snap.playedFraction, 0);
      expect(snap.remaining, Duration.zero);
    });
  });
}
