import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../entities/media.dart';
import '../utils/app_enums.dart';
import 'app_network_image.dart';

class MediaWidget extends StatelessWidget {
  final Media? media;
  final double? width;
  final double? height;
  final BoxFit fit;
  final BoxShape shape;
  final BorderRadiusGeometry? borderRadius;
  final Widget? errorWidget;
  final Widget? nullMediaWidget;
  final Color? svgColor;

  const MediaWidget({
    super.key,
    required this.media,
    this.width,
    this.height,
    this.fit = BoxFit.contain,
    this.shape = BoxShape.rectangle,
    this.borderRadius,
    this.nullMediaWidget,
    this.errorWidget,
    this.svgColor,
  });

  @override
  Widget build(BuildContext context) {
    if (media == null) {
      return nullMediaWidget ??
          Icon(
            Icons.broken_image_outlined,
            size: (width != null && height != null) ? (width! < height! ? width! : height!) * 0.5 : 24,
            color: Colors.grey,
          );
    }
    switch (media!.type) {
      case MediaType.icon:
        return SvgPicture.network(
          media!.url,
          width: width,
          height: height,
          fit: fit,
          colorFilter: svgColor != null ? ColorFilter.mode(svgColor!, BlendMode.srcIn) : null,
          placeholderBuilder: (BuildContext context) => SizedBox(width: width, height: height),
        );
      case MediaType.image:
        return AppNetworkImage(
          url: media!.url,
          width: width,
          height: height,
          fit: fit,
          shape: shape,
          borderRadius: borderRadius,
          errorWidget: errorWidget,
        );
      case MediaType.video:
      case MediaType.unknown:
        return errorWidget ??
            Icon(
              Icons.broken_image_outlined,
              size: (width != null && height != null) ? (width! < height! ? width! : height!) * 0.5 : 24,
              color: Colors.grey,
            );
    }
  }
}
