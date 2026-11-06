import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_template/core/utils/spoken_duration.dart';
import 'package:mobile_template/generated/l10n.dart';

void main() {
  group('spokenDuration (Arabic plural forms)', () {
    late S s;
    setUpAll(() async => s = await S.load(const Locale('ar')));

    test('minutes and seconds under ten minutes', () {
      expect(spokenDuration(s, const Duration(minutes: 4, seconds: 50)), '4 دقائق و50 ثانية');
    });

    test('dual and singular forms', () {
      expect(spokenDuration(s, const Duration(minutes: 2)), 'دقيقتين');
      expect(spokenDuration(s, const Duration(minutes: 1, seconds: 1)), 'دقيقة واحدة وثانية واحدة');
      expect(spokenDuration(s, const Duration(seconds: 7)), '7 ثوانٍ');
    });

    test('rounds to whole minutes from ten minutes up', () {
      expect(spokenDuration(s, const Duration(minutes: 12, seconds: 5)), '12 دقيقة');
      expect(spokenDuration(s, const Duration(minutes: 26, seconds: 48)), '27 دقيقة');
    });

    test('adds hours past sixty minutes', () {
      expect(spokenDuration(s, const Duration(hours: 1, minutes: 7)), 'ساعة و7 دقائق');
    });

    test('uses the magnitude of negative durations (extra time when slower)', () {
      expect(spokenDuration(s, const Duration(minutes: -8, seconds: -3)), '8 دقائق و3 ثوانٍ');
    });

    test('shortDuration', () {
      expect(shortDuration(s, const Duration(hours: 2, minutes: 14)), '2 س 14 د');
      expect(shortDuration(s, const Duration(minutes: 32)), '32 د');
    });
  });

  group('spokenDuration (English)', () {
    test('joins with a space', () async {
      final S en = await S.load(const Locale('en'));
      expect(spokenDuration(en, const Duration(minutes: 4, seconds: 50)), '4 minutes 50 seconds');
      expect(spokenDuration(en, const Duration(seconds: 1)), '1 second');
    });
  });
}
