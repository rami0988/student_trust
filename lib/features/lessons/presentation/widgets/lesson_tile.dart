import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/duration_utils.dart';
import '../../../../core/widgets/app_motion.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../generated/l10n.dart';
import '../../../downloads/presentation/widgets/download_button.dart';
import '../../domain/entities/lesson.dart';

class LessonTile extends StatelessWidget {
  final Lesson lesson;
  final bool isDownloaded;
  final VoidCallback onPlayOnline;
  final VoidCallback onPlayOffline;

  const LessonTile({super.key, required this.lesson, required this.isDownloaded, required this.onPlayOnline, required this.onPlayOffline});

  @override
  Widget build(BuildContext context) {
    final progress = lesson.progress;
    final double ratio = DurationUtils.ratio(progress.positionSeconds, lesson.durationSeconds);
    final VoidCallback onPlay = isDownloaded ? onPlayOffline : onPlayOnline;

    return Container(
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: AppTokens.radiusLG, boxShadow: AppTokens.shadowSM),
      child: Padding(
        padding: const EdgeInsets.all(AppTokens.s12),
        child: Column(
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Only the thumbnail + text are wrapped in the tap-to-play
                // target — DownloadButton has its own nested IconButtons, and
                // nesting it inside an outer tappable risks the two competing
                // for the same touch in the gesture arena.
                Expanded(
                  child: Semantics(
                    button: true,
                    label: lesson.title,
                    child: PressableScale(
                      onTap: onPlay,
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _PlayLeading(thumbnailUrl: lesson.thumbnailUrl, durationSeconds: lesson.durationSeconds, isDownloaded: isDownloaded),
                          const SizedBox(width: AppTokens.s12),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.symmetric(vertical: AppTokens.s4),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    lesson.title,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14.5, color: AppColors.textPrimary, height: 1.3),
                                  ),
                                  const SizedBox(height: AppTokens.s8),
                                  if (progress.isCompleted)
                                    _Badge(icon: Icons.check_circle_rounded, label: S.of(context).completed, color: AppColors.success)
                                  else
                                    Row(
                                      children: [
                                        const Icon(Icons.schedule_rounded, size: 13, color: AppColors.textSecondary),
                                        const SizedBox(width: AppTokens.s4),
                                        Text(
                                          DurationUtils.format(lesson.durationSeconds),
                                          style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
                                        ),
                                      ],
                                    ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                DownloadButton(lessonId: lesson.id, lessonTitle: lesson.title, durationSeconds: lesson.durationSeconds, thumbnailUrl: lesson.thumbnailUrl),
              ],
            ),
            if (ratio > 0) ...[
              const SizedBox(height: AppTokens.s8),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppTokens.rFull),
                child: LinearProgressIndicator(value: ratio, minHeight: 4, backgroundColor: AppColors.divider, color: AppColors.accent),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  const _Badge({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: color.withValues(alpha: 0.10), borderRadius: BorderRadius.circular(AppTokens.rSM)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: AppTokens.s4),
          Text(label, style: TextStyle(color: color, fontSize: 11.5, fontWeight: FontWeight.w700)),
        ],
      ),
    );
  }
}

class _PlayLeading extends StatelessWidget {
  final String? thumbnailUrl;
  final int durationSeconds;
  final bool isDownloaded;
  const _PlayLeading({required this.durationSeconds, required this.isDownloaded, this.thumbnailUrl});

  @override
  Widget build(BuildContext context) {
    final bool hasThumb = thumbnailUrl != null && thumbnailUrl!.isNotEmpty;
    return ClipRRect(
      borderRadius: AppTokens.radiusMD,
      child: SizedBox(
        width: 100,
        height: 70,
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Bunny's pull zone Referer allow-list means a plain
            // AppNetworkImage (no custom headers) will 403 here — same
            // caveat as the OLD app. Left as network image for now since
            // AppNetworkImage doesn't support custom headers; revisit
            // once BunnyConstants.cdnHeaders needs to be threaded through.
            if (hasThumb) AppNetworkImage(url: thumbnailUrl!) else const DecoratedBox(decoration: BoxDecoration(gradient: AppTokens.brandGradient)),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withValues(alpha: 0.05), Colors.black.withValues(alpha: 0.32)],
                ),
              ),
            ),
            Center(
              child: Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.9), shape: BoxShape.circle),
                child: const Icon(Icons.play_arrow_rounded, color: AppColors.primary, size: 20),
              ),
            ),
            if (durationSeconds > 0)
              Positioned(
                right: 5,
                bottom: 5,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.65), borderRadius: BorderRadius.circular(6)),
                  child: Text(DurationUtils.format(durationSeconds), style: const TextStyle(fontSize: 10.5, color: Colors.white, fontWeight: FontWeight.w600)),
                ),
              ),
            if (isDownloaded)
              const Positioned(
                left: 5,
                top: 5,
                child: Icon(Icons.offline_pin_rounded, color: AppColors.success, size: 18, shadows: [Shadow(color: Colors.black38, blurRadius: 4)]),
              ),
          ],
        ),
      ),
    );
  }
}
