import 'package:flutter/material.dart';

import '../theme/colors_manager.dart';

class CustomRefreshIndicator extends StatelessWidget {
  final void Function() onRefresh;
  final Widget child;

  const CustomRefreshIndicator({
    super.key,
    required this.onRefresh,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        onRefresh();
      },
      color: ColorsManager.primary,
      backgroundColor: ColorsManager.white,
      child: child,
    );
  }
}
