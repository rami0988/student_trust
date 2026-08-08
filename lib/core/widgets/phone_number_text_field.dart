import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../generated/l10n.dart';
import '../utils/app_validator.dart';
import '../utils/language_helper.dart';
import 'custom_country_code_picker.dart';
import 'custom_text_field.dart';

class PhoneNumberTextField extends StatelessWidget {
  final String? title;
  final TextStyle? titleStyle;
  final String? hintText;
  final TextStyle? hintStyle;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final String? Function(String?)? validator;
  final void Function(String)? onChanged;
  final void Function(String)? onFieldSubmitted;
  final void Function()? onTap;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final TextInputAction? textInputAction;
  final bool obscureText;
  final bool readOnly;
  final bool enabled;
  final bool autofocus;
  final TextAlign textAlign;
  final EdgeInsetsGeometry? contentPadding;
  final Color? fillColor;
  final double? borderRadius;
  final Color? borderColor;
  final double borderWidth;
  final TextAlignVertical textAlignVertical;
  final void Function(String) onCountryCodeChanged;
  final String countryCode;

  const PhoneNumberTextField({
    super.key,
    required this.controller,
    required this.countryCode,
    required this.onCountryCodeChanged,
    this.title,
    this.titleStyle,
    this.hintText,
    this.hintStyle,
    this.focusNode,
    this.validator,
    this.onChanged,
    this.onFieldSubmitted,
    this.onTap,
    this.prefixIcon,
    this.suffixIcon,
    this.textInputAction,
    this.obscureText = false,
    this.readOnly = false,
    this.enabled = true,
    this.autofocus = false,
    this.textAlign = TextAlign.start,
    this.contentPadding,
    this.fillColor,
    this.borderRadius,
    this.borderColor,
    this.borderWidth = 1.3,
    this.textAlignVertical = TextAlignVertical.center,
  });

  @override
  Widget build(BuildContext context) {
    return CustomTextField(
      title: title ?? S.of(context).phoneNumber,
      titleStyle: titleStyle,
      hintText: hintText ?? (countryCode == '+963' ? '09xxxxxxxx' : S.of(context).phoneNumber),
      hintStyle: hintStyle,
      controller: controller,
      focusNode: focusNode,
      validator: validator ?? (value) => AppValidator.phoneNumberValidator(value, countryCode),
      onChanged: onChanged,
      onFieldSubmitted: onFieldSubmitted,
      onTap: onTap,
      prefixIcon: LanguageHelper.isEnglishLocale(context)
          ? CustomCountryCodePicker(
              onChanged: onCountryCodeChanged,
              countryCode: countryCode,
            )
          : null,
      suffixIcon: LanguageHelper.isEnglishLocale(context)
          ? null
          : CustomCountryCodePicker(
              onChanged: onCountryCodeChanged,
              countryCode: countryCode,
            ),
      prefixIconConstraints: const BoxConstraints(
        minWidth: 134,
        maxWidth: 142,
        maxHeight: 56,
        minHeight: 56,
      ),
      suffixIconConstraints: const BoxConstraints(
        minWidth: 146,
        maxWidth: 154,
        maxHeight: 56,
        minHeight: 56,
      ),
      keyboardType: TextInputType.phone,
      textInputAction: textInputAction,
      inputFormatters: [
        LengthLimitingTextInputFormatter(countryCode == '+963' ? 10 : 15),
        FilteringTextInputFormatter.digitsOnly,
      ],
      obscureText: obscureText,
      readOnly: readOnly,
      enabled: enabled,
      autofocus: autofocus,
      textAlign: textAlign,
      contentPadding: contentPadding,
      fillColor: fillColor,
      borderRadius: borderRadius,
      borderColor: borderColor,
      borderWidth: borderWidth,
      textAlignVertical: textAlignVertical,
    );
  }
}
