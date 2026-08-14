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

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) => _currentRouteName = route.settings.name;

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) => _currentRouteName = newRoute?.settings.name;

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) => _currentRouteName = previousRoute?.settings.name;

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) => _currentRouteName = previousRoute?.settings.name;
}
