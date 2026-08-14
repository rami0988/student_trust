import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/di/di.dart';
import '../../../core/routing/route_tracker.dart';
import '../../../core/routing/routes.dart';
import '../../../core/services/connectivity_service.dart';

/// Watches connectivity for the whole app lifetime and swaps the student
/// between the offline screen and the normal app automatically.
///
/// Mounted in `MaterialApp.builder` — i.e. *above* the navigator — on
/// purpose. [AuthGate] cannot do this job: it finishes by calling
/// `pushNamedAndRemoveUntil(..., (route) => false)`, which tears down the
/// `home:` route it lives on, so any listener it owns dies the moment the
/// student actually reaches the app. Living above the navigator, this widget
/// is never disposed and keeps working on every screen.
///
/// Navigation goes through the global navigator key, since there is no
/// [Navigator] above this point in the tree to look up from context.
class ConnectivityWatcher extends StatefulWidget {
  final Widget child;

  const ConnectivityWatcher({super.key, required this.child});

  @override
  State<ConnectivityWatcher> createState() => _ConnectivityWatcherState();
}

class _ConnectivityWatcherState extends State<ConnectivityWatcher> {
  StreamSubscription<bool>? _subscription;

  /// Last known state — null until the first reading arrives.
  bool? _online;

  /// True while the student is on the offline screen *because this watcher
  /// put them there* (or because the app launched offline). Gates the return
  /// trip: someone who is deep in the app when a connection is restored
  /// should not be yanked back to the start, only someone who is stuck on
  /// the offline screen should.
  bool _showingOffline = false;

  @override
  void initState() {
    super.initState();
    _subscription = getIt<ConnectivityService>().isOnline.listen(_onConnectivityChanged);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _onConnectivityChanged(bool online) {
    final bool? previous = _online;
    _online = online;

    // First reading only seeds state. AuthGate is already deciding the
    // launch screen at this point; navigating here too would race it.
    if (previous == null) {
      _showingOffline = !online;
      return;
    }
    if (previous == online) return;

    final NavigatorState? navigator = getIt<GlobalKey<NavigatorState>>().currentState;
    if (navigator == null) return;

    // Never interrupt playback. A student watching a downloaded lesson is
    // the whole point of offline support, and an online video is already
    // broken by the time we get here — either way, throwing them out of the
    // player mid-lesson is worse than leaving the screen alone.
    if (getIt<RouteTracker>().currentRouteName == Routes.videoPlayer) return;

    if (!online) {
      _showingOffline = true;
      navigator.pushNamedAndRemoveUntil(Routes.offlineHome, (route) => false);
      return;
    }

    if (!_showingOffline) return;
    _showingOffline = false;
    // Back to the gate rather than straight to subjects: it re-runs the
    // auto-login check and picks subjects vs. login itself, so that decision
    // lives in exactly one place.
    navigator.pushNamedAndRemoveUntil(Routes.authGate, (route) => false);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
