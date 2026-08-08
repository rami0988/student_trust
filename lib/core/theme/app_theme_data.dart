import 'package:flutter/material.dart';

import '../extensions/colors.dart';
import '../utils/app_enums.dart';
import 'colors_manager.dart';
import 'text_styles.dart';

abstract class AppThemeData {
  AppThemeData._();

  static ThemeData appTheme(Language language) => ThemeData(
    colorScheme: const ColorScheme.light(
      primary: ColorsManager.primary,
      onPrimary: ColorsManager.white,
      outlineVariant: ColorsManager.darkGrey,
    ),
    scaffoldBackgroundColor: ColorsManager.white,
    iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(
        shape: const WidgetStatePropertyAll(CircleBorder()),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        overlayColor: WidgetStatePropertyAll(
          ColorsManager.primary.withOpacityValue(0.1),
        ),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 2),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        overlayColor: ColorsManager.primary,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(2)),
      ),
    ),
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: ColorsManager.primary,
      selectionColor: ColorsManager.primary.withOpacityValue(0.5),
      selectionHandleColor: ColorsManager.primary,
    ),
    // datePickerTheme: DatePickerThemeData(
    datePickerTheme: DatePickerThemeData(
      backgroundColor: ColorsManager.white,
      dayStyle: TextStyles.font16BlackRegular,
      headerHeadlineStyle: TextStyles.font30BlackMedium,
      headerHelpStyle: TextStyles.font16BlackMedium,
      yearStyle: TextStyles.font16BlackRegular,
      weekdayStyle: TextStyles.font16BlackRegular,
      rangePickerHeaderHelpStyle: TextStyles.font16BlackRegular,
      rangePickerHeaderHeadlineStyle: TextStyles.font16BlackRegular,
      dividerColor: ColorsManager.lightGrey,
      surfaceTintColor: ColorsManager.white,
      shadowColor: ColorsManager.lightGrey,
      rangePickerShadowColor: ColorsManager.lightGrey,
      elevation: 1,
      rangePickerElevation: 1,
      cancelButtonStyle: const ButtonStyle(
        textStyle: WidgetStatePropertyAll(TextStyles.font16BlackMedium),
        elevation: WidgetStatePropertyAll(1),
        foregroundColor: WidgetStatePropertyAll(ColorsManager.black),
        padding: WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        ),
        minimumSize: WidgetStatePropertyAll(Size.zero),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      confirmButtonStyle: const ButtonStyle(
        textStyle: WidgetStatePropertyAll(TextStyles.font16BlackMedium),
        elevation: WidgetStatePropertyAll(1),
        foregroundColor: WidgetStatePropertyAll(ColorsManager.primary),
        padding: WidgetStatePropertyAll(
          EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        ),
        minimumSize: WidgetStatePropertyAll(Size.zero),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      dayForegroundColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return ColorsManager.white;
        } else if (states.contains(WidgetState.disabled)) {
          return ColorsManager.grey;
        }
        return ColorsManager.black;
      }),
      dayBackgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return ColorsManager.primary;
        }
        return ColorsManager.transparent;
      }),
      todayBackgroundColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return ColorsManager.primary;
        }
        return ColorsManager.white;
      }),
      todayBorder: const BorderSide(color: ColorsManager.lightGrey),
      dayShape: const WidgetStatePropertyAll(
        CircleBorder(side: BorderSide.none),
      ),
      todayForegroundColor: WidgetStateProperty.resolveWith<Color>((states) {
        if (states.contains(WidgetState.selected)) {
          return ColorsManager.white;
        }
        return ColorsManager.black;
      }),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: TextStyles.font16PrimaryRegular,
        hintStyle: TextStyles.font16Black60OpacityRegular,
        errorStyle: TextStyles.font12RedRegular,
        filled: true,
        fillColor: ColorsManager.lightGrey,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: ColorsManager.transparent,
            width: 1.5,
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: ColorsManager.primary,
            width: 1.5,
          ),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: ColorsManager.transparent,
            width: 1.5,
          ),
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(
            color: ColorsManager.transparent,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: ColorsManager.red, width: 1.5),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: const BorderSide(color: ColorsManager.red, width: 1.5),
        ),
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: const BorderSide(color: ColorsManager.lightGrey, width: 2),
      ),
    ),
    fontFamily: "Tajawal",
  );
}
