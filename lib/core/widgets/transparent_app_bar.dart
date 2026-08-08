import 'package:flutter/material.dart';

import '../theme/colors_manager.dart';

class TransparentAppBar extends StatelessWidget implements PreferredSizeWidget {
  const TransparentAppBar({super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: ColorsManager.transparent,
      surfaceTintColor: ColorsManager.transparent,
      toolbarHeight: 0,
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => Size.zero;
}
