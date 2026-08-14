import 'package:flutter/material.dart';

import 'app_motion.dart' show isReducedMotionEnabled;

/// Wraps [child] with a horizontal shake it can play on demand — attention
/// feedback for a failed action (a tapped retry button, a rejected form).
/// Call [ShakeWidgetState.shake] via a [GlobalKey], or use [ShakeOnSignal]
/// below to trigger it from state instead of an imperative handle. A no-op
/// when the OS "reduce motion" setting is on.
class ShakeWidget extends StatefulWidget {
  final Widget child;
  final double extent;
  final Duration duration;

  const ShakeWidget({super.key, required this.child, this.extent = 8, this.duration = const Duration(milliseconds: 400)});

  @override
  State<ShakeWidget> createState() => ShakeWidgetState();
}

class ShakeWidgetState extends State<ShakeWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(vsync: this, duration: widget.duration);
  late final Animation<double> _offset = TweenSequence<double>([
    TweenSequenceItem(tween: Tween(begin: 0, end: -1), weight: 1),
    TweenSequenceItem(tween: Tween(begin: -1.0, end: 1), weight: 2),
    TweenSequenceItem(tween: Tween(begin: 1.0, end: -1), weight: 2),
    TweenSequenceItem(tween: Tween(begin: -1.0, end: 0), weight: 1),
  ]).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

  /// Plays the shake once. Safe to call repeatedly — restarts from zero.
  void shake() {
    if (isReducedMotionEnabled) return;
    _controller.forward(from: 0);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _offset,
      builder: (context, child) => Transform.translate(offset: Offset(_offset.value * widget.extent, 0), child: child),
      child: widget.child,
    );
  }
}

/// Declarative alternative to [ShakeWidgetState.shake]: bump [signal] (e.g. a
/// counter incremented in a cubit listener) each time the child should shake.
class ShakeOnSignal extends StatefulWidget {
  final Widget child;
  final Object? signal;

  const ShakeOnSignal({super.key, required this.child, required this.signal});

  @override
  State<ShakeOnSignal> createState() => _ShakeOnSignalState();
}

class _ShakeOnSignalState extends State<ShakeOnSignal> {
  final GlobalKey<ShakeWidgetState> _key = GlobalKey<ShakeWidgetState>();

  @override
  void didUpdateWidget(covariant ShakeOnSignal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.signal != oldWidget.signal) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _key.currentState?.shake());
    }
  }

  @override
  Widget build(BuildContext context) => ShakeWidget(key: _key, child: widget.child);
}
