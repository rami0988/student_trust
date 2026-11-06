import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/duration_utils.dart';
import '../../../../generated/l10n.dart';
import '../utils/playback_time.dart';
import '../../../../core/utils/spoken_duration.dart';

/// The localized sentences for one speed, shared by the card and the pill.
class TimeSavedCopy {
  final SpeedEffect effect;
  final String title;
  final String? subtitle;
  final String compact;

  /// The part of [title] to emphasise (the time saved/added, or the length).
  final String highlight;

  /// The part of [compact] to emphasise.
  final String compactHighlight;

  const TimeSavedCopy._(this.effect, this.title, this.subtitle, this.compact, this.highlight, [String? compactHighlight])
    : compactHighlight = compactHighlight ?? highlight;

  factory TimeSavedCopy.of(S s, {required Duration lesson, required double speed, Duration? chapter}) {
    final SpeedEffect effect = PlaybackTime.effectOf(speed);
    final String speedText = PlaybackTime.speedLabelInText(speed);
    switch (effect) {
      case SpeedEffect.faster:
        final String saved = spokenDuration(s, PlaybackTime.saved(lesson, speed));
        final String? chapterLine = chapter != null && chapter > lesson
            ? s.timeSavedChapter(spokenDuration(s, PlaybackTime.saved(chapter, speed)))
            : null;
        return TimeSavedCopy._(
          effect,
          s.timeSavedFaster(speedText, saved),
          chapterLine,
          s.timeSavedPillFaster(speedText, saved),
          saved,
        );
      case SpeedEffect.normal:
        final String suggested = PlaybackTime.speedLabelInText(PlaybackTime.suggestedSpeed);
        final String saved = spokenDuration(s, PlaybackTime.saved(lesson, PlaybackTime.suggestedSpeed));
        final String length = DurationUtils.format(lesson.inSeconds);
        return TimeSavedCopy._(
          effect,
          s.timeSavedNormal(length),
          s.timeSavedTry(suggested, saved),
          s.timeSavedPillNormal(suggested, saved),
          length,
          saved,
        );
      case SpeedEffect.slower:
        final String extra = spokenDuration(s, PlaybackTime.saved(lesson, speed));
        return TimeSavedCopy._(effect, s.timeSavedSlower(extra), s.timeSavedSlowerHint, s.timeSavedPillSlower(speedText, extra), extra);
    }
  }
}

Color _accentFor(SpeedEffect effect) => switch (effect) {
  SpeedEffect.faster => AppColors.successBright,
  SpeedEffect.slower => AppColors.accentLight,
  SpeedEffect.normal => AppColors.gradientEnd,
};

BoxDecoration _decorationFor(SpeedEffect effect, {required double radius}) {
  final BorderRadius r = BorderRadius.circular(radius);
  return switch (effect) {
    SpeedEffect.faster => BoxDecoration(
      borderRadius: r,
      gradient: LinearGradient(colors: [AppColors.success.withValues(alpha: 0.14), AppColors.gradientEnd.withValues(alpha: 0.10)]),
      border: Border.all(color: AppColors.successBright.withValues(alpha: 0.24)),
    ),
    SpeedEffect.slower => BoxDecoration(
      borderRadius: r,
      gradient: LinearGradient(colors: [AppColors.accent.withValues(alpha: 0.16), AppColors.gradientEnd.withValues(alpha: 0.08)]),
      border: Border.all(color: AppColors.accentLight.withValues(alpha: 0.30)),
    ),
    SpeedEffect.normal => BoxDecoration(
      borderRadius: r,
      color: AppColors.playerBg,
      border: Border.all(color: AppColors.playerLine),
    ),
  };
}

/// Splits [text] so [part] (first occurrence) is drawn in [highlight].
TextSpan highlightedSpan(String text, String part, {required TextStyle base, required TextStyle highlight}) {
  final int i = part.isEmpty ? -1 : text.indexOf(part);
  if (i < 0) return TextSpan(text: text, style: base);
  return TextSpan(
    style: base,
    children: [
      TextSpan(text: text.substring(0, i)),
      TextSpan(text: part, style: highlight),
      TextSpan(text: text.substring(i + part.length)),
    ],
  );
}

class _EffectIcon extends StatelessWidget {
  final SpeedEffect effect;
  const _EffectIcon({required this.effect});

  @override
  Widget build(BuildContext context) {
    final Color color = _accentFor(effect);
    return Container(
      width: 34,
      height: 34,
      decoration: BoxDecoration(color: color.withValues(alpha: 0.16), borderRadius: AppTokens.radiusSM),
      child: Icon(effect == SpeedEffect.slower ? Icons.psychology_rounded : Icons.bolt_rounded, color: color, size: 18),
    );
  }
}

