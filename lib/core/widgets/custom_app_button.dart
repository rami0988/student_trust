import 'package:flutter/material.dart';

import '../extensions/strings.dart';
import '../theme/colors_manager.dart';
import '../theme/text_styles.dart';
import 'loader.dart';

class CustomAppButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final double? width;
  final double height;
  final double elevation;
  final List<BoxShadow>? shadow;
  final List<Color>? gradient;
  final TextStyle? textStyle;
  final Color? backgroundColor;
  final BorderRadius? borderRadius;
  final bool isLoading;
  final bool isEnabled;
  final AlignmentGeometry gradientBegin;
  final AlignmentGeometry gradientEnd;
  final BoxBorder? border;
  final Widget? icon;
  final double iconSpacing;
  final MainAxisAlignment contentAlignment;
  final Color? disabledBackgroundColor;

  const CustomAppButton({
    super.key,
    required this.text,
    this.onPressed,
    this.width = double.infinity,
    this.height = 48,
    this.elevation = 0,
    this.shadow,
    this.gradient,
    this.textStyle,
    this.backgroundColor,
    this.borderRadius,
    this.isLoading = false,
    this.isEnabled = true,
    this.gradientBegin = Alignment.topCenter,
    this.gradientEnd = Alignment.bottomCenter,
    this.border,
    this.icon,
    this.iconSpacing = 8,
    this.contentAlignment = MainAxisAlignment.center,
    this.disabledBackgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final BorderRadius resolvedRadius = borderRadius ?? BorderRadius.circular(20);
    final bool isInteractive = isEnabled && !isLoading;

    return Opacity(
      opacity: isEnabled ? 1.0 : 0.5,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: gradient == null ? (backgroundColor ?? ColorsManager.primary) : ColorsManager.transparent,
          borderRadius: resolvedRadius,
          gradient: gradient != null
              ? LinearGradient(
                  colors: gradient!,
                  begin: gradientBegin,
                  end: gradientEnd,
                )
              : null,
          border: border,
          boxShadow: isEnabled ? shadow : null,
        ),
        child: ElevatedButton(
          onPressed: isInteractive ? onPressed : null,
          style: ElevatedButton.styleFrom(
            elevation: elevation,
            shadowColor: ColorsManager.transparent,
            backgroundColor: gradient != null ? ColorsManager.transparent : (backgroundColor ?? ColorsManager.primary),
            disabledBackgroundColor: disabledBackgroundColor,
            minimumSize: Size(width ?? double.infinity, height),
            shape: RoundedRectangleBorder(borderRadius: resolvedRadius),
            padding: EdgeInsets.zero,
          ),
          child: isLoading
              ? SizedBox(
                  width: 24,
                  height: 24,
                  child: Loader(
                    size: 24,
                    color: textStyle?.color ?? ColorsManager.primary,
                  ),
                )
              : Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: contentAlignment,
                  spacing: iconSpacing,
                  children: [
                    ?icon,
                    if (!text.isNullOrEmpty())
                      Flexible(
                        child: Text(
                          text,
                          style: textStyle ?? TextStyles.font16PrimaryMedium,
                          maxLines: 1,
                          textScaler: const TextScaler.linear(1.0),
                        ),
                      ),
                  ],
                ),
        ),
      ),
    );
  }
}
