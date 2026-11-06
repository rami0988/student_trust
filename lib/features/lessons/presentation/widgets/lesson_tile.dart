import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/endpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/duration_utils.dart';
import '../../../../core/widgets/app_motion.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../generated/l10n.dart';
import '../../../downloads/domain/entities/download_item.dart';
import '../../../downloads/presentation/cubit/download_cubit.dart';
import '../../../downloads/presentation/cubit/download_state.dart';
import '../../../downloads/presentation/widgets/download_button.dart';
import '../../domain/entities/lesson.dart';

/// One lesson in the list: numbered thumbnail with duration and watch
/// progress, title, two-line description, a status line (completed /
/// time left / new / download state) and the download control.
class LessonTile extends StatelessWidget {
  final Lesson lesson;

  /// 1-based position in the chapter, drawn on the thumbnail.
  final int number;
  final bool isDownloaded;

  /// The lesson the chapter hero would resume — outlined.
  final bool isActive;
  final VoidCallback onPlayOnline;
  final VoidCallback onPlayOffline;

  const LessonTile({
    super.key,
    required this.lesson,
    required this.number,
    required this.isDownloaded,
    required this.onPlayOnline,
    required this.onPlayOffline,
    this.isActive = false,
  });

  @override
  Widget build(BuildContext context) {
    final double ratio = DurationUtils.ratio(lesson.progress.positionSeconds, lesson.durationSeconds);
    final VoidCallback onPlay = isDownloaded ? onPlayOffline : onPlayOnline;

    return AnimatedContainer(
      duration: AppTokens.dMed,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppTokens.radiusLG,
        border: Border.all(color: isActive ? AppColors.primary.withValues(alpha: 0.45) : AppColors.divider),
        boxShadow: [
          if (isActive) BoxShadow(color: AppColors.primarySoft, spreadRadius: 3),
          ...AppTokens.shadowSM,
        ],
      ),
      padding: const EdgeInsets.all(AppTokens.s8 + 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Only the thumbnail + text are the tap-to-play target —
          // DownloadButton has its own tap targets, and nesting it inside an
          // outer tappable risks the two competing in the gesture arena.
          Expanded(
            child: Semantics(
              button: true,
              label: lesson.title,
              child: PressableScale(
                onTap: onPlay,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _Thumbnail(lesson: lesson, number: number, progress: lesson.progress.isCompleted ? 0 : ratio),
                    const SizedBox(width: AppTokens.s12),
                    Expanded(child: _Body(lesson: lesson, ratio: ratio, isDownloaded: isDownloaded)),
                  ],
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(top: AppTokens.s12),
            child: DownloadButton(
              lessonId: lesson.id,
              lessonTitle: lesson.title,
              durationSeconds: lesson.durationSeconds,
              thumbnailUrl: lesson.thumbnailUrl,
            ),
          ),
        ],
      ),
    );
  }
}

class _Body extends StatelessWidget {
  final Lesson lesson;
  final double ratio;
  final bool isDownloaded;
  const _Body({required this.lesson, required this.ratio, required this.isDownloaded});

  @override
  Widget build(BuildContext context) {
    final String? description = lesson.description?.trim();
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            lesson.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14, color: AppColors.textPrimary, height: 1.4),
          ),
          if (description != null && description.isNotEmpty) ...[
            const SizedBox(height: 2),
            Text(
              description,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, height: 1.5),
            ),
          ],
          const SizedBox(height: AppTokens.s8),
          // The download state (when there is one in progress or failed)
          // replaces the watch status line.
          BlocBuilder<DownloadCubit, DownloadState>(
            buildWhen: (p, c) => p.of(lesson.id) != c.of(lesson.id),
            builder: (context, state) {
              final DownloadItem? item = state.of(lesson.id);
              return switch (item?.status) {
                DownloadItemStatus.downloading || DownloadItemStatus.paused => _DownloadLine(item: item!),
                DownloadItemStatus.failed => _Badge(
                  icon: Icons.error_rounded,
                  label: S.of(context).downloadFailed,
                  color: AppColors.error,
                ),
                _ => _StatusLine(lesson: lesson, ratio: ratio, isDownloaded: isDownloaded),
              };
            },
          ),
        ],
      ),
    );
  }
}

class _StatusLine extends StatelessWidget {
  final Lesson lesson;
  final double ratio;
  final bool isDownloaded;
  const _StatusLine({required this.lesson, required this.ratio, required this.isDownloaded});

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final List<Widget> items = [];
    if (lesson.progress.isCompleted) {
      items.add(_Badge(icon: Icons.check_circle_rounded, label: s.completed, color: AppColors.success));
    } else if (ratio > 0) {
      final int minutesLeft = ((lesson.durationSeconds - lesson.progress.positionSeconds) / 60).ceil().clamp(1, 1 << 20);
      items
        ..add(_Badge(icon: Icons.schedule_rounded, label: s.minutesLeft(minutesLeft), color: AppColors.primary))
        ..add(Text('${(ratio * 100).round()}%', style: const TextStyle(fontSize: 11, color: AppColors.textTertiary)));
    } else {
      items.add(_Badge(label: s.newLesson, color: AppColors.accent));
    }
    if (isDownloaded) {
      items.add(_Badge(icon: Icons.offline_pin_rounded, label: s.savedOffline, color: AppColors.textSecondary, neutral: true));
    }
    return Wrap(spacing: 6, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center, children: items);
  }
}

