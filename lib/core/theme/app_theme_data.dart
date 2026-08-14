import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../utils/app_enums.dart';
import 'app_colors.dart';
import 'app_tokens.dart';

/// ثقة (Thiqa) unified app theme — ported from front_student_app's
/// core/theme/app_theme.dart (see [[unified-design-system]] memory), adapted
/// to use the locally-bundled 'Cairo' font family instead of `google_fonts`'
/// network-fetching `GoogleFonts.cairo()`, since this app must work offline
/// from first launch (see the downloads/offline features).
///
/// Light-only by design — no dark mode/theme switching. [AppColorsExtension]
/// is still registered on `ThemeData.extensions` so widgets can read
/// `context.colors.x`; screens that hardcode `AppColors.x` directly instead
/// are unaffected either way since there's only one palette now.
abstract class AppThemeData {
  AppThemeData._();

  static const String _fontFamily = 'Cairo';

  // NOTE(migration): [language] is accepted for signature compatibility with
  // TemplateApp's BlocSelector<AppCubit, AppState, Language> — Cairo covers
  // both Arabic and Latin script well, so there is currently no per-language
  // theme branch.
  static ThemeData light(Language language) => _build(AppColorsExtension.light);

  static ThemeData _build(AppColorsExtension colors) {
    final ThemeData base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: colors.primary,
        brightness: Brightness.light,
        primary: colors.primary,
        secondary: colors.accent,
        error: colors.error,
        surface: colors.surface,
      ),
      fontFamily: _fontFamily,
      scaffoldBackgroundColor: colors.background,
      splashFactory: InkSparkle.splashFactory,
      extensions: [colors],
    );

    final List<BoxShadow> cardShadow = [BoxShadow(color: Colors.black.withValues(alpha: 0.08), blurRadius: 24, offset: const Offset(0, 8))];

    return base.copyWith(
      textTheme: base.textTheme.apply(fontFamily: _fontFamily, bodyColor: colors.textPrimary, displayColor: colors.textPrimary),
      dividerColor: colors.divider,
      // Consistent, subtle slide+fade route transition on every platform.
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
          TargetPlatform.windows: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.macOS: FadeForwardsPageTransitionsBuilder(),
          TargetPlatform.linux: FadeForwardsPageTransitionsBuilder(),
        },
      ),
      // Explicit alongside cardTheme.color below: some widgets (and the
      // Card widget itself, absent a cardTheme override) read this directly.
      cardColor: colors.surface,
      cardTheme: CardThemeData(
        color: colors.surface,
        elevation: 2,
        margin: EdgeInsets.zero,
        shadowColor: Colors.black.withValues(alpha: 0.08),
        shape: RoundedRectangleBorder(borderRadius: AppTokens.radiusLG, side: BorderSide.none),
      ),
      // Generic icon color for any Icon without an explicit color (e.g.
      // inside plain body content, not the AppBar/buttons, which set their
      // own iconTheme below).
      iconTheme: IconThemeData(color: colors.textSecondary),
      appBarTheme: AppBarTheme(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: true,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
          statusBarBrightness: Brightness.dark,
        ),
        titleTextStyle: TextStyle(fontFamily: _fontFamily, color: colors.onPrimary, fontSize: 18, fontWeight: FontWeight.w700),
        iconTheme: IconThemeData(color: colors.onPrimary),
        actionsIconTheme: IconThemeData(color: colors.onPrimary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: colors.primary,
          foregroundColor: colors.onPrimary,
          disabledBackgroundColor: colors.primary.withValues(alpha: 0.35),
          disabledForegroundColor: colors.onPrimary.withValues(alpha: 0.7),
          minimumSize: const Size(88, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: AppTokens.radiusMD),
          textStyle: const TextStyle(fontFamily: _fontFamily, fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: colors.primary,
          minimumSize: const Size(88, 48),
          padding: const EdgeInsets.symmetric(horizontal: 24),
          side: BorderSide(color: colors.primary, width: 1.4),
          shape: RoundedRectangleBorder(borderRadius: AppTokens.radiusMD),
          textStyle: const TextStyle(fontFamily: _fontFamily, fontSize: 15, fontWeight: FontWeight.w700),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: colors.primary,
          shape: RoundedRectangleBorder(borderRadius: AppTokens.radiusSM),
          textStyle: const TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w700),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: colors.primary,
        foregroundColor: colors.onPrimary,
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: AppTokens.radiusLG),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: colors.surface,
        border: OutlineInputBorder(borderRadius: AppTokens.radiusMD, borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: AppTokens.radiusMD, borderSide: BorderSide.none),
        focusedBorder: OutlineInputBorder(borderRadius: AppTokens.radiusMD, borderSide: BorderSide(color: colors.primary, width: 2)),
        errorBorder: OutlineInputBorder(borderRadius: AppTokens.radiusMD, borderSide: BorderSide(color: colors.error, width: 1)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: AppTokens.radiusMD, borderSide: BorderSide(color: colors.error, width: 2)),
        contentPadding: const EdgeInsets.symmetric(horizontal: AppTokens.s16, vertical: AppTokens.s12),
        prefixIconColor: colors.textSecondary,
        suffixIconColor: colors.textSecondary,
        labelStyle: TextStyle(color: colors.textSecondary, fontSize: 13),
        hintStyle: TextStyle(color: colors.textSecondary.withValues(alpha: 0.6), fontSize: 13),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: colors.surface,
        selectedItemColor: colors.primary,
        unselectedItemColor: colors.textTertiary,
        elevation: 8,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
        unselectedLabelStyle: const TextStyle(fontSize: 11),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: colors.surface,
        indicatorColor: colors.primarySoft,
        elevation: 8,
        height: 68,
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            fontFamily: _fontFamily,
            fontSize: 11,
            fontWeight: states.contains(WidgetState.selected) ? FontWeight.w700 : FontWeight.normal,
            color: states.contains(WidgetState.selected) ? colors.primary : colors.textTertiary,
          ),
        ),
        iconTheme: WidgetStateProperty.resolveWith(
          (states) => IconThemeData(color: states.contains(WidgetState.selected) ? colors.primary : colors.textTertiary),
        ),
      ),
      tabBarTheme: TabBarThemeData(
        labelColor: colors.onPrimary,
        unselectedLabelColor: colors.onPrimary.withValues(alpha: 0.7),
        indicatorColor: colors.accent,
        indicatorSize: TabBarIndicatorSize.tab,
        dividerColor: Colors.transparent,
        labelStyle: const TextStyle(fontFamily: _fontFamily, fontWeight: FontWeight.w700, fontSize: 13),
        unselectedLabelStyle: const TextStyle(fontFamily: _fontFamily, fontSize: 13),
      ),
      // Snackbars conventionally use the *inverse* surface (dark chip on a
      // light page) so they read as a transient overlay rather than
      // blending into the page — ColorScheme.fromSeed already computes a
      // correct inverse pair.
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: base.colorScheme.inverseSurface,
        contentTextStyle: TextStyle(fontFamily: _fontFamily, color: base.colorScheme.onInverseSurface, fontSize: 13.5),
        actionTextColor: base.colorScheme.inversePrimary,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(AppTokens.rMD))),
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: AppTokens.radiusXL),
        titleTextStyle: TextStyle(fontFamily: _fontFamily, color: colors.textPrimary, fontSize: 17, fontWeight: FontWeight.w700),
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: colors.surface,
        showDragHandle: true,
        shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      ),
      chipTheme: base.chipTheme.copyWith(
        backgroundColor: colors.inputFill,
        selectedColor: colors.primarySoft,
        labelStyle: TextStyle(fontFamily: _fontFamily, fontSize: 12, color: colors.textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppTokens.rFull)),
        side: BorderSide.none,
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(color: colors.primary, linearTrackColor: colors.divider, circularTrackColor: colors.divider),
      listTileTheme: ListTileThemeData(iconColor: colors.textSecondary, shape: RoundedRectangleBorder(borderRadius: AppTokens.radiusMD)),
      dividerTheme: DividerThemeData(color: colors.divider, thickness: 1, space: 1),
      switchTheme: SwitchThemeData(
        thumbColor: const WidgetStatePropertyAll(Colors.white),
        trackColor: WidgetStateProperty.resolveWith((states) => states.contains(WidgetState.selected) ? colors.primary : colors.divider),
      ),
      extensions: [colors, AppShadowsExtension(card: cardShadow)],
    );
  }
}

/// Companion [ThemeExtension] for the card shadow, for any bespoke
/// `Container(decoration: BoxDecoration(boxShadow: ...))` that isn't
/// migrated to [CardTheme] — read via
/// `Theme.of(context).extension<AppShadowsExtension>()!.card`.
class AppShadowsExtension extends ThemeExtension<AppShadowsExtension> {
  final List<BoxShadow>? card;
  const AppShadowsExtension({required this.card});

  @override
  AppShadowsExtension copyWith({List<BoxShadow>? card}) => AppShadowsExtension(card: card ?? this.card);

  @override
  AppShadowsExtension lerp(ThemeExtension<AppShadowsExtension>? other, double t) => this;
}
