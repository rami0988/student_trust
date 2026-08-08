import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../di/di.dart';
import '../theme/colors_manager.dart';
import '../widgets/loader.dart';

void showToastMessage(String toastMessage, {bool isError = false}) {
  final context = getIt<GlobalKey<NavigatorState>>().currentContext;
  if (context != null) {
    final messenger = ScaffoldMessenger.maybeOf(context);
    messenger
      ?..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            toastMessage,
            style: TextStyle(
              fontFamily: 'Tajawal',
              color: isError ? ColorsManager.white : ColorsManager.black,
            ),
          ),
          backgroundColor: isError ? ColorsManager.red : ColorsManager.lightGrey,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
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
