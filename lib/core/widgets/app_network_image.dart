import 'package:cached_network_image_ce/cached_network_image.dart';
import 'package:flutter/material.dart';

import 'shimmer_loading.dart';

class AppNetworkImage extends StatelessWidget {
  final String url;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BoxShape shape;
  final BorderRadiusGeometry? borderRadius;
  final Widget? errorWidget;

  const AppNetworkImage({
    super.key,
    required this.url,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.shape = BoxShape.rectangle,
    this.borderRadius,
    this.errorWidget,
  });

  @override
  Widget build(BuildContext context) {
    final Widget image = CachedNetworkImage(
      imageUrl: url,
      width: width,
      height: height,
      fit: fit,
      placeholder: (_, _) => ShimmerLoading(
        width: width ?? double.infinity,
        height: height ?? double.infinity,
        borderRadius: borderRadius,
      ),
      errorBuilder: (_, _, _) =>
          errorWidget ??
          Icon(
            Icons.broken_image_outlined,
            size: (width != null && height != null) ? (width! < height! ? width! : height!) * 0.5 : 24,
            color: Colors.grey,
          ),
    );

    if (shape == BoxShape.circle) {
      return ClipOval(child: image);
    }

    if (borderRadius != null) {
      return ClipRRect(borderRadius: borderRadius!, child: image);
    }

    return image;
  }
}
