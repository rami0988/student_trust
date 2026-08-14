import 'package:flutter/material.dart';

/// Shared page frame: a plain [Scaffold] with the app's themed [AppBar] (see
/// `AppThemeData._build`'s `appBarTheme` — brand-colored, no hardcoded
/// color here) and a [SafeArea] body so content never sits under the status
/// bar or bottom system gesture area.
///
/// Replaces the old colored-header-behind-a-rounded-sheet layout, which
/// positioned its white sheet at a hardcoded `top: 180` and its overlay
/// actions at hardcoded pixel offsets (e.g. `top: 48`) — neither adapted to
/// the real per-device status bar / gesture-nav inset, which is what caused
/// the reported header/bottom overflow on some screens.
class CustomScaffold extends StatelessWidget {
  final Widget body;

  /// AppBar title. Omit for a title-less bar (rare — prefer always setting one).
  final String? title;

  /// Overrides [title] with an arbitrary widget (e.g. a search `TextField`
  /// swapped in for the title while a page is in "searching" mode).
  final Widget? titleWidget;

  /// Overrides the automatic leading widget (e.g. a "close search" button
  /// instead of the back arrow). Ignored if null — falls back to
  /// [showBackButton]'s normal behavior.
  final Widget? leading;

  /// Shows the automatic back button. Set false for root/tab pages (e.g. Home).
  final bool showBackButton;
  final List<Widget> appBarActions;
  final Widget? bottomNavigationBar;
  final Widget? floatingActionButton;

  /// Overrides the theme's default `centerTitle: true`. Set false for a
  /// [titleWidget] that needs to fill the remaining width (e.g. a search
  /// field) — Flutter's centered-title layout constrains a flexible title
  /// to a symmetric width against the actions instead of letting it expand,
  /// which is what makes a centered search field look squeezed/off.
  final bool? centerTitle;

  const CustomScaffold({
    super.key,
    required this.body,
    this.title,
    this.titleWidget,
    this.leading,
    this.showBackButton = true,
    this.appBarActions = const [],
    this.bottomNavigationBar,
    this.floatingActionButton,
    this.centerTitle,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: titleWidget ?? (title != null ? Text(title!, maxLines: 1, overflow: TextOverflow.ellipsis) : null),
        leading: leading,
        automaticallyImplyLeading: showBackButton,
        actions: appBarActions,
        centerTitle: centerTitle,
      ),
      body: SafeArea(child: body),
      bottomNavigationBar: bottomNavigationBar,
      floatingActionButton: floatingActionButton,
    );
  }
}
