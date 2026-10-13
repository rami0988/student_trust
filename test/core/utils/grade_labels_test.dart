import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_template/core/utils/grade_labels.dart';
import 'package:mobile_template/generated/l10n.dart';

void main() {
  setUpAll(() async {
    TestWidgetsFlutterBinding.ensureInitialized();
    await S.load(const Locale('ar'));
  });

  test('raw DB and API grade codes get readable labels, never the raw code', () {
    expect(gradeLabel('tase3'), 'الصف التاسع');
    expect(gradeLabel('grade9'), 'الصف التاسع');
    expect(gradeLabel('grade11'), 'الصف الحادي عشر');
    expect(gradeLabel('bac'), 'بكالوريا');
  });

  test('null or empty grade is a shared subject', () {
    expect(gradeLabel(null), 'عام');
    expect(gradeLabel('  '), 'عام');
  });

  test('11th grade is never shown as 9th grade', () {
    for (final v in ['GRADE11', 'grade_11', '11', 'الحادي عشر']) {
      expect(gradeLabel(v), 'الصف الحادي عشر', reason: v);
    }
    expect(gradeLabel('111'), 'الصف التاسع');
  });
}
