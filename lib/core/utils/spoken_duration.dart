import '../../generated/l10n.dart';

/// A duration as words ("4 دقائق و50 ثانية"), with correct Arabic plural
/// forms from the ARB plural rules.
///
/// Under 10 minutes it gives minutes and seconds; from 10 minutes it rounds
/// to whole minutes (and hours), where seconds stop being useful.
String spokenDuration(S s, Duration duration) {
  final int total = duration.inSeconds.abs();
  final List<String> parts = [];
  if (total >= 600) {
    int minutes = (total / 60).round();
    final int hours = minutes ~/ 60;
    minutes %= 60;
    if (hours > 0) parts.add(s.durationHours(hours));
    if (minutes > 0) parts.add(s.durationMinutes(minutes));
  } else {
    final int minutes = total ~/ 60;
    final int seconds = total % 60;
    if (minutes > 0) parts.add(s.durationMinutes(minutes));
    if (seconds > 0 || minutes == 0) parts.add(s.durationSeconds(seconds));
  }
  return parts.reduce((a, b) => s.durationJoin(a, b));
}

/// Short form for cards and hero stats: "2 س 14 د" / "32 د".
String shortDuration(S s, Duration duration) {
  final int minutes = (duration.inSeconds / 60).round();
  if (minutes >= 60) return s.hoursMinutesShort(minutes ~/ 60, minutes % 60);
  return s.minutesShort(minutes);
}
