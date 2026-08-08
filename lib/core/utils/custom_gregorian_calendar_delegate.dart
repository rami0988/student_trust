import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

class CustomGregorianCalendarDelegate extends CalendarDelegate<DateTime> {
  CustomGregorianCalendarDelegate();

  late final MaterialLocalizations englishMaterialLocalizations;

  Future<void> call() async {
    englishMaterialLocalizations = await GlobalMaterialLocalizations.delegate.load(
      const Locale('en'),
    );
  }

  /// Converts Arabic-Indic (and Extended Arabic-Indic) digits to Western
  /// Arabic numerals (0–9), leaving all other characters (letters, spaces,
  /// punctuation) untouched so that locale-specific text is preserved.
  String _toWesternDigits(String input) {
    return input.replaceAllMapped(RegExp(r'[\u0660-\u0669\u06F0-\u06F9]'), (m) {
      final int codeUnit = m[0]!.codeUnitAt(0);
      // Arabic-Indic: U+0660–U+0669
      if (codeUnit >= 0x0660 && codeUnit <= 0x0669) {
        return String.fromCharCode(codeUnit - 0x0660 + 0x30);
      }
      // Extended Arabic-Indic (Urdu/Farsi): U+06F0–U+06F9
      return String.fromCharCode(codeUnit - 0x06F0 + 0x30);
    });
  }

  @override
  DateTime now() => DateTime.now();

  @override
  DateTime dateOnly(DateTime date) => DateUtils.dateOnly(date);

  @override
  int monthDelta(DateTime startDate, DateTime endDate) => DateUtils.monthDelta(startDate, endDate);

  @override
  DateTime addMonthsToMonthDate(DateTime monthDate, int monthsToAdd) {
    return DateUtils.addMonthsToMonthDate(monthDate, monthsToAdd);
  }

  @override
  DateTime addDaysToDate(DateTime date, int days) => DateUtils.addDaysToDate(date, days);

  @override
  int firstDayOffset(int year, int month, MaterialLocalizations localizations) {
    return DateUtils.firstDayOffset(year, month, localizations);
  }

  @override
  int getDaysInMonth(int year, int month) => DateUtils.getDaysInMonth(year, month);

  @override
  DateTime getMonth(int year, int month) => DateTime(year, month);

  @override
  DateTime getDay(int year, int month, int day) => DateTime(year, month, day);

  /// Month + year header (e.g. "فبراير ٢٠٢٦" → "فبراير 2026").
  @override
  String formatMonthYear(DateTime date, MaterialLocalizations localizations) {
    return _toWesternDigits(localizations.formatMonthYear(date));
  }

  /// Medium date shown in the dialog header (e.g. "الأربعاء، ٢٥ فبراير" →
  /// "الأربعاء، 25 فبراير").
  @override
  String formatMediumDate(DateTime date, MaterialLocalizations localizations) {
    return _toWesternDigits(localizations.formatMediumDate(date));
  }

  /// Short month + day (e.g. "فبراير ٢٥" → "فبراير 25").
  @override
  String formatShortMonthDay(
    DateTime date,
    MaterialLocalizations localizations,
  ) {
    return _toWesternDigits(localizations.formatShortMonthDay(date));
  }

  /// Short date string (e.g. "٢٥/٢/٢٠٢٦" → "25/2/2026").
  @override
  String formatShortDate(DateTime date, MaterialLocalizations localizations) {
    return _toWesternDigits(localizations.formatShortDate(date));
  }

  /// Full date string (e.g. "الأربعاء، ٢٥ فبراير ٢٠٢٦" →
  /// "الأربعاء، 25 فبراير 2026").
  @override
  String formatFullDate(DateTime date, MaterialLocalizations localizations) {
    return _toWesternDigits(localizations.formatFullDate(date));
  }

  /// Year shown in the year-picker grid (e.g. "٢٠٢٦" → "2026").
  @override
  String formatYear(int year, MaterialLocalizations localizations) {
    return _toWesternDigits(localizations.formatYear(DateTime(year)));
  }

  /// Compact date used by the text-input mode; always English so parsing works.
  @override
  String formatCompactDate(DateTime date, MaterialLocalizations localizations) {
    return englishMaterialLocalizations.formatCompactDate(date);
  }

  @override
  DateTime? parseCompactDate(
    String? inputString,
    MaterialLocalizations localizations,
  ) {
    final DateTime? dateTime = englishMaterialLocalizations.parseCompactDate(
      inputString,
    );
    return dateTime;
  }

  @override
  String dateHelpText(MaterialLocalizations localizations) {
    return localizations.dateHelpText;
  }
}
