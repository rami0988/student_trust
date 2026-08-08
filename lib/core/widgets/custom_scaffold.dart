import 'package:flutter/material.dart';

import '../theme/colors_manager.dart';
import 'transparent_app_bar.dart';

/// Scaffold with a colored header area and a white rounded sheet holding the
/// body — the app-wide page frame. Adjust the header decoration per project.
class CustomScaffold extends StatelessWidget {
  final Widget body;
  final List<Widget> actions;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;
  final double topPadding;
  const CustomScaffold({
    super.key,
    required this.body,
    this.actions = const [],
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.topPadding = 180,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      extendBodyBehindAppBar: true,
      appBar: const TransparentAppBar(),
      body: ColoredBox(
        color: ColorsManager.primary,
        child: Stack(
          children: [
            Positioned(
              left: 0,
              right: 0,
              top: topPadding,
              bottom: 0,
              child: Container(
                clipBehavior: Clip.hardEdge,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                ),
                child: body,
              ),
            ),
            ...actions,
          ],
        ),
      ),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }
}
