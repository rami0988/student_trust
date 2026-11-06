import 'package:flutter/material.dart';
import 'package:injectable/injectable.dart';

/// Records the name of the route currently on top of the navigator.
///
/// Registered on `MaterialApp.navigatorObservers`. Widgets that sit *above*
/// the navigator (see `ConnectivityWatcher`, mounted in `MaterialApp.builder`)
/// have no route context of their own, so this is the only way for them to
/// know what the user is actually looking at before yanking them elsewhere.
@lazySingleton
class RouteTracker extends NavigatorObserver {
  String? _currentRouteName;

  /// Name of the top route, or null before the first push / for an unnamed
  /// route (e.g. a dialog pushed without `RouteSettings`).
  String? get currentRouteName => _currentRouteName;

  // Dialogs, bottom sheets and menus (PopupRoute) sit OVER a screen without
  // replacing it, so they never change the answer. Tracking them made the
  // player's own quality/speed sheet (an unnamed popup) read as "not on the
  // video player", and a connectivity change at that moment threw the student
  // out of the lesson to the offline/home screen.
  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route is PopupRoute) return;
    _currentRouteName = route.settings.name;
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute is PopupRoute) return;
    _currentRouteName = newRoute?.settings.name;
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route is PopupRoute) return;
    _currentRouteName = _screenName(previousRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route is PopupRoute) return;
    _currentRouteName = _screenName(previousRoute);
  }

  /// A popup is never the "screen" — fall back to unknown rather than its name.
  String? _screenName(Route<dynamic>? route) => route is PopupRoute ? null : route?.settings.name;
}
