import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../theme/colors_manager.dart';

class ShimmerLoading extends StatelessWidget {
  final Color? baseColor;
  final Color? highlightColor;
  final EdgeInsetsGeometry margin;
  final BorderRadiusGeometry? borderRadius;
  final double width;
  final double height;
  final BoxShape boxShape;

  const ShimmerLoading({
    super.key,
    this.baseColor,
    this.highlightColor,
    this.width = double.infinity,
    this.height = double.infinity,
    this.margin = EdgeInsets.zero,
    this.boxShape = BoxShape.rectangle,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: baseColor ?? ColorsManager.lightGrey,
      highlightColor: highlightColor ?? ColorsManager.white,
      direction: ShimmerDirection.ttb,
      child: Container(
        width: width,
        height: height,
        margin: margin,
        decoration: BoxDecoration(
          borderRadius: borderRadius,
          color: baseColor ?? ColorsManager.primary,
          shape: boxShape,
        ),
      ),
    );
  }
}
