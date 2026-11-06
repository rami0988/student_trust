import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_gradients.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../generated/l10n.dart';
import '../utils/zoom_geometry.dart';
import 'player_chrome.dart';

/// "Right · Bottom", "Center", "Whole frame".
String zoomRegionLabel(S s, ZoomGeometry geometry) {
  if (!geometry.isZoomed) return s.zoomPosFull;
  final (int h, int v) = geometry.region;
  if (h == 0 && v == 0) return s.zoomPosCenter;
  final String? horizontal = h < 0 ? s.zoomPosLeft : (h > 0 ? s.zoomPosRight : null);
  final String? vertical = v < 0 ? s.zoomPosTop : (v > 0 ? s.zoomPosBottom : null);
  return [?horizontal, ?vertical].join(' · ');
}

/// Vertical zoom slider on the edge of the video: + at the top (4×),
/// − at the bottom (1×), draggable knob in between.
class ZoomRail extends StatelessWidget {
  final ZoomGeometry geometry;
  final ValueChanged<double> onScale;

  const ZoomRail({super.key, required this.geometry, required this.onScale});

  void _fromLocal(Offset local, double height) {
    if (height <= 0) return;
    final double fraction = 1 - (local.dy / height).clamp(0.0, 1.0);
    onScale(ZoomGeometry.scaleForSlider(fraction));
  }

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return Semantics(
      slider: true,
      label: s.zoomTitle,
      value: geometry.label,
      increasedValue: geometry.withScale(geometry.scale + 0.5).label,
      decreasedValue: geometry.withScale(geometry.scale - 0.5).label,
      onIncrease: () => onScale(geometry.scale + 0.5),
      onDecrease: () => onScale(geometry.scale - 0.5),
      child: Container(
        width: 40,
        padding: const EdgeInsets.symmetric(vertical: 4),
        decoration: overlayDecoration(),
        child: Column(
          children: [
            _RailButton(label: '+', tooltip: s.zoomIn, onTap: () => onScale(geometry.scale + 0.5)),
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final double h = constraints.maxHeight;
                  final double knob = geometry.sliderValue * h;
                  return GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (d) => _fromLocal(d.localPosition, h),
                    onVerticalDragUpdate: (d) => _fromLocal(d.localPosition, h),
                    child: SizedBox(
                      width: 40,
                      child: Stack(
                        alignment: Alignment.bottomCenter,
                        clipBehavior: Clip.none,
                        children: [
                          Container(
                            width: 4,
                            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.2), borderRadius: BorderRadius.circular(2)),
                          ),
                          Container(
                            width: 4,
                            height: knob,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(2),
                              gradient: const LinearGradient(
                                begin: Alignment.bottomCenter,
                                end: Alignment.topCenter,
                                colors: [AppColors.primary, AppColors.gradientEnd],
                              ),
                            ),
                          ),
                          Positioned(bottom: knob - 8, child: const _Knob(size: 16)),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            _RailButton(label: '−', tooltip: s.zoomOut, onTap: () => onScale(geometry.scale - 0.5)),
          ],
        ),
      ),
    );
  }
}

class _RailButton extends StatelessWidget {
  final String label;
  final String tooltip;
  final VoidCallback onTap;
  const _RailButton({required this.label, required this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkResponse(
        onTap: onTap,
        radius: 20,
        child: SizedBox(
          width: 40,
          height: 28,
          child: Center(
            child: Text(label, style: const TextStyle(color: AppColors.playerInk, fontSize: 17, fontWeight: FontWeight.w700, height: 1)),
          ),
        ),
      ),
    );
  }
}

class _Knob extends StatelessWidget {
  final double size;
  const _Knob({required this.size});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.playerInk,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: AppColors.primary.withValues(alpha: 0.4), spreadRadius: 4),
          const BoxShadow(color: Colors.black38, blurRadius: 8, offset: Offset(0, 2)),
        ],
      ),
    );
  }
}

/// Picture-in-picture map of the whole frame with the visible part outlined.
/// Tap or drag on it to move the zoomed view there.
///
/// [preview] is what to draw as the frame — the lesson thumbnail when there is
/// one. (The live video can't be drawn twice: it is a single platform texture.)
class ZoomMiniMap extends StatelessWidget {
  final ZoomGeometry geometry;
  final ValueChanged<Offset> onCenter;
  final Widget preview;

