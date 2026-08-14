import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
import 'app_motion.dart' show isReducedMotionEnabled;

/// ثقة (Thiqa) shared skeleton-loading primitives (dependency-free shimmer).
/// Ported from front_student_app's core/widgets/shimmer.dart (see
/// [[unified-design-system]] memory).

/// Animates a light sweep across all [ShimmerBox] descendants. Renders as a
/// static (non-animated) skeleton when the OS "reduce motion" setting is on
/// — a continuously-looping sweep is exactly the kind of motion that setting
/// exists to suppress.
class Shimmer extends StatefulWidget {
  final Widget child;
  const Shimmer({super.key, required this.child});

  @override
  State<Shimmer> createState() => _ShimmerState();
}

class _ShimmerState extends State<Shimmer> with SingleTickerProviderStateMixin {
  late final bool _reducedMotion = isReducedMotionEnabled;
  AnimationController? _controller;

  @override
  void initState() {
    super.initState();
    if (!_reducedMotion) {
      _controller = AnimationController(vsync: this, duration: const Duration(milliseconds: 1400))..repeat();
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final AnimationController? controller = _controller;
    if (controller == null) return widget.child;
    return AnimatedBuilder(
      animation: controller,
      builder: (context, child) {
        final double t = controller.value;
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
              colors: const [AppColors.shimmer, AppColors.shimmerHighlight, AppColors.shimmer],
              stops: const [0.25, 0.5, 0.75],
              transform: _SlideGradientTransform(t * 2 - 1),
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

class _SlideGradientTransform extends GradientTransform {
  final double percent;
  const _SlideGradientTransform(this.percent);

  @override
  Matrix4? transform(Rect bounds, {TextDirection? textDirection}) {
    return Matrix4.translationValues(bounds.width * percent, 0, 0);
  }
}

/// A grey placeholder block; combine inside a [Shimmer] for loading skeletons.
class ShimmerBox extends StatelessWidget {
  final double? width;
  final double height;
  final BorderRadius? borderRadius;
  final BoxShape shape;

  const ShimmerBox({super.key, this.width, required this.height, this.borderRadius, this.shape = BoxShape.rectangle});

  const ShimmerBox.circle({super.key, required double size}) : width = size, height = size, borderRadius = null, shape = BoxShape.circle;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppColors.shimmer,
        shape: shape,
        borderRadius: shape == BoxShape.circle ? null : (borderRadius ?? AppTokens.radiusSM),
      ),
    );
  }
}

/// Ready-made skeleton for list screens: N card-shaped rows with an avatar,
/// title and subtitle placeholder.
class SkeletonListLoader extends StatelessWidget {
  final int itemCount;
  final double itemHeight;
  final EdgeInsetsGeometry padding;

  const SkeletonListLoader({super.key, this.itemCount = 6, this.itemHeight = 84, this.padding = const EdgeInsets.all(AppTokens.s16)});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: ListView.separated(
        padding: padding,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: itemCount,
        separatorBuilder: (_, _) => const SizedBox(height: AppTokens.s12),
        itemBuilder: (_, _) => Container(
          height: itemHeight,
          padding: const EdgeInsets.all(AppTokens.s16),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: AppTokens.radiusLG),
          child: const Row(
            children: [
              ShimmerBox.circle(size: 46),
              SizedBox(width: AppTokens.s12),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [ShimmerBox(width: 160, height: 14), SizedBox(height: AppTokens.s8), ShimmerBox(width: 100, height: 11)],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Ready-made skeleton for card-grid screens (e.g. subjects).
class SkeletonGridLoader extends StatelessWidget {
  final int itemCount;
  final int crossAxisCount;
  final double childAspectRatio;

  const SkeletonGridLoader({super.key, this.itemCount = 6, this.crossAxisCount = 2, this.childAspectRatio = 1.1});

  @override
  Widget build(BuildContext context) {
    return Shimmer(
      child: GridView.builder(
        padding: const EdgeInsets.all(AppTokens.s16),
        physics: const NeverScrollableScrollPhysics(),
        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: crossAxisCount,
          childAspectRatio: childAspectRatio,
          crossAxisSpacing: AppTokens.s12,
          mainAxisSpacing: AppTokens.s12,
        ),
        itemCount: itemCount,
        itemBuilder: (_, _) => Container(
          padding: const EdgeInsets.all(AppTokens.s16),
          decoration: BoxDecoration(color: AppColors.surface, borderRadius: AppTokens.radiusLG),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ShimmerBox.circle(size: 42),
              Spacer(),
              ShimmerBox(width: 110, height: 14),
              SizedBox(height: AppTokens.s8),
              ShimmerBox(width: 70, height: 11),
            ],
          ),
        ),
      ),
    );
  }
}
