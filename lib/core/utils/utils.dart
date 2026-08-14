import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../di/di.dart';
import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
import '../theme/colors_manager.dart';
import '../widgets/loader.dart';

/// App-wide toast, driven by the injected navigator key so it can be called
/// from anywhere (cubits, services) without a [BuildContext]. Styling comes
/// from [AppThemeData]'s `snackBarTheme` by default; pass [isError] for the
/// error variant, or [action] for an actionable toast (e.g. "Open").
void showToastMessage(String toastMessage, {bool isError = false, SnackBarAction? action}) {
  final context = getIt<GlobalKey<NavigatorState>>().currentContext;
  if (context != null) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(toastMessage),
          backgroundColor: isError ? AppColors.error : null,
          duration: const Duration(seconds: 3),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: AppTokens.radiusMD),
          action: action,
        ),
      );
  }
  if (isError) {
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
