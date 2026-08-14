import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/duration_utils.dart';
import '../../../../core/widgets/app_motion.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../domain/entities/worksheet_video.dart';

class WorksheetVideoTile extends StatelessWidget {
  final WorksheetVideo video;
  final VoidCallback onPlay;

  const WorksheetVideoTile({super.key, required this.video, required this.onPlay});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: video.title,
      child: PressableScale(
        onTap: onPlay,
        child: Container(
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: AppTokens.radiusLG, boxShadow: AppTokens.shadowSM),
          child: Padding(
            padding: const EdgeInsets.all(AppTokens.s8),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: AppTokens.radiusMD,
                  child: SizedBox(
                    width: 96,
                    height: 64,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        // NOTE(migration): Bunny's pull zone Referer allow-list
                        // means a plain AppNetworkImage (no custom headers)
                        // will 403 here — same caveat as OLD app's cached
                        // network image usage. AppNetworkImage doesn't support
                        // custom headers yet; revisit once BunnyConstants
                        // .cdnHeaders needs to be threaded through.
                        if (video.thumbnailUrl != null && video.thumbnailUrl!.isNotEmpty)
                          AppNetworkImage(url: video.thumbnailUrl!)
                        else
                          const DecoratedBox(decoration: BoxDecoration(gradient: AppTokens.brandGradient)),
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
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.9), shape: BoxShape.circle),
                            child: const Icon(Icons.play_arrow_rounded, color: AppColors.primary, size: 18),
                          ),
                        ),
                        if (video.durationSeconds > 0)
                          Positioned(
                            right: 4,
                            bottom: 4,
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                              decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.65), borderRadius: BorderRadius.circular(6)),
                              child: Text(
                                DurationUtils.format(video.durationSeconds),
                                style: const TextStyle(fontSize: 10, color: Colors.white, fontWeight: FontWeight.w600),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppTokens.s12),
                Expanded(
                  child: Text(
                    video.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.3),
                  ),
                ),
                const Icon(Icons.chevron_left_rounded, color: AppColors.primary),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
