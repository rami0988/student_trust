import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

/// A semi-transparent, periodically-repositioned overlay showing the
/// student's identity over the video — a deterrent against screen recording
/// / re-sharing.
class VideoWatermark extends StatefulWidget {
  final String studentName;
  /// No longer shown: the watermark displays the student's name only. Kept so
  /// the existing call site doesn't change.
  final String phoneNumber;

  const VideoWatermark({super.key, required this.studentName, required this.phoneNumber});

  @override
  State<VideoWatermark> createState() => _VideoWatermarkState();
}

class _VideoWatermarkState extends State<VideoWatermark> {
  /// Subtle on purpose: ~10% white text over a faint shadow stays out of the
  /// way of teacher notes yet is still legible in a screen recording.
  ///
  /// The alpha lives in the colors rather than in an `Opacity` widget: Opacity
  /// forces an offscreen compositing layer every frame, which is wasteful for
  /// a label that glides across the video. The shadow is scaled with the text
  /// so it doesn't turn into a dark smudge at this transparency. Built once,
  /// so repositioning rebuilds reuse the same style.
  static final TextStyle _style = TextStyle(
    color: Colors.white.withValues(alpha: 0.10),
    fontSize: 14,
    fontWeight: FontWeight.w300,
    shadows: [Shadow(color: Colors.black.withValues(alpha: 0.10), blurRadius: 6, offset: const Offset(1, 1))],
  );

  Offset _position = const Offset(20, 50);
  Timer? _timer;
  Size _parentSize = const Size(300, 200);

  @override
  void initState() {
    super.initState();
    _timer = Timer.periodic(const Duration(seconds: 5), (_) {
      if (!mounted) return;
      setState(() => _position = _newRandomPosition());
    });
  }

  Offset _newRandomPosition() {
    final Random rng = Random();
    final double x = rng.nextDouble() * (_parentSize.width * 0.65);
    final double y = (_parentSize.height * 0.10) + rng.nextDouble() * (_parentSize.height * 0.70);
    return Offset(x, y);
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (ctx, constraints) {
        _parentSize = Size(constraints.maxWidth, constraints.maxHeight);
        return IgnorePointer(
          child: Stack(
            children: [
              AnimatedPositioned(
                duration: const Duration(milliseconds: 800),
                curve: Curves.easeInOut,
                left: _position.dx,
                top: _position.dy,
                child: Text(widget.studentName, style: _style),
              ),
            ],
          ),
        );
      },
    );
  }
}