class _DownloadLine extends StatelessWidget {
  final DownloadItem item;
  const _DownloadLine({required this.item});

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final int percent = (item.progress * 100).round();
    final bool paused = item.status == DownloadItemStatus.paused;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          paused ? s.downloadPausedPercent(percent) : s.downloadingPercent(percent),
          style: const TextStyle(fontSize: 11, color: AppColors.textSecondary, fontWeight: FontWeight.w600),
        ),
        const SizedBox(height: 4),
        Container(
          height: 4,
          clipBehavior: Clip.antiAlias,
          alignment: AlignmentDirectional.centerStart,
          decoration: BoxDecoration(color: AppColors.shimmer, borderRadius: BorderRadius.circular(2)),
          child: FractionallySizedBox(
            widthFactor: item.progress.clamp(0.0, 1.0),
            heightFactor: 1,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: paused ? null : AppTokens.brandGradient,
                color: paused ? AppColors.textTertiary : null,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData? icon;
  final String label;
  final Color color;
  final bool neutral;
  const _Badge({required this.label, required this.color, this.icon, this.neutral = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 22,
      padding: const EdgeInsets.symmetric(horizontal: AppTokens.s8),
      decoration: BoxDecoration(
        color: neutral ? AppColors.inputFill : color.withValues(alpha: 0.10),
        borderRadius: BorderRadius.circular(AppTokens.rFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[Icon(icon, size: 13, color: color), const SizedBox(width: 4)],
          Text(label, style: TextStyle(color: color, fontSize: 11, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  final Lesson lesson;
  final int number;

  /// Watch progress drawn along the bottom edge (0 hides it).
  final double progress;

  const _Thumbnail({required this.lesson, required this.number, required this.progress});

  @override
  Widget build(BuildContext context) {
    final String? thumb = lesson.thumbnailUrl;
    final bool hasThumb = thumb != null && thumb.isNotEmpty;
    return ClipRRect(
      borderRadius: AppTokens.radiusMD,
      child: SizedBox(
        width: 104,
        height: 82,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Bunny's pull zone Referer allow-list 403s a thumbnail request
            // without the embed Referer, so it must carry cdnHeaders.
            if (hasThumb)
              AppNetworkImage(url: thumb, httpHeaders: BunnyConstants.cdnHeaders, cacheKey: BunnyConstants.stableCacheKey(thumb))
            else ...[
              DecoratedBox(decoration: BoxDecoration(gradient: AppGradients.thumbnails[number % AppGradients.thumbnails.length])),
              const CustomPaint(painter: _GridPainter()),
              PositionedDirectional(
                start: 8,
                top: 0,
                child: Text(
                  number.toString().padLeft(2, '0'),
                  style: TextStyle(fontSize: 30, fontWeight: FontWeight.w800, color: Colors.white.withValues(alpha: 0.28), height: 1.2),
                ),
              ),
            ],
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withValues(alpha: 0.0), Colors.black.withValues(alpha: 0.28)],
                ),
              ),
            ),
            Center(
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.92),
                  shape: BoxShape.circle,
                  boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 14, offset: Offset(0, 4))],
                ),
                child: Icon(
                  lesson.progress.isCompleted ? Icons.replay_rounded : Icons.play_arrow_rounded,
                  color: AppColors.primary,
                  size: 18,
                ),
              ),
            ),
            if (lesson.durationSeconds > 0)
              PositionedDirectional(
                end: 6,
                bottom: progress > 0 ? 8 : 6,
                child: Container(
                  height: 18,
                  padding: const EdgeInsets.symmetric(horizontal: 6),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(color: AppColors.playerBg.withValues(alpha: 0.7), borderRadius: BorderRadius.circular(6)),
                  child: Text(
                    DurationUtils.format(lesson.durationSeconds),
                    textDirection: TextDirection.ltr,
                    style: const TextStyle(fontSize: 10.5, color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                ),
              ),
            if (progress > 0)
              Positioned(
                left: 0,
                right: 0,
                bottom: 0,
                height: 3,
                child: ColoredBox(
                  color: Colors.white.withValues(alpha: 0.3),
                  child: Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: FractionallySizedBox(
                      widthFactor: progress,
                      heightFactor: 1,
                      child: const ColoredBox(color: AppColors.accent),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// Faint 14px grid over placeholder thumbnails.
class _GridPainter extends CustomPainter {
  const _GridPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Paint p = Paint()
      ..color = Colors.white.withValues(alpha: 0.08)
      ..strokeWidth = 1;
    for (double x = 0; x < size.width; x += 14) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), p);
    }
    for (double y = 0; y < size.height; y += 14) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), p);
    }
  }

  @override
  bool shouldRepaint(_GridPainter oldDelegate) => false;
}
