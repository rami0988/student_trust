import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/duration_utils.dart';
import '../../../../generated/l10n.dart';
import '../../domain/entities/chapter_progress.dart';

/// Gradient card at the top of the lessons list: chapter title, stats
/// (lessons · total length · completed), a progress ring, and one button that
/// continues where the student left off.
class ChapterProgressHero extends StatelessWidget {
  final String chapterTitle;

  /// Small label above the title (e.g. the subject); null hides it.
  final String? eyebrow;
  final ChapterProgress progress;

  /// Formats the total chapter length ("2 س 14 د").
  final String totalDurationLabel;
  final VoidCallback? onResume;

  const ChapterProgressHero({
    super.key,
    required this.chapterTitle,
    required this.progress,
    required this.totalDurationLabel,
    this.eyebrow,
    this.onResume,
  });

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final int percent = (progress.fraction * 100).round();
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(gradient: AppGradients.hero, borderRadius: AppTokens.radiusXL, boxShadow: AppTokens.shadowPrimary),
      child: Stack(
        children: [
          // Soft light blobs for depth.
          PositionedDirectional(start: -80, top: -110, child: _Glow(size: 220, color: Colors.white.withValues(alpha: 0.22))),
          PositionedDirectional(end: -50, bottom: -70, child: _Glow(size: 160, color: AppColors.accent.withValues(alpha: 0.45))),
          Padding(
            padding: const EdgeInsets.all(AppTokens.s20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (eyebrow != null)
                            Container(
                              margin: const EdgeInsets.only(bottom: 6),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.white.withValues(alpha: 0.18),
                                borderRadius: BorderRadius.circular(AppTokens.rFull),
                              ),
                              child: Text(eyebrow!, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
                            ),
                          Text(
                            chapterTitle,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(color: Colors.white, fontSize: 19, fontWeight: FontWeight.w800, height: 1.35),
                          ),
                          const SizedBox(height: 6),
                          Wrap(
                            spacing: 8,
                            children: [
                              _stat(s.lessonsCount(progress.lessonCount)),
                              if (progress.totalDuration > Duration.zero) ...[_stat('·'), _stat(totalDurationLabel)],
                              _stat('·'),
                              _stat(s.completedCount(progress.completedCount)),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: AppTokens.s16),
                    _ProgressRing(fraction: progress.fraction, label: '$percent%', caption: s.chapterDone),
                  ],
                ),
                if (progress.resumeLesson != null && onResume != null) ...[
                  const SizedBox(height: AppTokens.s16),
                  _ResumeButton(progress: progress, onTap: onResume!),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _stat(String text) => Text(text, style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12));
}

class _Glow extends StatelessWidget {
  final double size;
  final Color color;
  const _Glow({required this.size, required this.color});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, gradient: RadialGradient(colors: [color, color.withValues(alpha: 0)])),
      ),
    );
  }
}

class _ProgressRing extends StatelessWidget {
  final double fraction;
  final String label;
  final String caption;
  const _ProgressRing({required this.fraction, required this.label, required this.caption});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$caption $label',
      excludeSemantics: true,
      child: SizedBox(
        width: 68,
        height: 68,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: fraction),
          duration: AppTokens.dSlow * 2,
          curve: AppTokens.curve,
          builder: (context, value, _) => CustomPaint(
            painter: _RingPainter(value),
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(label, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w800, height: 1.1)),
                  Text(caption, style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 9, fontWeight: FontWeight.w600)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double fraction;
  _RingPainter(this.fraction);

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = (Offset.zero & size).deflate(3);
    final Paint p = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;
    canvas.drawArc(rect, 0, math.pi * 2, false, p..color = Colors.white.withValues(alpha: 0.2));
    if (fraction > 0) {
      canvas.drawArc(rect, -math.pi / 2, fraction * math.pi * 2, false, p
        ..color = Colors.white
        ..strokeCap = StrokeCap.round);
    }
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.fraction != fraction;
}

class _ResumeButton extends StatelessWidget {
  final ChapterProgress progress;
  final VoidCallback onTap;
  const _ResumeButton({required this.progress, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final lesson = progress.resumeLesson!;
    final String label = switch (progress.resumeKind) {
      ResumeKind.resume => '${s.continueWhereLeft} · ${DurationUtils.format(lesson.progress.positionSeconds)}',
      ResumeKind.next => s.upNext,
      ResumeKind.start => s.startChapter,
      ResumeKind.rewatch => s.watchAgain,
    };
    final bool rtl = Directionality.of(context) == TextDirection.rtl;
    return ClipRRect(
      borderRadius: AppTokens.radiusLG,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Material(
          color: Colors.white.withValues(alpha: 0.14),
          child: InkWell(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppTokens.s12, vertical: AppTokens.s8 + 2),
              decoration: BoxDecoration(
                borderRadius: AppTokens.radiusLG,
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle),
                    child: Icon(
                      progress.resumeKind == ResumeKind.rewatch ? Icons.replay_rounded : Icons.play_arrow_rounded,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(width: AppTokens.s12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(label, style: TextStyle(color: Colors.white.withValues(alpha: 0.85), fontSize: 12)),
                        Text(
                          lesson.title,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  ),
                  Icon(rtl ? Icons.chevron_left_rounded : Icons.chevron_right_rounded, color: Colors.white),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
