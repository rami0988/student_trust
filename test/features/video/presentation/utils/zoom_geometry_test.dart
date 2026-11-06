import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_template/features/video/presentation/utils/zoom_geometry.dart';

void main() {
  const Size viewport = Size(400, 225);

  group('ZoomGeometry', () {
    test('clamps scale to 1–4×', () {
      expect(ZoomGeometry(scale: 0.5).scale, 1);
      expect(ZoomGeometry(scale: 9).scale, 4);
    });

    test('keeps the visible area inside the frame', () {
      // At 2× the view is half the frame, so its centre can't go past 0.25/0.75.
      final ZoomGeometry g = ZoomGeometry(scale: 2, center: const Offset(0.95, 0.05));
      expect(g.center, const Offset(0.75, 0.25));
      expect(g.visibleRect.left, closeTo(0.5, 1e-9));
      expect(g.visibleRect.top, closeTo(0, 1e-9));
    });

    test('matrix round-trips through InteractiveViewer form', () {
      final ZoomGeometry g = ZoomGeometry(scale: 2.4, center: const Offset(0.72, 0.7));
      final ZoomGeometry back = ZoomGeometry.fromMatrix(g.toMatrix(viewport), viewport);
      expect(back.scale, closeTo(2.4, 1e-9));
      expect(back.center.dx, closeTo(0.72, 1e-9));
      expect(back.center.dy, closeTo(0.7, 1e-9));
    });

    test('identity matrix is 1× centred', () {
      final ZoomGeometry g = ZoomGeometry.fromMatrix(Matrix4.identity(), viewport);
      expect(g.scale, 1);
      expect(g.center, const Offset(0.5, 0.5));
      expect(g.isZoomed, isFalse);
    });

    test('changing scale keeps the centre where possible', () {
      final ZoomGeometry g = ZoomGeometry(scale: 4, center: const Offset(0.8, 0.8)).withScale(2);
      expect(g.scale, 2);
      expect(g.center, const Offset(0.75, 0.75)); // re-clamped for the bigger view
    });

    test('visible fraction and slider value', () {
      expect(ZoomGeometry(scale: 2).visibleFraction, 0.25);
      expect(ZoomGeometry(scale: 1).sliderValue, 0);
      expect(ZoomGeometry(scale: 4).sliderValue, 1);
      expect(ZoomGeometry.scaleForSlider(0.5), 2.5);
      expect(ZoomGeometry.scaleForSlider(3), 4);
    });

    test('region buckets the view into left/centre/right and top/centre/bottom', () {
      expect(ZoomGeometry(scale: 3, center: const Offset(0.8, 0.8)).region, (1, 1));
      expect(ZoomGeometry(scale: 3, center: const Offset(0.2, 0.5)).region, (-1, 0));
      expect(ZoomGeometry(scale: 1).region, (0, 0));
    });

    test('label shows one decimal only when needed', () {
      expect(ZoomGeometry(scale: 2).label, '2×');
      expect(ZoomGeometry(scale: 2.4).label, '2.4×');
      expect(ZoomGeometry(scale: 2.44).label, '2.4×');
    });
  });
}
