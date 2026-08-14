import 'dart:io';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/duration_utils.dart';
import '../../../../generated/l10n.dart';
import '../../../downloads/domain/entities/downloaded_lesson_info.dart';

/// One downloaded video: cached thumbnail (or placeholder) with a duration
/// badge, title, and an "available offline" chip. Tap → offline playback;
/// swipe or tap the trash icon → delete (both go through [onConfirmDelete]).
class DownloadedVideoTile extends StatelessWidget {
  final DownloadedLessonInfo lesson;
  final VoidCallback onPlay;
  final Future<bool> Function() onConfirmDelete;

  const DownloadedVideoTile({super.key, required this.lesson, required this.onPlay, required this.onConfirmDelete});

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: key!,
      direction: DismissDirection.horizontal,
      confirmDismiss: (_) => onConfirmDelete(),
      background: const _DeleteBackground(alignment: Alignment.centerLeft),
      secondaryBackground: const _DeleteBackground(alignment: Alignment.centerRight),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [BoxShadow(color: AppColors.black.withValues(alpha: 0.05), blurRadius: 12, offset: const Offset(0, 4))],
        ),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onPlay,
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _Thumbnail(thumbPath: lesson.thumbPath, durationSeconds: lesson.durationSeconds),
                const SizedBox(width: 14),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          lesson.title.isEmpty ? S.of(context).lessons : lesson.title,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(fontSize: 14.5, fontWeight: FontWeight.w700, color: AppColors.textPrimary, height: 1.3),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(color: AppColors.successSoft, borderRadius: BorderRadius.circular(8)),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.offline_pin_rounded, size: 13, color: AppColors.success),
                              const SizedBox(width: 4),
                              Text(
                                S.of(context).availableOffline,
                                style: const TextStyle(fontSize: 11.5, color: AppColors.success, fontWeight: FontWeight.w700),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                IconButton(
                  tooltip: S.of(context).deleteDownload,
                  onPressed: onConfirmDelete,
                  style: IconButton.styleFrom(
                    backgroundColor: AppColors.errorSoft,
                    padding: const EdgeInsets.all(8),
                    minimumSize: const Size(36, 36),
                  ),
                  icon: const Icon(Icons.delete_outline_rounded, color: AppColors.error, size: 20),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _DeleteBackground extends StatelessWidget {
  final Alignment alignment;
  const _DeleteBackground({required this.alignment});

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: alignment,
      padding: const EdgeInsets.symmetric(horizontal: 24),
      margin: const EdgeInsets.symmetric(vertical: 2),
      decoration: BoxDecoration(color: AppColors.error, borderRadius: BorderRadius.circular(18)),
      child: const Icon(Icons.delete_rounded, color: Colors.white, size: 26),
    );
  }
}

class _Thumbnail extends StatelessWidget {
  final String? thumbPath;
  final int durationSeconds;
  const _Thumbnail({required this.thumbPath, required this.durationSeconds});

  @override
  Widget build(BuildContext context) {
    final File? file = thumbPath == null ? null : File(thumbPath!);
    final bool hasThumb = file != null && file.existsSync();

    return ClipRRect(
      borderRadius: BorderRadius.circular(14),
      child: SizedBox(
        width: 112,
        height: 78,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (hasThumb)
              Image.file(file, fit: BoxFit.cover)
            else
              const DecoratedBox(
                decoration: BoxDecoration(gradient: LinearGradient(colors: [AppColors.primary, AppColors.gradientEnd])),
              ),
            // Subtle scrim so the play icon stays legible on any thumbnail.
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.black.withValues(alpha: 0.05), Colors.black.withValues(alpha: 0.35)],
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
                  child: Text(
                    DurationUtils.format(durationSeconds),
                    style: const TextStyle(fontSize: 10.5, color: Colors.white, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
