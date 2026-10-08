import 'package:flutter/widgets.dart';

import '../../../../generated/l10n.dart';
import '../../domain/entities/download_item.dart';

/// Formatting for the live download figures (sizes, speed, time left).
abstract class DownloadProgressFormat {
  DownloadProgressFormat._();

  /// "340 MB", "1.2 GB" — whole numbers from 10 up, one decimal below.
  static String bytes(int bytes) {
    if (bytes <= 0) return '0 MB';
    const List<String> units = ['B', 'KB', 'MB', 'GB'];
    double value = bytes.toDouble();
    int unit = 0;
    while (value >= 1024 && unit < units.length - 1) {
      value /= 1024;
      unit++;
    }
    return '${value.toStringAsFixed(value >= 10 || unit == 0 ? 0 : 1)} ${units[unit]}';
  }

  /// "4:05" / "1:02:30" style remaining time.
  static String duration(Duration d) {
    final int h = d.inHours;
    final String m = (d.inMinutes % 60).toString().padLeft(h > 0 ? 2 : 1, '0');
    final String s = (d.inSeconds % 60).toString().padLeft(2, '0');
    return h > 0 ? '$h:$m:$s' : '$m:$s';
  }

  /// One line describing a download in flight, e.g.
  /// "12 MB / 340 MB · 1.2 MB/s · 4:05 left". Parts that aren't known yet are
  /// left out rather than shown as zero.
  static String detail(BuildContext context, DownloadItem item) {
    final S s = S.of(context);
    if (item.status == DownloadItemStatus.waitingForNetwork) return s.waitingForNetwork;
    final List<String> parts = [];
    if (item.totalBytes > 0) {
      parts.add('${bytes(item.bytesReceived)} / ${bytes(item.totalBytes)}');
    }
    if (item.status == DownloadItemStatus.downloading && item.speedBytesPerSecond > 0) {
      parts.add('${bytes(item.speedBytesPerSecond.round())}${s.perSecond}');
    }
    final Duration? left = item.remaining;
    if (left != null) parts.add(s.timeLeft(duration(left)));
    return parts.join(' · ');
  }
}
