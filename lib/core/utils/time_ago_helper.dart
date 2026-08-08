import '../../generated/l10n.dart';

abstract class TimeAgoHelper {
  TimeAgoHelper._();

  static String format(DateTime dateTime) {
    final Duration diff = DateTime.now().difference(dateTime.toLocal());

    if (diff.inMinutes < 1) return S.current.timeAgoNow;
    if (diff.inHours < 1) return S.current.timeAgoMinutes(diff.inMinutes);
    if (diff.inDays < 1) return S.current.timeAgoHours(diff.inHours);
    if (diff.inDays < 30) return S.current.timeAgoDays(diff.inDays);

    final int months = diff.inDays ~/ 30;
    if (months < 12) return S.current.timeAgoMonths(months);

    return S.current.timeAgoYears(diff.inDays ~/ 365);
  }
}
