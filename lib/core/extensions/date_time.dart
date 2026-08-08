import 'package:intl/intl.dart';

/// Extension methods for [DateTime] to provide convenient date and time formatting.
///
/// This extension provides various formatting methods that support localization,
/// with English as the default locale. All methods convert the DateTime to local
/// time before formatting.
///
/// Example:
/// ```dart
/// final now = DateTime.now();
/// print(now.formatDate()); // "Jan 21, 2026"
/// print(now.formatDate('ar')); // "٢١ يناير ٢٠٢٦"
/// print(now.formatTime()); // "3:45 PM"
/// ```
extension DateTimeExtension on DateTime {
  /// Formats date in a human-readable format with abbreviated month name.
  ///
  /// Returns a string in the format "MMM d, y" (e.g., "Jan 15, 2023" in English
  /// or "١٥ يناير ٢٠٢٣" in Arabic).
  ///
  /// Parameters:
  /// - [locale]: Optional locale string (defaults to 'en' for English).
  ///
  /// Example:
  /// ```dart
  /// DateTime.now().formatDate(); // "Jan 21, 2026"
  /// DateTime.now().formatDate('ar'); // "٢١ يناير ٢٠٢٦"
  /// ```
  String formatDate([String? locale]) => DateFormat('MMM d, y', locale ?? 'en').format(toLocal());

  /// Formats date showing only day and year without month name.
  ///
  /// Returns a string in the format "d, y" (e.g., "21, 2026" in English
  /// or "٢١, ٢٠٢٦" in Arabic).
  ///
  /// Parameters:
  /// - [locale]: Optional locale string (defaults to 'en' for English).
  ///
  /// Example:
  /// ```dart
  /// DateTime.now().formatYearDay(); // "21, 2026"
  /// ```
  String formatYearDay([String? locale]) => DateFormat('d, y', locale ?? 'en').format(toLocal());

  /// Formats date to show only the abbreviated month name.
  ///
  /// Returns a string in the format "MMM" (e.g., "Jan" in English or "يناير" in Arabic).
  ///
  /// Parameters:
  /// - [locale]: Optional locale string (defaults to 'en' for English).
  ///
  /// Example:
  /// ```dart
  /// DateTime.now().formatMonth(); // "Jan"
  /// DateTime.now().formatMonth('ar'); // "يناير"
  /// ```
  String formatMonth([String? locale]) => DateFormat('MMM', locale ?? 'en').format(toLocal());

  /// Formats date to show only the day of the month.
  ///
  /// Returns a string in the format "d" (e.g., "21" in English or "٢١" in Arabic).
  ///
  /// Parameters:
  /// - [locale]: Optional locale string (defaults to 'en' for English).
  ///
  /// Example:
  /// ```dart
  /// DateTime(2024, 10, 6).formatDay(); // "6"
  /// DateTime(2024, 10, 21).formatDay('ar'); // "٢١"
  /// ```
  String formatDay([String? locale]) => DateFormat('d', locale ?? 'en').format(toLocal());

  /// Formats date to show only the year.
  ///
  /// Returns a string in the format "y" (e.g., "2026" in English or "٢٠٢٦" in Arabic).
  ///
  /// Parameters:
  /// - [locale]: Optional locale string (defaults to 'en' for English).
  ///
  /// Example:
  /// ```dart
  /// DateTime.now().formatYear(); // "2026"
  /// DateTime.now().formatYear('ar'); // "٢٠٢٦"
  /// ```
  String formatYear([String? locale]) => DateFormat('y', locale ?? 'en').format(toLocal());

  /// Formats date showing day and abbreviated month name.
  ///
  /// Returns a string in the format "d MMM" (e.g., "21 Jan" in English
  /// or "٢١ يناير" in Arabic).
  ///
  /// Parameters:
  /// - [locale]: Optional locale string (defaults to 'en' for English).
  ///
  /// Example:
  /// ```dart
  /// DateTime.now().formatMonthDate(); // "21 Jan"
  /// DateTime.now().formatMonthDate('ar'); // "٢١ يناير"
  /// ```
  String formatMonthDate([String? locale]) => DateFormat('d MMM', locale ?? 'en').format(toLocal());

  /// Formats date in day/month/year format with slash separators.
  ///
  /// Returns a string in the format "d / M / yyyy" (e.g., "6 / 10 / 2024" in English
  /// or "٦ / ١٠ / ٢٠٢٤" in Arabic).
  ///
  /// Parameters:
  /// - [locale]: Optional locale string (defaults to 'en' for English).
  ///
  /// Example:
  /// ```dart
  /// DateTime(2024, 10, 6).formatDayMonthYear(); // "6 / 10 / 2024"
  /// DateTime(2024, 10, 6).formatDayMonthYear('ar'); // "٦ / ١٠ / ٢٠٢٤"
  /// ```
  String formatDayMonthYear([String? locale]) => DateFormat('d / M / yyyy', locale ?? 'en').format(toLocal());

