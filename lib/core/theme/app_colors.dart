import 'package:flutter/material.dart';

/// The ثقة (Thiqa) brand palette. This is the canonical source of truth for
/// app color — [ColorsManager] (the template's original color set) maps its
/// legacy field names onto these values so existing widget code keeps
/// compiling unchanged while actually rendering the real brand colors.
class AppColors {
  AppColors._();

  // ── Brand ─────────────────────────────────────────────────────
  static const Color primary = Color(0xFF1C74B9); // brand deep blue (ثقة)
  static const Color primaryDark = Color(0xFF14568C); // deep blue shade
  static const Color primaryLight = Color(0xFF4983C3); // hands blue
  static const Color gradientEnd = Color(0xFF4D9DD8); // sky blue highlight
  static const Color accent = Color(0xFFE65A1F); // brand orange

  // ── Semantic ──────────────────────────────────────────────────
  static const Color success = Color(0xFF16A34A);
  static const Color warning = Color(0xFFD97706);
  static const Color error = Color(0xFFDC2626);
  static const Color info = Color(0xFF0284C7);

  // ── Surfaces ──────────────────────────────────────────────────
  static const Color background = Color(0xFFF6F7FB);
  static const Color surface = Colors.white;
  static const Color cardBg = Colors.white;
  static const Color inputFill = Color(0xFFF3F4F9);

  // ── Ink ───────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF111827);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);

  // ── Lines & misc ──────────────────────────────────────────────
  static const Color divider = Color(0xFFE5E7EB);
  static const Color shimmer = Color(0xFFE9EBF2);
  static const Color shimmerHighlight = Color(0xFFF7F8FC);
  static const Color black = Colors.black;

  /// Soft tinted fill used behind icons/badges (primary at 10%).
  static Color get primarySoft => primary.withValues(alpha: 0.10);
  static Color get accentSoft => accent.withValues(alpha: 0.12);
  static Color get successSoft => success.withValues(alpha: 0.10);
  static Color get errorSoft => error.withValues(alpha: 0.10);
  static Color get warningSoft => warning.withValues(alpha: 0.12);
}

