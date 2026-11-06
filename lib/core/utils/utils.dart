import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../di/di.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
import '../theme/colors_manager.dart';
import '../widgets/loader.dart';

/// Visual flavour of [showToastMessage]: picks the icon and its color.
enum ToastType { info, success, warning, error }

/// App-wide toast, driven by the injected navigator key so it can be called
/// from anywhere (cubits, services) without a [BuildContext].
///
/// Drawn as a dark card with a tinted icon tile (the redesign's toast); pass
/// [type] for success/warning, [isError] (or `type: ToastType.error`) for the
/// error variant, or [action] for an actionable toast (e.g. "Open").
void showToastMessage(String toastMessage, {bool isError = false, ToastType? type, SnackBarAction? action}) {
  final ToastType kind = type ?? (isError ? ToastType.error : ToastType.info);
  final context = getIt<GlobalKey<NavigatorState>>().currentContext;
  if (context != null) {
    final (IconData icon, Color color) = switch (kind) {
      ToastType.success => (Icons.check_rounded, AppColors.successBright),
      ToastType.warning => (Icons.wifi_rounded, AppColors.warningBright),
      ToastType.error => (Icons.error_outline_rounded, AppColors.errorBright),
      ToastType.info => (Icons.info_outline_rounded, AppColors.gradientEnd),
    };
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(color: color.withValues(alpha: 0.16), borderRadius: AppTokens.radiusSM),
                child: Icon(icon, color: color, size: 18),
              ),
              const SizedBox(width: AppTokens.s12),
              Expanded(
                child: Text(
                  toastMessage,
                  style: const TextStyle(color: AppColors.playerInk, fontSize: 13, fontWeight: FontWeight.w600, height: 1.5),
                ),
              ),
            ],
          ),
          backgroundColor: AppColors.playerSurface2,
          elevation: 8,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          padding: const EdgeInsets.symmetric(horizontal: AppTokens.s12 + 2, vertical: AppTokens.s12),
          shape: RoundedRectangleBorder(borderRadius: AppTokens.radiusLG, side: const BorderSide(color: AppColors.playerLine)),
          action: action,
        ),
      );
  }
  if (kind == ToastType.error) {
    HapticFeedback.vibrate();
  } else {
    HapticFeedback.lightImpact();
  }
}

void showLoadingDialog(BuildContext context, {Color? backgroundColor}) {
  if (getIt<GlobalKey<State>>().currentContext == null) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: backgroundColor,
      builder: (_) => PopScope(
        canPop: false,
        child: Dialog(
          key: getIt<GlobalKey<State>>(),
          backgroundColor: backgroundColor ?? ColorsManager.transparent,
          child: const Loader(),
        ),
      ),
    );
  }
}

void closeLoadingDialogIfVisible() {
  if (getIt<GlobalKey<State>>().currentContext != null) {
    Navigator.of(
      getIt<GlobalKey<State>>().currentContext!,
      rootNavigator: true,
    ).pop();
  }
}

bool isTablet(BuildContext context) {
  final data = MediaQuery.of(context);
  final double shortestSide = data.size.shortestSide;
  return shortestSide >= 600;
}
