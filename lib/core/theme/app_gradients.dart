import 'package:flutter/material.dart';

import 'app_colors.dart';

/// Gradients from the redesign that [AppTokens] doesn't carry. Kept in a
/// separate file because `app_tokens.dart` is mirrored verbatim with the
/// admin app (FRONT), and these are student-app only.
class AppGradients {
  AppGradients._();

  /// Chapter hero card: deep navy → brand blue → sky.
  static const LinearGradient hero = LinearGradient(
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
    colors: [Color(0xFF123E66), AppColors.primary, AppColors.gradientEnd],
    stops: [0, 0.55, 1],
  );

  /// Orange progress fills (watch progress, "slower" time indicator).
  static const LinearGradient accent = LinearGradient(colors: [AppColors.accent, AppColors.accentLight]);

  /// Primary fills on dark surfaces (selected speed, timeline played part).
  static const LinearGradient brandHorizontal = LinearGradient(colors: [AppColors.gradientEnd, AppColors.primary]);

  /// Lesson thumbnail placeholders, picked by lesson position so neighbouring
  /// cards don't look identical when there is no thumbnail.
  static const List<LinearGradient> thumbnails = [
    LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [AppColors.primary, AppColors.gradientEnd]),
    LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [Color(0xFF0F4C81), Color(0xFF2F86C9)]),
    LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [Color(0xFF3B3F9E), Color(0xFF5C7BD9)]),
    LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [Color(0xFF0E6E6E), Color(0xFF2BA3A3)]),
    LinearGradient(begin: Alignment.topRight, end: Alignment.bottomLeft, colors: [Color(0xFF8A3A12), AppColors.accent]),
  ];
}