  /// Formats date in month/day/year format with slash separators.
  ///
  /// Returns a string in the format "M / d / yyyy" (e.g., "10 / 6 / 2024" in English
  /// or "١٠ / ٦ / ٢٠٢٤" in Arabic). This format is commonly used in the United States.
  ///
  /// Parameters:
  /// - [locale]: Optional locale string (defaults to 'en' for English).
  ///
  /// Example:
  /// ```dart
  /// DateTime(2024, 10, 6).formatMonthDayYear(); // "10 / 6 / 2024"
  /// DateTime(2024, 10, 6).formatMonthDayYear('ar'); // "١٠ / ٦ / ٢٠٢٤"
  /// ```
  String formatMonthDayYear([String? locale]) => DateFormat('M / d / yyyy', locale ?? 'en').format(toLocal());

  /// Formats date in year/month/day format with slash separators and zero-padding.
  ///
  /// Returns a string in the format "yyyy/MM/dd" (e.g., "2024/10/06" in English
  /// or "٢٠٢٤/١٠/٠٦" in Arabic). This format is commonly used in East Asian countries
  /// and provides consistent width with zero-padded values.
  ///
  /// Parameters:
  /// - [locale]: Optional locale string (defaults to 'en' for English).
  ///
  /// Example:
  /// ```dart
  /// DateTime(2024, 10, 6).formatYearMonthDay(); // "2024/10/06"
  /// DateTime(2024, 10, 6).formatYearMonthDay('ar'); // "٢٠٢٤/١٠/٠٦"
  /// ```
  String formatYearMonthDay([String? locale]) => DateFormat('yyyy/MM/dd', locale ?? 'en').format(toLocal());

  /// Formats date in ISO 8601 date format.
  ///
  /// Returns a string in the format "yyyy-MM-dd" (e.g., "2024-10-06" in English
  /// or "٢٠٢٤-١٠-٠٦" in Arabic). This is the standard ISO 8601 date format,
  /// useful for APIs and data storage.
  ///
  /// Parameters:
  /// - [locale]: Optional locale string (defaults to 'en' for English).
  ///
  /// Example:
  /// ```dart
  /// DateTime(2024, 10, 6).formatISODate(); // "2024-10-06"
  /// DateTime(2024, 10, 6).formatISODate('ar'); // "٢٠٢٤-١٠-٠٦"
  /// ```
  String formatISODate([String? locale]) => DateFormat('yyyy-MM-dd', locale ?? 'en').format(toLocal());

  /// Formats time in 12-hour format with AM/PM indicator.
  ///
  /// Returns a string in the format "hh:mm a" (e.g., "3:45 PM" in English
  /// or "٣:٤٥ م" in Arabic).
  ///
  /// Parameters:
  /// - [locale]: Optional locale string (defaults to 'en' for English).
  ///
  /// Example:
  /// ```dart
  /// DateTime.now().formatTime(); // "3:45 PM"
  /// DateTime.now().formatTime('ar'); // "٣:٤٥ م"
  /// ```
  String formatTime([String? locale]) => DateFormat('hh:mm a', locale ?? 'en').format(toLocal());

  /// Formats time in 12-hour format without AM/PM indicator.
  ///
  /// Returns a string in the format "hh:mm" (e.g., "03:45" in English
  /// or "٠٣:٤٥" in Arabic). Note that this does not indicate whether
  /// the time is AM or PM.
  ///
  /// Parameters:
  /// - [locale]: Optional locale string (defaults to 'en' for English).
  ///
  /// Example:
  /// ```dart
  /// DateTime.now().formatHourWithoutTime(); // "03:45"
  /// DateTime.now().formatHourWithoutTime('ar'); // "٠٣:٤٥"
  /// ```
  String formatHourWithoutTime([String? locale]) => DateFormat('hh:mm', locale ?? 'en').format(toLocal());

  /// Formats time to return only the AM/PM period indicator.
  ///
  /// Returns a string in the format "a" (e.g., "PM" in English
  /// or "م" in Arabic). This returns only the period marker without
  /// the time itself.
  ///
  /// Parameters:
  /// - [locale]: Optional locale string (defaults to 'en' for English).
  ///
  /// Example:
  /// ```dart
  /// DateTime(2024, 1, 1, 15, 45).formatAmPM(); // "PM"
  /// DateTime(2024, 1, 1, 15, 45).formatAmPM('ar'); // "م"
  /// DateTime(2024, 1, 1, 9, 30).formatAmPM(); // "AM"
  /// ```
  String formatAmPM([String? locale]) => DateFormat('a', locale ?? 'en').format(toLocal());

  /// Formats time in 24-hour format.
  ///
  /// Returns a string in the format "HH:mm" (e.g., "15:45" in English
  /// or "١٥:٤٥" in Arabic). This format is commonly used in military time
  /// and international contexts.
  ///
  /// Parameters:
  /// - [locale]: Optional locale string (defaults to 'en' for English).
  ///
  /// Example:
  /// ```dart
  /// DateTime.now().formatTime24(); // "15:45"
  /// DateTime.now().formatTime24('ar'); // "١٥:٤٥"
  /// ```
  String formatTime24([String? locale]) => DateFormat('HH:mm', locale ?? 'en').format(toLocal());
}
