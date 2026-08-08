import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/colors_manager.dart';
import '../theme/text_styles.dart';

class CustomTextField extends StatelessWidget {
  final String? title;
  final TextStyle? titleStyle;
  final String hintText;
  final TextStyle? hintStyle;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final void Function()? onTap;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputType? keyboardType;
  final TextInputAction? textInputAction;
  final List<TextInputFormatter>? inputFormatters;
  final bool obscureText;
  final bool readOnly;
  final bool enabled;
  final int maxLines;
  final int? minLines;
  final int? maxLength;
  final bool autofocus;
  final TextAlign textAlign;
  final EdgeInsetsGeometry? contentPadding;
  final Color? fillColor;
  final double? borderRadius;
  final Color? borderColor;
  final double borderWidth;
  final TextAlignVertical textAlignVertical;
  final BoxConstraints? suffixIconConstraints;
  final BoxConstraints? prefixIconConstraints;

  const CustomTextField({
    super.key,
    this.title,
    this.titleStyle,
    required this.hintText,
    this.hintStyle,
    required this.controller,
    this.focusNode,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.onTap,
    this.prefixIcon,
    this.suffixIcon,
    this.keyboardType,
    this.textInputAction,
    this.inputFormatters,
    this.obscureText = false,
    this.readOnly = false,
    this.enabled = true,
    this.maxLines = 1,
    this.minLines,
    this.maxLength,
    this.autofocus = false,
    this.textAlign = TextAlign.start,
    this.contentPadding,
    this.fillColor,
    this.borderRadius,
    this.borderColor,
    this.borderWidth = 1.5,
    this.textAlignVertical = TextAlignVertical.center,
    this.suffixIconConstraints,
    this.prefixIconConstraints,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (title != null) ...[
          Text(title!, style: titleStyle ?? TextStyles.font14BlackMedium),
          const SizedBox(height: 8),
        ],
        TextFormField(
          controller: controller,
          focusNode: focusNode,
          validator: validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          onChanged: onChanged,
          onFieldSubmitted: onFieldSubmitted,
          onTap: onTap,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          inputFormatters: inputFormatters,
          obscureText: obscureText,
          readOnly: readOnly,
          enabled: enabled,
          maxLines: maxLines,
          minLines: minLines,
          maxLength: maxLength,
          autofocus: autofocus,
          textAlign: textAlign,
          style: hintStyle ?? TextStyles.font16Black60OpacityRegular,
          textAlignVertical: textAlignVertical,
          cursorColor: ColorsManager.primary,
          cursorHeight: hintStyle?.fontSize ?? 16,
          onTapOutside: (_) => FocusManager.instance.primaryFocus?.unfocus(),
          decoration: InputDecoration(
            hintText: hintText,
            hintStyle: hintStyle ?? TextStyles.font16Black60OpacityRegular,
            contentPadding: contentPadding ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            suffixIcon: suffixIcon != null
                ? Padding(
                    padding: const EdgeInsetsDirectional.only(end: 12),
                    child: suffixIcon,
                  )
                : null,
            suffixIconConstraints: suffixIconConstraints ?? const BoxConstraints(minWidth: 36, maxWidth: 42),
            prefixIcon: prefixIcon,
            prefixIconConstraints: prefixIconConstraints ?? const BoxConstraints(minWidth: 36, maxWidth: 42),
            filled: true,
            fillColor: fillColor ?? ColorsManager.lightGrey,
            enabledBorder: _buildBorder(
              borderColor ?? ColorsManager.transparent,
              borderWidth,
            ),
            focusedBorder: _buildBorder(ColorsManager.primary, borderWidth),
            errorBorder: _buildBorder(ColorsManager.red, borderWidth),
            focusedErrorBorder: _buildBorder(ColorsManager.red, borderWidth),
            disabledBorder: _buildBorder(
              ColorsManager.transparent,
              borderWidth,
            ),
            errorMaxLines: 2,
            errorStyle: TextStyles.font12RedRegular,
          ),
        ),
      ],
    );
  }

  OutlineInputBorder _buildBorder(Color color, double width) {
    return OutlineInputBorder(
      borderRadius: BorderRadius.circular(borderRadius ?? 16),
      borderSide: BorderSide(color: color, width: width),
    );
  }
}
