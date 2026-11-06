import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';

/// Seek bar: buffered range, played range, and a draggable thumb.
///
/// Media timelines are not mirrored for RTL (Material bidirectionality
/// guidance), so this always runs left → right. The seek is committed on
/// release; while dragging only the thumb moves, so a scrub doesn't fire a
/// burst of network seeks on a weak connection.
class PlayerTimeline extends StatefulWidget {
  final double played;
  final double buffered;
  final ValueChanged<double> onSeek;

  /// Called on drag start/end so the controls stay visible while scrubbing.
  final ValueChanged<bool>? onScrubbing;

  const PlayerTimeline({super.key, required this.played, required this.buffered, required this.onSeek, this.onScrubbing});

  @override
  State<PlayerTimeline> createState() => _PlayerTimelineState();
}

class _PlayerTimelineState extends State<PlayerTimeline> {
  double? _dragValue;

  double _fractionAt(Offset local, double width) => width <= 0 ? 0 : (local.dx / width).clamp(0.0, 1.0);

  @override
  Widget build(BuildContext context) {
    final double played = _dragValue ?? widget.played;
    return Directionality(
      textDirection: TextDirection.ltr,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final double width = constraints.maxWidth;
          return Semantics(
            slider: true,
            value: '${(played * 100).round()}%',
            child: GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTapUp: (d) => widget.onSeek(_fractionAt(d.localPosition, width)),
              onHorizontalDragStart: (d) {
                widget.onScrubbing?.call(true);
                setState(() => _dragValue = _fractionAt(d.localPosition, width));
              },
              onHorizontalDragUpdate: (d) => setState(() => _dragValue = _fractionAt(d.localPosition, width)),
              onHorizontalDragEnd: (_) {
                final double? value = _dragValue;
                setState(() => _dragValue = null);
                widget.onScrubbing?.call(false);
                if (value != null) widget.onSeek(value);
              },
              child: SizedBox(
                height: 24,
                child: Stack(
                  alignment: Alignment.centerLeft,
                  clipBehavior: Clip.none,
                  children: [
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      height: _dragValue != null ? 6 : 4,
                      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.22), borderRadius: BorderRadius.circular(3)),
                    ),
                    FractionallySizedBox(
                      widthFactor: widget.buffered.clamp(0.0, 1.0),
                      child: Container(
                        height: 4,
                        decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.38), borderRadius: BorderRadius.circular(3)),
                      ),
                    ),
                    FractionallySizedBox(
                      widthFactor: played.clamp(0.0, 1.0),
                      child: Container(
                        height: _dragValue != null ? 6 : 4,
                        decoration: BoxDecoration(gradient: AppGradients.brandHorizontal, borderRadius: BorderRadius.circular(3)),
                      ),
                    ),
                    Positioned(
                      left: (played.clamp(0.0, 1.0) * width) - 7,
                      child: Container(
                        width: 14,
                        height: 14,
                        decoration: BoxDecoration(
                          color: AppColors.playerInk,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(color: AppColors.primary.withValues(alpha: 0.35), spreadRadius: 4),
                            const BoxShadow(color: Colors.black45, blurRadius: 6, offset: Offset(0, 2)),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