/// Full card for the playback settings sheet: motivational line, chapter
/// line, and a bar comparing normal vs chosen duration.
class TimeSavedCard extends StatelessWidget {
  final Duration lesson;
  final Duration? chapter;
  final double speed;

  const TimeSavedCard({super.key, required this.lesson, required this.speed, this.chapter});

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final TimeSavedCopy copy = TimeSavedCopy.of(s, lesson: lesson, speed: speed, chapter: chapter);
    final Duration atSpeed = PlaybackTime.atSpeed(lesson, speed);
    final double longest = (lesson > atSpeed ? lesson : atSpeed).inMilliseconds.toDouble();
    final Color accent = _accentFor(copy.effect);

    return Semantics(
      liveRegion: true,
      child: AnimatedContainer(
        duration: AppTokens.dMed,
        curve: AppTokens.curve,
        padding: const EdgeInsets.all(AppTokens.s12 + 2),
        decoration: _decorationFor(copy.effect, radius: AppTokens.rLG),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _EffectIcon(effect: copy.effect),
                const SizedBox(width: AppTokens.s12 - 2),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text.rich(
                        highlightedSpan(
                          copy.title,
                          copy.highlight,
                          base: const TextStyle(color: AppColors.playerInk, fontSize: 13, fontWeight: FontWeight.w800, height: 1.6),
                          highlight: TextStyle(color: accent),
                        ),
                      ),
                      if (copy.subtitle != null)
                        Text(copy.subtitle!, style: const TextStyle(color: AppColors.playerInk2, fontSize: 11.5, height: 1.55)),
                    ],
                  ),
                ),
              ],
            ),
            if (lesson > Duration.zero) ...[
              const SizedBox(height: AppTokens.s12 - 2),
              Directionality(
                textDirection: TextDirection.ltr,
                child: Column(
                  children: [
                    _MeterRow(label: PlaybackTime.speedLabel(1), fraction: lesson.inMilliseconds / longest, time: lesson, fill: null),
                    const SizedBox(height: 6),
                    _MeterRow(
                      label: PlaybackTime.speedLabel(speed),
                      fraction: atSpeed.inMilliseconds / longest,
                      time: atSpeed,
                      fill: copy.effect == SpeedEffect.slower ? AppGradients.accent : AppGradients.brandHorizontal,
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MeterRow extends StatelessWidget {
  final String label;
  final double fraction;
  final Duration time;
  final Gradient? fill;

  const _MeterRow({required this.label, required this.fraction, required this.time, required this.fill});

  @override
  Widget build(BuildContext context) {
    const TextStyle style = TextStyle(color: AppColors.playerInk2, fontSize: 11, fontWeight: FontWeight.w700);
    return Row(
      children: [
        SizedBox(width: 40, child: Text(label, style: style)),
        const SizedBox(width: AppTokens.s8),
        Expanded(
          child: Container(
            height: 8,
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.06), borderRadius: BorderRadius.circular(4)),
            alignment: Alignment.centerLeft,
            child: AnimatedFractionallySizedBox(
              duration: AppTokens.dSlow,
              curve: AppTokens.curveEmphasized,
              widthFactor: fraction.clamp(0.0, 1.0),
              child: Container(
                decoration: BoxDecoration(
                  color: fill == null ? Colors.white.withValues(alpha: 0.28) : null,
                  gradient: fill,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: AppTokens.s8),
        SizedBox(
          width: 44,
          child: Text(DurationUtils.format(time.inSeconds), textAlign: TextAlign.right, style: style),
        ),
      ],
    );
  }
}

/// Compact version under the lesson's watch progress; tapping opens the
/// playback settings.
class TimeSavedPill extends StatelessWidget {
  final Duration lesson;
  final double speed;
  final VoidCallback onTap;

  const TimeSavedPill({super.key, required this.lesson, required this.speed, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final TimeSavedCopy copy = TimeSavedCopy.of(s, lesson: lesson, speed: speed);
    return Semantics(
      button: true,
      liveRegion: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppTokens.radiusMD,
          child: Ink(
            padding: const EdgeInsets.symmetric(horizontal: AppTokens.s12, vertical: AppTokens.s8 + 2),
            decoration: _decorationFor(copy.effect, radius: AppTokens.rMD),
            child: Row(
              children: [
                _EffectIcon(effect: copy.effect),
                const SizedBox(width: AppTokens.s12 - 2),
                Expanded(
                  child: Text.rich(
                    highlightedSpan(
                      copy.compact,
                      copy.compactHighlight,
                      base: const TextStyle(color: AppColors.playerInk, fontSize: 12.5, fontWeight: FontWeight.w700, height: 1.55),
                      highlight: TextStyle(color: _accentFor(copy.effect)),
                    ),
                  ),
                ),
                const SizedBox(width: AppTokens.s8),
                Text(s.change, style: const TextStyle(color: AppColors.gradientEnd, fontSize: 11.5, fontWeight: FontWeight.w800)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