/// Theme-reactive counterpart to [AppColors]. The app is light-only (no
/// dark mode) — this extension exists so shared components under
/// `core/widgets` can read colors via `context.colors` instead of the
/// static [AppColors] constants, keeping a single indirection point rather
/// than because the values themselves currently vary.
///
/// Registered on [AppThemeData.light] as a [ThemeExtension] — the idiomatic
/// Flutter mechanism for custom color sets. See [[unified-design-system]]
/// memory for the brand values.
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  final Color primary;
  final Color primaryDark;
  final Color primaryLight;
  final Color gradientEnd;
  final Color accent;

  final Color success;
  final Color warning;
  final Color error;
  final Color info;

  /// The page backdrop behind cards — a soft off-white.
  final Color background;

  /// Card/sheet surface.
  final Color surface;
  final Color cardBg;
  final Color inputFill;

  /// High-emphasis text/icons.
  final Color textPrimary;

  /// Medium-emphasis text.
  final Color textSecondary;

  /// Disabled/lowest-emphasis text.
  final Color textTertiary;

  final Color divider;
  final Color shimmer;
  final Color shimmerHighlight;

  /// Text/icon color guaranteed to read on top of [primary] (a colored
  /// surface, e.g. the brand gradient header) — the surface it sits on is
  /// brand-colored, not theme-following, so this stays white.
  final Color onPrimary;

  /// Text/icon color guaranteed to read on top of [surface].
  final Color onSurface;

  const AppColorsExtension({
    required this.primary,
    required this.primaryDark,
    required this.primaryLight,
    required this.gradientEnd,
    required this.accent,
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
    required this.background,
    required this.surface,
    required this.cardBg,
    required this.inputFill,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.divider,
    required this.shimmer,
    required this.shimmerHighlight,
    required this.onPrimary,
    required this.onSurface,
  });

  Color get primarySoft => primary.withValues(alpha: 0.10);
  Color get accentSoft => accent.withValues(alpha: 0.12);
  Color get successSoft => success.withValues(alpha: 0.10);
  Color get errorSoft => error.withValues(alpha: 0.10);
  Color get warningSoft => warning.withValues(alpha: 0.12);

  static const AppColorsExtension light = AppColorsExtension(
    primary: AppColors.primary,
    primaryDark: AppColors.primaryDark,
    primaryLight: AppColors.primaryLight,
    gradientEnd: AppColors.gradientEnd,
    accent: AppColors.accent,
    success: AppColors.success,
    warning: AppColors.warning,
    error: AppColors.error,
    info: AppColors.info,
    background: AppColors.background,
    surface: AppColors.surface,
    cardBg: AppColors.cardBg,
    inputFill: AppColors.inputFill,
    textPrimary: AppColors.textPrimary,
    textSecondary: AppColors.textSecondary,
    textTertiary: AppColors.textTertiary,
    divider: AppColors.divider,
    shimmer: AppColors.shimmer,
    shimmerHighlight: AppColors.shimmerHighlight,
    onPrimary: Colors.white,
    onSurface: AppColors.textPrimary,
  );

  @override
  AppColorsExtension copyWith({
    Color? primary,
    Color? primaryDark,
    Color? primaryLight,
    Color? gradientEnd,
    Color? accent,
    Color? success,
    Color? warning,
    Color? error,
    Color? info,
    Color? background,
    Color? surface,
    Color? cardBg,
    Color? inputFill,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? divider,
    Color? shimmer,
    Color? shimmerHighlight,
    Color? onPrimary,
    Color? onSurface,
  }) {
    return AppColorsExtension(
      primary: primary ?? this.primary,
      primaryDark: primaryDark ?? this.primaryDark,
      primaryLight: primaryLight ?? this.primaryLight,
      gradientEnd: gradientEnd ?? this.gradientEnd,
      accent: accent ?? this.accent,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      info: info ?? this.info,
      background: background ?? this.background,
      surface: surface ?? this.surface,
      cardBg: cardBg ?? this.cardBg,
      inputFill: inputFill ?? this.inputFill,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      divider: divider ?? this.divider,
      shimmer: shimmer ?? this.shimmer,
      shimmerHighlight: shimmerHighlight ?? this.shimmerHighlight,
      onPrimary: onPrimary ?? this.onPrimary,
      onSurface: onSurface ?? this.onSurface,
    );
  }

  @override
  AppColorsExtension lerp(ThemeExtension<AppColorsExtension>? other, double t) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      primary: Color.lerp(primary, other.primary, t)!,
      primaryDark: Color.lerp(primaryDark, other.primaryDark, t)!,
      primaryLight: Color.lerp(primaryLight, other.primaryLight, t)!,
      gradientEnd: Color.lerp(gradientEnd, other.gradientEnd, t)!,
      accent: Color.lerp(accent, other.accent, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
      info: Color.lerp(info, other.info, t)!,
      background: Color.lerp(background, other.background, t)!,
      surface: Color.lerp(surface, other.surface, t)!,
      cardBg: Color.lerp(cardBg, other.cardBg, t)!,
      inputFill: Color.lerp(inputFill, other.inputFill, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      divider: Color.lerp(divider, other.divider, t)!,
      shimmer: Color.lerp(shimmer, other.shimmer, t)!,
      shimmerHighlight: Color.lerp(shimmerHighlight, other.shimmerHighlight, t)!,
      onPrimary: Color.lerp(onPrimary, other.onPrimary, t)!,
      onSurface: Color.lerp(onSurface, other.onSurface, t)!,
    );
  }
}

/// Ergonomic theme-reactive color access: `context.colors.primary`. Prefer
/// this over `AppColors.x` in shared components (see [AppColorsExtension]'s
/// doc comment).
extension AppColorsContext on BuildContext {
  AppColorsExtension get colors => Theme.of(this).extension<AppColorsExtension>()!;
}
