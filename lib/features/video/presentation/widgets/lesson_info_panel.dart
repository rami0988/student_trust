import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/duration_utils.dart';
import '../../../../generated/l10n.dart';
import '../pages/video_player_args.dart';
import '../utils/playback_snapshot.dart';
import '../utils/playback_time.dart';
import 'time_saved_indicator.dart';

/// Everything under the video in portrait: where the lesson sits in the
/// chapter, its title, badges, live watch progress, the time-saved pill, the
/// description, playback shortcuts and the next lesson.
class LessonInfoPanel extends StatelessWidget {
  final VideoPlayerArgs args;
  final ValueListenable<PlaybackSnapshot> playback;
  final double speed;

  /// Quality currently playing ("720p"), or null when there's no choice.
  final String? quality;
  final VoidCallback onOpenSettings;
  final ValueChanged<VideoPlayerArgs>? onPlayNext;

  const LessonInfoPanel({
    super.key,
    required this.args,
    required this.playback,
    required this.speed,
    required this.quality,
    required this.onOpenSettings,
    this.onPlayNext,
  });

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final String? eyebrow = _eyebrow(s);
    return ListView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(AppTokens.s16, AppTokens.s16 + 2, AppTokens.s16, AppTokens.s40),
      children: [
        if (eyebrow != null)
          Text(eyebrow, style: const TextStyle(color: AppColors.playerInk3, fontSize: 12, fontWeight: FontWeight.w600)),
        Text(
          args.lessonTitle,
          style: const TextStyle(color: AppColors.playerInk, fontSize: 20, fontWeight: FontWeight.w800, height: 1.35),
        ),
        const SizedBox(height: AppTokens.s12),
        ValueListenableBuilder<PlaybackSnapshot>(
          valueListenable: playback,
          builder: (context, snap, _) {
            final Duration length = _length(snap);
            final double watched = snap.duration > Duration.zero
                ? snap.playedFraction
                : DurationUtils.ratio(args.savedPosition, args.durationSeconds);
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Wrap(
                  spacing: AppTokens.s8,
                  runSpacing: AppTokens.s8,
                  children: [
                    if (length > Duration.zero)
                      _InfoChip(icon: Icons.schedule_rounded, label: DurationUtils.format(length.inSeconds), ltr: true),
                    if (args.isOffline || args.isDownloaded)
                      _InfoChip(icon: Icons.offline_pin_rounded, label: s.availableOffline, highlight: true),
                    if (quality != null) _InfoChip(icon: Icons.hd_rounded, label: quality!, ltr: true),
                  ],
                ),
                if (args.trackProgress && length > Duration.zero) ...[
                  const SizedBox(height: AppTokens.s16),
                  _WatchProgress(label: s.watched, fraction: watched),
                ],
                if (length > Duration.zero) ...[
                  const SizedBox(height: AppTokens.s16),
                  TimeSavedPill(lesson: length, speed: speed, onTap: onOpenSettings),
                ],
              ],
            );
          },
        ),
        if (args.description != null && args.description!.trim().isNotEmpty) ...[
          const SizedBox(height: AppTokens.s16),
          _DescriptionCard(text: args.description!.trim()),
        ],
        const SizedBox(height: AppTokens.s16),
        Row(
          children: [
            Expanded(
              child: _QuickSetting(
                icon: Icons.speed_rounded,
                label: s.speedLabel,
                value: PlaybackTime.speedLabel(speed),
                onTap: onOpenSettings,
              ),
            ),
            if (quality != null) ...[
              const SizedBox(width: AppTokens.s12 - 2),
              Expanded(
                child: _QuickSetting(icon: Icons.hd_outlined, label: s.qualityLabel, value: quality!, onTap: onOpenSettings),
              ),
            ],
          ],
        ),
        if (args.nextLesson != null && onPlayNext != null) ...[
          const SizedBox(height: AppTokens.s20),
          Text(s.upNext, style: const TextStyle(color: AppColors.playerInk, fontSize: 14, fontWeight: FontWeight.w800)),
          const SizedBox(height: AppTokens.s8),
          _UpNextTile(next: args.nextLesson!, onTap: () => onPlayNext!(args.nextLesson!)),
        ],
      ],
    );
  }

  String? _eyebrow(S s) {
    final List<String> parts = [
      if (args.lessonNumber != null && args.lessonCount != null) s.lessonOfCount(args.lessonNumber!, args.lessonCount!),
      if (args.chapterTitle != null && args.chapterTitle!.isNotEmpty) args.chapterTitle!,
    ];
    return parts.isEmpty ? null : parts.join(' · ');
  }

  Duration _length(PlaybackSnapshot snap) => snap.duration > Duration.zero ? snap.duration : Duration(seconds: args.durationSeconds);
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool highlight;
  final bool ltr;

  const _InfoChip({required this.icon, required this.label, this.highlight = false, this.ltr = false});

  @override
  Widget build(BuildContext context) {
    final Color fg = highlight ? AppColors.successBright : AppColors.playerInk2;
    return Container(
      height: 28,
      padding: const EdgeInsets.symmetric(horizontal: AppTokens.s8 + 2),
      decoration: BoxDecoration(
        color: highlight ? AppColors.success.withValues(alpha: 0.10) : AppColors.playerSurface2,
        borderRadius: BorderRadius.circular(AppTokens.rFull),
        border: Border.all(color: highlight ? AppColors.success.withValues(alpha: 0.20) : AppColors.playerLine),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: fg),
          const SizedBox(width: 6),
          Text(
            label,
            textDirection: ltr ? TextDirection.ltr : null,
            style: TextStyle(color: fg, fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }
}

class _WatchProgress extends StatelessWidget {
  final String label;
  final double fraction;
  const _WatchProgress({required this.label, required this.fraction});

  @override
  Widget build(BuildContext context) {
    const TextStyle style = TextStyle(color: AppColors.playerInk2, fontSize: 12);
    return Semantics(
      label: label,
      value: '${(fraction * 100).round()}%',
      excludeSemantics: true,
      child: Row(
        children: [
          Text(label, style: style),
          const SizedBox(width: AppTokens.s8 + 2),
          Expanded(
            child: Container(
              height: 6,
              decoration: BoxDecoration(color: AppColors.playerSurface2, borderRadius: BorderRadius.circular(3)),
              alignment: AlignmentDirectional.centerStart,
              child: FractionallySizedBox(
                widthFactor: fraction.clamp(0.0, 1.0),
                child: Container(
                  decoration: BoxDecoration(gradient: AppGradients.accent, borderRadius: BorderRadius.circular(3)),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppTokens.s8 + 2),
          Text('${(fraction * 100).round()}%', style: style),
        ],
      ),
    );
  }
}

/// Lesson description, clamped to three lines with "Show more" when longer.
class _DescriptionCard extends StatefulWidget {
  final String text;
  const _DescriptionCard({required this.text});

  @override
  State<_DescriptionCard> createState() => _DescriptionCardState();
}

class _DescriptionCardState extends State<_DescriptionCard> {
  bool _expanded = false;
  static const TextStyle _style = TextStyle(color: AppColors.playerInk2, fontSize: 13.5, height: 1.85);

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return Container(
      padding: const EdgeInsets.fromLTRB(AppTokens.s16, AppTokens.s12 + 2, AppTokens.s16, AppTokens.s12),
      decoration: BoxDecoration(
        color: AppColors.playerSurface,
        borderRadius: AppTokens.radiusLG,
        border: Border.all(color: AppColors.playerLine),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final TextPainter painter = TextPainter(
            text: TextSpan(text: widget.text, style: _style),
            maxLines: 3,
            textDirection: Directionality.of(context),
            textScaler: MediaQuery.textScalerOf(context),
          )..layout(maxWidth: constraints.maxWidth);
          final bool overflows = painter.didExceedMaxLines;
          painter.dispose();
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Icon(Icons.info_rounded, size: 15, color: AppColors.playerInk),
                  const SizedBox(width: 6),
                  Text(s.aboutLesson, style: const TextStyle(color: AppColors.playerInk, fontSize: 13, fontWeight: FontWeight.w800)),
                ],
              ),
              const SizedBox(height: 6),
              AnimatedSize(
                duration: AppTokens.dMed,
                curve: AppTokens.curve,
                alignment: AlignmentDirectional.topStart,
                child: Text(
                  widget.text,
                  style: _style,
                  maxLines: _expanded ? null : 3,
                  overflow: _expanded ? TextOverflow.visible : TextOverflow.ellipsis,
                ),
              ),
              if (overflows)
                TextButton(
                  onPressed: () => setState(() => _expanded = !_expanded),
                  style: TextButton.styleFrom(
                    foregroundColor: AppColors.gradientEnd,
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 36),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  child: Text(_expanded ? s.showLess : s.showMore, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12.5)),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _QuickSetting extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final VoidCallback onTap;

  const _QuickSetting({required this.icon, required this.label, required this.value, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: '$label $value',
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppTokens.radiusLG,
          child: Ink(
            padding: const EdgeInsets.all(AppTokens.s12),
            decoration: BoxDecoration(
              color: AppColors.playerSurface,
              borderRadius: AppTokens.radiusLG,
              border: Border.all(color: AppColors.playerLine),
            ),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(color: AppColors.gradientEnd.withValues(alpha: 0.14), borderRadius: AppTokens.radiusSM),
                  child: Icon(icon, color: AppColors.gradientEnd, size: 18),
                ),
                const SizedBox(width: AppTokens.s8 + 2),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(label, style: const TextStyle(color: AppColors.playerInk3, fontSize: 11, height: 1.3)),
                      Text(
                        value,
                        textDirection: TextDirection.ltr,
                        style: const TextStyle(color: AppColors.playerInk, fontSize: 14, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _UpNextTile extends StatelessWidget {
  final VideoPlayerArgs next;
  final VoidCallback onTap;
  const _UpNextTile({required this.next, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final String? sub = next.lessonNumber != null && next.lessonCount != null ? s.lessonOfCount(next.lessonNumber!, next.lessonCount!) : null;
    return Semantics(
      button: true,
      label: '${s.upNext}: ${next.lessonTitle}',
      excludeSemantics: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppTokens.radiusMD,
          child: Padding(
            padding: const EdgeInsets.all(AppTokens.s8),
            child: Row(
              children: [
                Container(
                  width: 72,
                  height: 45,
                  decoration: BoxDecoration(
                    gradient: AppGradients.thumbnails[(next.lessonNumber ?? 1) % AppGradients.thumbnails.length],
                    borderRadius: AppTokens.radiusSM,
                  ),
                  alignment: AlignmentDirectional.bottomEnd,
                  padding: const EdgeInsets.all(4),
                  child: next.durationSeconds > 0
                      ? Container(
                          padding: const EdgeInsets.symmetric(horizontal: 4),
                          decoration: BoxDecoration(color: Colors.black.withValues(alpha: 0.6), borderRadius: BorderRadius.circular(4)),
                          child: Text(
                            DurationUtils.format(next.durationSeconds),
                            textDirection: TextDirection.ltr,
                            style: const TextStyle(color: AppColors.playerInk, fontSize: 9.5, fontWeight: FontWeight.w700),
                          ),
                        )
                      : null,
                ),
                const SizedBox(width: AppTokens.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        next.lessonTitle,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: AppColors.playerInk, fontSize: 13, fontWeight: FontWeight.w700),
                      ),
                      if (sub != null) Text(sub, style: const TextStyle(color: AppColors.playerInk3, fontSize: 12)),
                    ],
                  ),
                ),
                Icon(
                  Directionality.of(context) == TextDirection.rtl ? Icons.chevron_left_rounded : Icons.chevron_right_rounded,
                  color: AppColors.playerInk2,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
