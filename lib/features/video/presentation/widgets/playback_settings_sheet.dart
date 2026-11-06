import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../generated/l10n.dart';
import '../utils/playback_time.dart';
import 'player_chrome.dart';
import 'time_saved_indicator.dart';

/// Opens the playback settings sheet (speed + time saved + quality).
///
/// Changes apply immediately through [onSpeedChanged] / [onQualityChanged]
/// while the sheet stays open, so the student sees the effect of each choice.
Future<void> showPlaybackSettingsSheet({
  required BuildContext context,
  required double speed,
  required ValueChanged<double> onSpeedChanged,
  required Duration lessonDuration,
  Duration? chapterDuration,
  List<String> qualities = const [],
  String? selectedQuality,
  String? defaultQuality,
  ValueChanged<String>? onQualityChanged,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.6),
    constraints: BoxConstraints(maxHeight: MediaQuery.sizeOf(context).height * 0.88, maxWidth: 640),
    builder: (_) => _PlaybackSettingsSheet(
      initialSpeed: speed,
      onSpeedChanged: onSpeedChanged,
      lessonDuration: lessonDuration,
      chapterDuration: chapterDuration,
      qualities: qualities,
      initialQuality: selectedQuality,
      defaultQuality: defaultQuality,
      onQualityChanged: onQualityChanged,
    ),
  );
}

class _PlaybackSettingsSheet extends StatefulWidget {
  final double initialSpeed;
  final ValueChanged<double> onSpeedChanged;
  final Duration lessonDuration;
  final Duration? chapterDuration;
  final List<String> qualities;
  final String? initialQuality;
  final String? defaultQuality;
  final ValueChanged<String>? onQualityChanged;

  const _PlaybackSettingsSheet({
    required this.initialSpeed,
    required this.onSpeedChanged,
    required this.lessonDuration,
    required this.chapterDuration,
    required this.qualities,
    required this.initialQuality,
    required this.defaultQuality,
    required this.onQualityChanged,
  });

  @override
  State<_PlaybackSettingsSheet> createState() => _PlaybackSettingsSheetState();
}

class _PlaybackSettingsSheetState extends State<_PlaybackSettingsSheet> {
  late double _speed = widget.initialSpeed;
  late String? _quality = widget.initialQuality ?? widget.defaultQuality;

  void _pickSpeed(double speed) {
    setState(() => _speed = speed);
    widget.onSpeedChanged(speed);
  }

  void _pickQuality(String quality) {
    setState(() => _quality = quality);
    widget.onQualityChanged?.call(quality);
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(28)),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
        child: Container(
          decoration: const BoxDecoration(
            color: AppColors.playerSurface,
            border: Border(top: BorderSide(color: AppColors.playerLine)),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(AppTokens.s16, AppTokens.s8 + 2, AppTokens.s16, AppTokens.s24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(2)),
                    ),
                  ),
                  const SizedBox(height: AppTokens.s12),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          s.playbackSettings,
                          style: const TextStyle(color: AppColors.playerInk, fontSize: 17, fontWeight: FontWeight.w800),
                        ),
                      ),
                      IconButton(
                        tooltip: MaterialLocalizations.of(context).closeButtonTooltip,
                        onPressed: () => Navigator.of(context).pop(),
                        style: IconButton.styleFrom(backgroundColor: AppColors.playerSurface2, foregroundColor: AppColors.playerInk2),
                        icon: const Icon(Icons.close_rounded, size: 18),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppTokens.s8),
                  _SectionTitle(title: s.playbackSpeed, trailing: s.speedSavedForAll),
                  const SizedBox(height: AppTokens.s8 + 2),
                  _SpeedPicker(value: _speed, onChanged: _pickSpeed, normalLabel: s.speedNormal),
                  const SizedBox(height: AppTokens.s12),
                  TimeSavedCard(lesson: widget.lessonDuration, chapter: widget.chapterDuration, speed: _speed),
                  if (widget.qualities.isNotEmpty) ...[
                    const SizedBox(height: AppTokens.s20),
                    _SectionTitle(title: s.videoQuality),
                    const SizedBox(height: AppTokens.s8),
                    for (final String q in widget.qualities)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: _QualityOption(
                          quality: q,
                          selected: q == _quality,
                          isDefault: q == widget.defaultQuality,
                          onTap: () => _pickQuality(q),
                        ),
                      ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  final String? trailing;
  const _SectionTitle({required this.title, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Expanded(
          child: Text(title, style: const TextStyle(color: AppColors.playerInk, fontSize: 13, fontWeight: FontWeight.w800)),
        ),
        if (trailing != null)
          Text(trailing!, style: const TextStyle(color: AppColors.playerInk3, fontSize: 11.5, fontWeight: FontWeight.w600)),
      ],
    );
  }
}

