import '../../generated/l10n.dart';

final RegExp _grade11Pattern = RegExp(r'^(grade[\s_-]?)?11$');

/// Display name for a grade as the backend sends it — raw DB values (`tase3`, `grade11`, `bac`)
/// or API values (`grade9`). Null/empty means a shared subject. Anything not recognized as
/// bac or 11th grade is shown as 9th grade, matching the backend's own fallback.
String gradeLabel(String? raw) {
  final String v = (raw ?? '').trim().toLowerCase();
  if (v.isEmpty) return S.current.gradeGeneral;
  if (v.contains('bac') || v.contains('بكالوريا')) return S.current.gradeBac;
  if (_grade11Pattern.hasMatch(v) || v.contains('حادي عشر')) return S.current.gradeEleven;
  return S.current.gradeNine;
}
