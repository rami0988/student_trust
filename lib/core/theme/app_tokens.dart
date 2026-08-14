import 'package:flutter/material.dart';

import 'app_colors.dart';

/// ثقة (Thiqa) unified design tokens — spacing/radius/shadow/motion scale.
/// Ported from front_student_app's core/theme/app_tokens.dart (see
/// [[unified-design-system]] memory); use these instead of ad-hoc EdgeInsets
/// or hex colors so every screen shares one rhythm.
class AppTokens {
  AppTokens._();

  // ── Spacing scale ─────────────────────────────────────────────
  static const double s4 = 4;
  static const double s8 = 8;
  static const double s12 = 12;
  static const double s16 = 16;
  static const double s20 = 20;
  static const double s24 = 24;
  static const double s32 = 32;
  static const double s40 = 40;

  // ── Radius scale ──────────────────────────────────────────────
  static const double rSM = 10;
  static const double rMD = 14;
  static const double rLG = 18;
  static const double rXL = 24;
  static const double rFull = 999;

  static BorderRadius get radiusSM => BorderRadius.circular(rSM);
  static BorderRadius get radiusMD => BorderRadius.circular(rMD);
  static BorderRadius get radiusLG => BorderRadius.circular(rLG);
  static BorderRadius get radiusXL => BorderRadius.circular(rXL);

  // ── Elevation / shadows ───────────────────────────────────────
  /// Soft resting shadow for cards.
  static List<BoxShadow> get shadowSM => [
    BoxShadow(color: AppColors.primaryDark.withValues(alpha: 0.06), blurRadius: 12, offset: const Offset(0, 4)),
  ];

  /// Raised shadow for floating elements / pressed-in emphasis.
  static List<BoxShadow> get shadowMD => [
    BoxShadow(color: AppColors.primaryDark.withValues(alpha: 0.10), blurRadius: 24, offset: const Offset(0, 8)),
  ];

  /// Colored glow used behind primary CTAs and hero elements.
  static List<BoxShadow> get shadowPrimary => [
    BoxShadow(color: AppColors.primary.withValues(alpha: 0.30), blurRadius: 18, offset: const Offset(0, 8)),
  ];

  // ── Motion ────────────────────────────────────────────────────
  static const Duration dFast = Duration(milliseconds: 150);
  static const Duration dMed = Duration(milliseconds: 250);
  static const Duration dSlow = Duration(milliseconds: 400);
  static const Curve curve = Curves.easeOutCubic;
  static const Curve curveEmphasized = Curves.easeInOutCubicEmphasized;

  // ── Brand gradients ───────────────────────────────────────────
  static const LinearGradient brandGradient = LinearGradient(
    begin: Alignment.topRight,
    end: Alignment.bottomLeft,
    colors: [AppColors.primary, AppColors.gradientEnd],
  );

  static const LinearGradient heroGradient = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [AppColors.primaryDark, AppColors.primary],
  );
}
