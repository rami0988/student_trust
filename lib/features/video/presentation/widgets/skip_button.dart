import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import 'player_chrome.dart';

/// "−10" / "+10" pill. The step is printed on the button so its effect is
/// obvious, and a short pulse confirms each tap.
class SkipButton extends StatefulWidget {
  /// Negative to go back, positive to go forward.
  final int seconds;
  final String tooltip;
  final VoidCallback onPressed;
  final bool large;

  const SkipButton({super.key, required this.seconds, required this.tooltip, required this.onPressed, this.large = false});

  @override
  State<SkipButton> createState() => _SkipButtonState();
}

class _SkipButtonState extends State<SkipButton> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(vsync: this, duration: AppTokens.dSlow);

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  void _tap() {
    _pulse.forward(from: 0);
    widget.onPressed();
  }

  @override
  Widget build(BuildContext context) {
    final bool back = widget.seconds < 0;
    final double height = widget.large ? 40 : 34;
    // The "forward" icon is the replay arrow mirrored.
    final Widget icon = Transform.flip(
      flipX: !back,
      child: Icon(Icons.replay_rounded, color: AppColors.playerInk, size: widget.large ? 20 : 18),
    );
    final Widget label = Text(
      back ? '−${widget.seconds.abs()}' : '+${widget.seconds}',
      style: TextStyle(color: AppColors.playerInk, fontWeight: FontWeight.w800, fontSize: widget.large ? 13.5 : 12.5),
    );

    return Tooltip(
      message: widget.tooltip,
      child: Semantics(
        button: true,
        label: widget.tooltip,
        excludeSemantics: true,
        child: Material(
          color: Colors.transparent,
          shape: const StadiumBorder(),
          clipBehavior: Clip.antiAlias,
          child: Ink(
            height: height,
            decoration: overlayDecoration(),
            child: InkWell(
              onTap: _tap,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned.fill(
                    child: AnimatedBuilder(
                      animation: _pulse,
                      builder: (context, _) {
                        if (!_pulse.isAnimating) return const SizedBox.shrink();
                        return Opacity(
                          opacity: 1 - _pulse.value,
                          child: Transform.scale(
                            scale: 0.6 + _pulse.value * 0.8,
                            child: DecoratedBox(
                              decoration: ShapeDecoration(color: AppColors.gradientEnd.withValues(alpha: 0.45), shape: const StadiumBorder()),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                  Container(
                    constraints: BoxConstraints(minWidth: widget.large ? 68 : 58),
                    padding: const EdgeInsets.symmetric(horizontal: AppTokens.s8 + 2),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: back ? [icon, const SizedBox(width: 4), label] : [label, const SizedBox(width: 4), icon],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