  const ZoomMiniMap({super.key, required this.geometry, required this.onCenter, required this.preview});

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return Container(
      width: 112,
      padding: const EdgeInsets.all(4),
      decoration: overlayDecoration(radius: BorderRadius.circular(10), color: AppColors.glassStrong),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          AspectRatio(
            aspectRatio: 16 / 9,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final Size size = constraints.biggest;
                  void move(Offset local) => onCenter(Offset(local.dx / size.width, local.dy / size.height));
                  final Rect view = geometry.visibleRect;
                  return Semantics(
                    label: s.zoomYourPosition,
                    value: zoomRegionLabel(s, geometry),
                    child: GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapDown: (d) => move(d.localPosition),
                      onPanUpdate: (d) => move(d.localPosition),
                      child: Stack(
                        children: [
                          Positioned.fill(child: Opacity(opacity: 0.85, child: preview)),
                          // Dim everything outside the visible rectangle.
                          Positioned.fill(
                            child: CustomPaint(painter: _ViewportPainter(view)),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(2, 4, 2, 0),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    s.zoomYourPosition,
                    style: const TextStyle(color: AppColors.playerInk2, fontSize: 9.5, fontWeight: FontWeight.w700),
                  ),
                ),
                Text(
                  geometry.label,
                  textDirection: TextDirection.ltr,
                  style: const TextStyle(color: AppColors.accentLight, fontSize: 9.5, fontWeight: FontWeight.w800),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ViewportPainter extends CustomPainter {
  final Rect view;
  _ViewportPainter(this.view);

  @override
  void paint(Canvas canvas, Size size) {
    final Rect r = Rect.fromLTRB(view.left * size.width, view.top * size.height, view.right * size.width, view.bottom * size.height);
    final Path outside = Path()
      ..fillType = PathFillType.evenOdd
      ..addRect(Offset.zero & size)
      ..addRRect(RRect.fromRectAndRadius(r, const Radius.circular(3)));
    canvas.drawPath(outside, Paint()..color = Colors.black.withValues(alpha: 0.45));
    canvas.drawRRect(
      RRect.fromRectAndRadius(r.inflate(1.5), const Radius.circular(4)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 3
        ..color = AppColors.gradientEnd.withValues(alpha: 0.45),
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(r, const Radius.circular(3)),
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5
        ..color = Colors.white,
    );
  }

  @override
  bool shouldRepaint(_ViewportPainter old) => old.view != view;
}

/// Zoom panel shown under the video (portrait) while zoomed: slider with
/// 1×–4× ticks, presets, readouts, gesture tips and the watermark note.
class ZoomPanel extends StatelessWidget {
  final ZoomGeometry geometry;
  final ValueChanged<double> onScale;

  const ZoomPanel({super.key, required this.geometry, required this.onScale});

  static const List<double> presets = [1, 1.5, 2, 3, 4];

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return Container(
      margin: const EdgeInsets.all(AppTokens.s16),
      padding: const EdgeInsets.all(AppTokens.s16),
      decoration: BoxDecoration(
        color: AppColors.playerSurface,
        borderRadius: AppTokens.radiusXL,
        border: Border.all(color: AppColors.playerLine),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(s.zoomTitle, style: const TextStyle(color: AppColors.playerInk, fontSize: 15, fontWeight: FontWeight.w800)),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: AppTokens.s8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.gradientEnd.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(AppTokens.rFull),
                ),
                child: Text(
                  s.zoomModeBadge,
                  style: const TextStyle(color: AppColors.gradientEnd, fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.s12),
          _ZoomSlider(geometry: geometry, onScale: onScale),
          const SizedBox(height: AppTokens.s12),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Row(
              children: [
                for (final double p in presets)
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 3),
                      child: _PresetButton(
                        label: ZoomGeometry(scale: p).label,
                        selected: (geometry.scale - p).abs() < 0.05,
                        onTap: () => onScale(p),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppTokens.s12),
          Row(
            children: [
              Expanded(child: _Stat(label: s.zoomVisibleArea, value: '${(geometry.visibleFraction * 100).round()}%')),
              const SizedBox(width: AppTokens.s8),
              Expanded(child: _Stat(label: s.zoomPosition, value: zoomRegionLabel(s, geometry))),
            ],
          ),
          const SizedBox(height: AppTokens.s12),
          Row(
            children: [
              Expanded(child: _Tip(icon: Icons.pinch_rounded, text: s.zoomTipPinch)),
              const SizedBox(width: AppTokens.s8),
              Expanded(child: _Tip(icon: Icons.open_with_rounded, text: s.zoomTipPan)),
              const SizedBox(width: AppTokens.s8),
              Expanded(child: _Tip(icon: Icons.map_outlined, text: s.zoomTipMap)),
            ],
          ),
          const SizedBox(height: AppTokens.s12),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: AppTokens.s12, vertical: AppTokens.s8 + 2),
            decoration: BoxDecoration(
              color: AppColors.accent.withValues(alpha: 0.08),
              borderRadius: AppTokens.radiusMD,
              border: Border.all(color: AppColors.accent.withValues(alpha: 0.2)),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Icon(Icons.verified_user_rounded, color: AppColors.accentLight, size: 18),
                const SizedBox(width: AppTokens.s8 + 2),
                Expanded(
                  child: Text(s.zoomWatermarkNote, style: const TextStyle(color: AppColors.playerInk2, fontSize: 12, height: 1.5)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ZoomSlider extends StatelessWidget {
  final ZoomGeometry geometry;
  final ValueChanged<double> onScale;
  const _ZoomSlider({required this.geometry, required this.onScale});

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Row(
        children: [
          _RoundButton(label: '−', tooltip: s.zoomOut, onTap: () => onScale(geometry.scale - 0.5)),
          const SizedBox(width: AppTokens.s8 + 2),
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                final double w = constraints.maxWidth;
                void set(Offset local) => onScale(ZoomGeometry.scaleForSlider(local.dx / w));
                return Semantics(
                  slider: true,
                  label: s.zoomTitle,
                  value: geometry.label,
                  increasedValue: geometry.withScale(geometry.scale + 0.1).label,
                  decreasedValue: geometry.withScale(geometry.scale - 0.1).label,
                  onIncrease: () => onScale(geometry.scale + 0.1),
                  onDecrease: () => onScale(geometry.scale - 0.1),
                  child: GestureDetector(
                    behavior: HitTestBehavior.opaque,
                    onTapDown: (d) => set(d.localPosition),
                    onHorizontalDragUpdate: (d) => set(d.localPosition),
                    child: SizedBox(
                      height: 44,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned(
                            left: 0,
                            right: 0,
                            top: 10,
                            child: Container(
                              height: 6,
                              decoration: BoxDecoration(color: AppColors.playerSurface2, borderRadius: BorderRadius.circular(3)),
                              alignment: Alignment.centerLeft,
                              child: FractionallySizedBox(
                                widthFactor: geometry.sliderValue,
                                child: Container(
                                  decoration: BoxDecoration(gradient: AppGradients.brandHorizontal, borderRadius: BorderRadius.circular(3)),
                                ),
                              ),
                            ),
                          ),
                          Positioned(left: geometry.sliderValue * w - 11, top: 2, child: const _Knob(size: 22)),
                          for (int i = 0; i < 4; i++)
                            Positioned(
                              left: (i / 3) * w - 12,
                              top: 26,
                              child: SizedBox(
                                width: 24,
                                child: Column(
                                  children: [
                                    Container(width: 1, height: 5, color: AppColors.playerInk3),
                                    Text(
                                      '${i + 1}×',
                                      style: const TextStyle(color: AppColors.playerInk3, fontSize: 10, fontWeight: FontWeight.w700),
                                    ),
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
          ),
          const SizedBox(width: AppTokens.s8 + 2),
          _RoundButton(label: '+', tooltip: s.zoomIn, onTap: () => onScale(geometry.scale + 0.5)),
          SizedBox(
            width: 48,
            child: Text(
              geometry.label,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.playerInk, fontSize: 15, fontWeight: FontWeight.w800),
            ),
          ),
        ],
      ),
    );
  }
}

class _RoundButton extends StatelessWidget {
  final String label;
  final String tooltip;
  final VoidCallback onTap;
  const _RoundButton({required this.label, required this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: AppColors.playerSurface2,
        shape: const CircleBorder(),
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: SizedBox(
            width: 40,
            height: 40,
            child: Center(
              child: Text(label, style: const TextStyle(color: AppColors.playerInk, fontSize: 20, fontWeight: FontWeight.w700)),
            ),
          ),
        ),
      ),
    );
  }
}

class _PresetButton extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;
  const _PresetButton({required this.label, required this.selected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      selected: selected,
      button: true,
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: AppTokens.radiusSM,
          child: AnimatedContainer(
            duration: AppTokens.dMed,
            height: 34,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: selected ? AppColors.primary.withValues(alpha: 0.18) : AppColors.playerBg,
              borderRadius: AppTokens.radiusSM,
              border: Border.all(color: selected ? AppColors.gradientEnd : AppColors.playerLine),
            ),
            child: Text(
              label,
              style: TextStyle(
                color: selected ? AppColors.playerInk : AppColors.playerInk2,
                fontSize: 12.5,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Stat extends StatelessWidget {
  final String label;
  final String value;
  const _Stat({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppTokens.s12, vertical: AppTokens.s8 + 2),
      decoration: BoxDecoration(
        color: AppColors.playerBg,
        borderRadius: AppTokens.radiusMD,
        border: Border.all(color: AppColors.playerLine),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: const TextStyle(color: AppColors.playerInk3, fontSize: 11)),
          Text(value, style: const TextStyle(color: AppColors.playerInk, fontSize: 15, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _Tip extends StatelessWidget {
  final IconData icon;
  final String text;
  const _Tip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: AppTokens.s8 + 2),
      decoration: BoxDecoration(
        color: AppColors.playerBg,
        borderRadius: AppTokens.radiusMD,
        border: Border.all(color: AppColors.playerLine),
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.gradientEnd, size: 20),
          const SizedBox(height: 6),
          Text(text, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.playerInk2, fontSize: 11, height: 1.35)),
        ],
      ),
    );
  }
}
