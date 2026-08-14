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
    // Decode at the actual rendered pixel size rather than the source
    // resolution — cuts decode cost/memory a lot for large CDN thumbnails
    // shown in small cards. Falls back to the constraints LayoutBuilder
    // hands this widget when width/height weren't given explicitly (e.g. an
    // AppNetworkImage filling an AspectRatio or a Hero banner).
    return LayoutBuilder(
      builder: (context, constraints) {
        final double dpr = MediaQuery.devicePixelRatioOf(context);
        final double? renderWidth = width ?? (constraints.hasBoundedWidth ? constraints.maxWidth : null);
        final double? renderHeight = height ?? (constraints.hasBoundedHeight ? constraints.maxHeight : null);

        final Widget image = CachedNetworkImage(
          imageUrl: url,
          width: width,
          height: height,
          fit: fit,
          memCacheWidth: renderWidth != null ? (renderWidth * dpr).round() : null,
          memCacheHeight: renderHeight != null ? (renderHeight * dpr).round() : null,
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
      },
    );
  }
}
