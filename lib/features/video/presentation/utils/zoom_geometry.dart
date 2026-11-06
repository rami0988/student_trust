import 'dart:math' as math;

import 'package:flutter/widgets.dart';

/// Where the student is zoomed, in a form the UI can reason about: a scale
/// (1–4×) and the centre of the visible area as a fraction of the frame
/// (0,0 top-left … 1,1 bottom-right).
///
/// [InteractiveViewer] stores the same thing as a matrix
/// (`screen = content × scale + translation`); this converts both ways so the
/// zoom rail, the slider, the presets and the mini-map can all drive it.
@immutable
class ZoomGeometry {
  static const double minScale = 1;
  static const double maxScale = 4;

  final double scale;

  /// Centre of the visible area, normalised to the frame.
  final Offset center;

  const ZoomGeometry._(this.scale, this.center);

  /// A geometry with [scale] clamped to 1–4× and [center] clamped so the
  /// visible area never leaves the frame.
  factory ZoomGeometry({required double scale, Offset center = const Offset(0.5, 0.5)}) {
    final double s = scale.clamp(minScale, maxScale);
    final double half = 0.5 / s;
    return ZoomGeometry._(s, Offset(center.dx.clamp(half, 1 - half), center.dy.clamp(half, 1 - half)));
  }

  static final ZoomGeometry identity = ZoomGeometry(scale: 1);

  /// Reads an [InteractiveViewer] matrix for a viewport of [size].
  factory ZoomGeometry.fromMatrix(Matrix4 matrix, Size size) {
    final double s = math.max(matrix.getMaxScaleOnAxis(), minScale);
    if (size.isEmpty) return ZoomGeometry(scale: s);
    final translation = matrix.getTranslation();
    return ZoomGeometry(
      scale: s,
      center: Offset((size.width / 2 - translation.x) / (s * size.width), (size.height / 2 - translation.y) / (s * size.height)),
    );
  }

  /// The matrix that shows this geometry in a viewport of [size].
  Matrix4 toMatrix(Size size) {
    final double tx = size.width / 2 - center.dx * scale * size.width;
    final double ty = size.height / 2 - center.dy * scale * size.height;
    return Matrix4.identity()
      ..translateByDouble(tx, ty, 0, 1)
      ..scaleByDouble(scale, scale, 1, 1);
  }

  ZoomGeometry withScale(double newScale) => ZoomGeometry(scale: newScale, center: center);

  ZoomGeometry withCenter(Offset newCenter) => ZoomGeometry(scale: scale, center: newCenter);

  bool get isZoomed => scale > 1.01;

  /// The visible part of the frame, normalised (for the mini-map rectangle).
  Rect get visibleRect {
    final double size = 1 / scale;
    return Rect.fromCenter(center: center, width: size, height: size);
  }

  /// Share of the frame on screen: 1 at 1×, 1/4 at 2×, 1/16 at 4×.
  double get visibleFraction => 1 / (scale * scale);

  /// Slider position for this scale, 0 (1×) … 1 (4×).
  double get sliderValue => (scale - minScale) / (maxScale - minScale);

  static double scaleForSlider(double value) => minScale + value.clamp(0.0, 1.0) * (maxScale - minScale);

  /// Coarse horizontal/vertical position of the view: -1, 0 or 1 per axis
  /// (left/top, centre, right/bottom), for the "view position" readout.
  (int, int) get region {
    int bucket(double v) => v < 0.4 ? -1 : (v > 0.6 ? 1 : 0);
    return (bucket(center.dx), bucket(center.dy));
  }

  /// Short label like "2.4×".
  String get label {
    final double rounded = (scale * 10).round() / 10;
    final String text = rounded == rounded.roundToDouble() ? rounded.toStringAsFixed(0) : rounded.toStringAsFixed(1);
    return '$text×';
  }

  @override
  bool operator ==(Object other) => other is ZoomGeometry && other.scale == scale && other.center == center;

  @override
  int get hashCode => Object.hash(scale, center);
}