/// Five-way segmented speed control (left → right like the player controls).
class _SpeedPicker extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;
  final String normalLabel;

  const _SpeedPicker({required this.value, required this.onChanged, required this.normalLabel});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppColors.playerBg,
          borderRadius: AppTokens.radiusLG,
          border: Border.all(color: AppColors.playerLine),
        ),
        child: Row(
          children: [
            for (final double speed in PlaybackTime.speeds)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 3),
                  child: _SpeedOption(
                    label: PlaybackTime.speedLabel(speed),
                    caption: speed == 1 ? normalLabel : null,
                    selected: speed == value,
                    onTap: () => onChanged(speed),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _SpeedOption extends StatelessWidget {
  final String label;
  final String? caption;
  final bool selected;
  final VoidCallback onTap;

  const _SpeedOption({required this.label, required this.caption, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      inMutuallyExclusiveGroup: true,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: AnimatedContainer(
          duration: AppTokens.dMed,
          curve: AppTokens.curve,
          height: 46,
          decoration: BoxDecoration(
            gradient: selected ? AppTokens.brandGradient : null,
            borderRadius: AppTokens.radiusMD,
            boxShadow: selected
                ? [BoxShadow(color: AppColors.primary.withValues(alpha: 0.45), blurRadius: 18, offset: const Offset(0, 6))]
                : null,
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                label,
                style: TextStyle(
                  color: selected ? AppColors.playerInk : AppColors.playerInk2,
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  height: 1.2,
                ),
              ),
              if (caption != null)
                Text(
                  caption!,
                  style: TextStyle(color: selected ? AppColors.playerInk2 : AppColors.playerInk3, fontSize: 8.5, height: 1.1),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _QualityOption extends StatelessWidget {
  final String quality;
  final bool selected;
  final bool isDefault;
  final VoidCallback onTap;

  const _QualityOption({required this.quality, required this.selected, required this.isDefault, required this.onTap});

  String _description(S s) {
    final int height = int.tryParse(quality.replaceAll(RegExp(r'[^0-9]'), '')) ?? 0;
    final String base = height >= 1080
        ? s.qualityFullDesc
        : height >= 720
        ? s.qualityHighDesc
        : height >= 480
        ? s.qualityDataSaverDesc
        : s.qualityLowDesc;
    return isDefault ? '$base · ${s.qualityDefaultTag}' : base;
  }

  @override
  Widget build(BuildContext context) {
    final String? tag = qualityTagFor(quality);
    return Semantics(
      selected: selected,
      inMutuallyExclusiveGroup: true,
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppTokens.radiusMD,
          child: AnimatedContainer(
            duration: AppTokens.dMed,
            padding: const EdgeInsets.symmetric(horizontal: AppTokens.s12 + 2, vertical: AppTokens.s12),
            decoration: BoxDecoration(
              color: selected ? AppColors.primary.withValues(alpha: 0.12) : AppColors.playerBg,
              borderRadius: AppTokens.radiusMD,
              border: Border.all(color: selected ? AppColors.gradientEnd : AppColors.playerLine),
            ),
            child: Row(
              children: [
                AnimatedContainer(
                  duration: AppTokens.dMed,
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: selected ? AppColors.gradientEnd : AppColors.playerInk3, width: 2),
                  ),
                  alignment: Alignment.center,
                  child: selected
                      ? Container(
                          width: 10,
                          height: 10,
                          decoration: const BoxDecoration(color: AppColors.gradientEnd, shape: BoxShape.circle),
                        )
                      : null,
                ),
                const SizedBox(width: AppTokens.s12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        quality,
                        textDirection: TextDirection.ltr,
                        style: const TextStyle(color: AppColors.playerInk, fontSize: 14, fontWeight: FontWeight.w700),
                      ),
                      Text(_description(S.of(context)), style: const TextStyle(color: AppColors.playerInk3, fontSize: 11.5)),
                    ],
                  ),
                ),
                if (tag != null) QualityTag(label: tag),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
