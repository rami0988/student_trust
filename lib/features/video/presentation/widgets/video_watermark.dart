import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

/// A semi-transparent, periodically-repositioned overlay showing the
/// student's identity over the video — a deterrent against screen recording
/// / re-sharing.
class VideoWatermark extends StatefulWidget {
  final String studentName;
  final String phoneNumber;

  const VideoWatermark({super.key, required this.studentName, required this.phoneNumber});

  @override
  State<VideoWatermark> createState() => _VideoWatermarkState();
}

class _VideoWatermarkState extends State<VideoWatermark> {
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
                child: Opacity(
                  opacity: 0.35,
                  child: Text(
                    '${widget.studentName} | ${widget.phoneNumber}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      shadows: [Shadow(color: Colors.black, blurRadius: 6, offset: Offset(1, 1))],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
