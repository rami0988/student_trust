import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';

/// Shared building blocks for everything drawn over the video.
///
/// Overlays use a translucent fill with a hairline border rather than a real
/// backdrop blur: a `BackdropFilter` over a playing video re-blurs every
/// frame, which drops frames on the low-end phones most students have. The
/// bottom sheet and toasts, which sit over static content, do blur.
BoxDecoration overlayDecoration({BoxShape shape = BoxShape.rectangle, BorderRadius? radius, Color color = AppColors.glass}) {
  return BoxDecoration(
    color: color,
    shape: shape,
    borderRadius: shape == BoxShape.circle ? null : (radius ?? BorderRadius.circular(AppTokens.rFull)),
    border: Border.all(color: AppColors.glassLine),
  );
}

/// Round 36dp (48dp hit area) icon button over the video.
class OverlayIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final double size;
  final double iconSize;

  const OverlayIconButton({super.key, required this.icon, required this.tooltip, required this.onPressed, this.size = 36, this.iconSize = 20});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: tooltip,
        child: SizedBox(
          width: 48,
          height: 48,
          child: Center(
            child: Material(
              color: Colors.transparent,
              shape: const CircleBorder(),
              clipBehavior: Clip.antiAlias,
              child: Ink(
                width: size,
                height: size,
                decoration: overlayDecoration(shape: BoxShape.circle),
                child: InkWell(
                  onTap: onPressed,
                  child: Icon(icon, color: AppColors.playerInk, size: iconSize),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Pill over the video showing a value (speed "1.25×", quality "720p HD").
class OverlayChip extends StatelessWidget {
  final String label;
  final String tooltip;
  final VoidCallback onPressed;

  /// Small orange tag after the label ("HD", "FHD").
  final String? tag;

  const OverlayChip({super.key, required this.label, required this.tooltip, required this.onPressed, this.tag});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: '$tooltip $label',
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Material(
            color: Colors.transparent,
            shape: const StadiumBorder(),
            clipBehavior: Clip.antiAlias,
            child: Ink(
              height: 36,
              decoration: overlayDecoration(),
              child: InkWell(
                onTap: onPressed,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: AppTokens.s12),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        label,
                        textDirection: TextDirection.ltr,
                        style: const TextStyle(color: AppColors.playerInk, fontWeight: FontWeight.w800, fontSize: 12.5),
                      ),
                      if (tag != null) ...[const SizedBox(width: 3), QualityTag(label: tag!, compact: true)],
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Orange "HD" / "FHD" tag.
class QualityTag extends StatelessWidget {
  final String label;
  final bool compact;

  const QualityTag({super.key, required this.label, this.compact = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: compact ? 3 : 6, vertical: compact ? 0 : 2),
      decoration: BoxDecoration(color: AppColors.accent, borderRadius: BorderRadius.circular(compact ? 3 : 4)),
      child: Text(
        label,
        textDirection: TextDirection.ltr,
        style: TextStyle(color: AppColors.playerInk, fontSize: compact ? 8 : 10, fontWeight: FontWeight.w800, height: 1.4),
      ),
    );
  }
}

/// "HD" for 720p, "FHD" for 1080p and up, nothing below.
String? qualityTagFor(String quality) {
  final int? height = int.tryParse(quality.replaceAll(RegExp(r'[^0-9]'), ''));
  if (height == null) return null;
  if (height >= 1080) return 'FHD';
  if (height >= 720) return 'HD';
  return null;
}
