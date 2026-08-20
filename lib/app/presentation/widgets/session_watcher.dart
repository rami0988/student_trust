import 'dart:async';

import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';

import '../../../core/di/di.dart';
import '../../../core/event_bus/session_expired_event.dart';
import '../../../core/routing/routes.dart';
import '../../../features/auth/presentation/cubit/auth_cubit.dart';

/// Watches for [SessionExpiredEvent] (fired by `SessionInterceptor` on a 401)
/// for the whole app lifetime and drops the student back to the login
/// screen, no matter which screen they were on.
///
/// Mounted in `MaterialApp.builder` — i.e. *above* the navigator — for the
/// same reason as [ConnectivityWatcher]: [AuthGate] tears down the route it
/// lives on once it finishes, so a listener it owned would die the moment
/// the student actually reached the app. Living above the navigator, this
/// widget is never disposed.
///
/// Navigation goes through the global navigator key, since there is no
/// [Navigator] above this point in the tree to look up from context.
class SessionWatcher extends StatefulWidget {
  final Widget child;

  const SessionWatcher({super.key, required this.child});

  @override
  State<SessionWatcher> createState() => _SessionWatcherState();
}

class _SessionWatcherState extends State<SessionWatcher> {
  StreamSubscription<SessionExpiredEvent>? _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = getIt<EventBus>().on<SessionExpiredEvent>().listen(_onSessionExpired);
  }

  @override
  void dispose() {
    _subscription?.cancel();
    super.dispose();
  }

  void _onSessionExpired(SessionExpiredEvent event) {
    // Clear the stored token/user (device id is kept, same as a manual
    // logout) so the auth gate's silent auto-login can't just log back in
    // with the same expired token.
    getIt<AuthCubit>().logout();

    final NavigatorState? navigator = getIt<GlobalKey<NavigatorState>>().currentState;
    if (navigator == null) return;
    // Back to the gate rather than straight to login: it re-runs the
    // auto-login check and picks login itself, so that decision lives in
    // exactly one place (see ConnectivityWatcher for the same pattern).
    navigator.pushNamedAndRemoveUntil(Routes.authGate, (route) => false);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
