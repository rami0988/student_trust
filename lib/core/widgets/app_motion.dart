import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../theme/app_tokens.dart';

/// ثقة (Thiqa) shared motion primitives. Ported from front_student_app's
/// core/widgets/app_motion.dart (see [[unified-design-system]] memory), with
/// added support for the OS "reduce motion" accessibility setting.

/// True when the platform's "reduce motion" accessibility setting is on.
/// Checked once per widget build rather than via `MediaQuery.of` so it's
/// safe to read in `initState` (no InheritedWidget dependency timing).
bool get isReducedMotionEnabled => SchedulerBinding.instance.platformDispatcher.accessibilityFeatures.disableAnimations;

/// Fades + slides its child up into place once, when first built.
///
/// Use with a per-item [delay] (e.g. `index * 40ms`) to build staggered list
/// entrances. Purely presentational: the child is always laid out, only
/// opacity/offset animate. Skips the delay and animation entirely when the
/// OS "reduce motion" setting is on — the child is shown immediately.
class FadeSlideIn extends StatefulWidget {
  final Widget child;
  final Duration delay;
  final Duration duration;
  final Offset beginOffset;

  const FadeSlideIn({
    super.key,
    required this.child,
    this.delay = Duration.zero,
    this.duration = AppTokens.dSlow,
    this.beginOffset = const Offset(0, 0.08),
  });

  /// Convenience for staggered lists: delay grows with [index], capped so
  /// long lists don't take seconds to settle.
  factory FadeSlideIn.staggered({Key? key, required int index, required Widget child}) {
    final int ms = (index.clamp(0, 12)) * 50;
    return FadeSlideIn(key: key, delay: Duration(milliseconds: ms), child: child);
  }

  @override
  State<FadeSlideIn> createState() => _FadeSlideInState();
}

class _FadeSlideInState extends State<FadeSlideIn> with SingleTickerProviderStateMixin {
  late final bool _reducedMotion = isReducedMotionEnabled;
  late final AnimationController _controller = AnimationController(vsync: this, duration: widget.duration, value: _reducedMotion ? 1 : 0);
  late final CurvedAnimation _curved = CurvedAnimation(parent: _controller, curve: AppTokens.curve);

  @override
  void initState() {
    super.initState();
    if (_reducedMotion) return;
    if (widget.delay == Duration.zero) {
      _controller.forward();
    } else {
      Future<void>.delayed(widget.delay, () {
        if (mounted) _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _curved.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _curved,
      child: SlideTransition(position: Tween<Offset>(begin: widget.beginOffset, end: Offset.zero).animate(_curved), child: widget.child),
    );
  }
}

/// Scales its child down slightly while pressed — a tactile micro-interaction
/// for cards and tiles. Wraps (does not replace) the child's own `onTap`.
/// The scale transition is instant (no animated tween) when the OS "reduce
/// motion" setting is on, so the press feedback stays but doesn't move.
class PressableScale extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double pressedScale;

  const PressableScale({super.key, required this.child, this.onTap, this.onLongPress, this.pressedScale = 0.96});

  @override
  State<PressableScale> createState() => _PressableScaleState();
}

class _PressableScaleState extends State<PressableScale> {
  bool _pressed = false;

  void _setPressed(bool value) {
    if (_pressed != value) setState(() => _pressed = value);
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: (_) => _setPressed(true),
      onTapCancel: () => _setPressed(false),
      onTapUp: (_) => _setPressed(false),
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: AnimatedScale(
        scale: _pressed ? widget.pressedScale : 1,
        duration: isReducedMotionEnabled ? Duration.zero : AppTokens.dFast,
        curve: Curves.easeOut,
        child: widget.child,
      ),
    );
  }
}
