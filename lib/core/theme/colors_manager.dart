import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Legacy field names kept so the rest of the app (every widget already
/// written against `ColorsManager.xxx`) keeps compiling unchanged, while
/// actually rendering the real ثقة (Thiqa) brand palette — see [AppColors]
/// for the canonical values. Prefer [AppColors] directly in new code.
abstract class ColorsManager {
  static const Color primary = AppColors.primary;
  static const Color secondary = AppColors.primaryDark;
  static const Color lightSecondary = AppColors.primaryLight;
  static const Color blue = AppColors.info;
  static const Color orange = AppColors.accent;
  static const Color yellow = AppColors.warning;
  static const Color lightYellow = Color(0xFFFDECD8); // pale tint of accent/warning
  static const Color red = AppColors.error;
  static const Color lightRed = Color(0xFFFCE4E4); // pale tint of error
  static const Color darkRed = Color(0xFFB91C1C); // darker shade of error, for emphasis
  static const Color transparent = Colors.transparent;
  static const Color white = Colors.white;
  static const Color black = AppColors.black;
  static const Color grey = AppColors.textSecondary;
  static const Color lightGrey = AppColors.inputFill;
  static const Color lighterGrey = AppColors.background;
  static const Color darkGrey = AppColors.divider;
  static const Color grey400 = AppColors.textTertiary;
  static const Color brown = Color(0xFF292512); // no brand equivalent, kept as-is
  static const Color warmOrange = Color(0xFFFDF0E7); // pale backdrop for accent-colored icons
  static const Color green = AppColors.success;
  static const Color lightGreen = Color(0xFF34D399); // no brand equivalent, kept close to original
  static const Color mediumGreen = AppColors.success;
  static const Color lighterGreen = Color(0xFFDCFCE9); // pale tint of success
  static const Color navyBlue = AppColors.textPrimary;
}
