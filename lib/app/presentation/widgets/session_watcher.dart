import 'dart:async';

import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';

import '../../../core/di/di.dart';
import '../../../core/event_bus/session_expired_event.dart';
import '../../../core/routing/routes.dart';
import '../../../features/auth/presentation/cubit/auth_cubit.dart';

/// Watches for [SessionExpiredEvent] (fired by `TokenRefreshInterceptor` when
/// a 401 could not be recovered by a token refresh) for the whole app lifetime
/// and drops the student back to the login screen, no matter which screen they
/// were on.
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

  /// One dead session raises one event per in-flight request (they all 401
  /// together). Only the first may tear down and navigate; the rest arrive
  /// within this window and are dropped, so the student lands on login once
  /// instead of being bounced through the gate repeatedly.
  static const Duration _dedupeWindow = Duration(seconds: 2);
  DateTime? _lastHandledAt;

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
    final DateTime now = DateTime.now();
    final DateTime? last = _lastHandledAt;
    if (last != null && now.difference(last) < _dedupeWindow) return;
    _lastHandledAt = now;

    // The interceptor has already wiped the stored tokens (that is what fires
    // this event), so only the in-memory auth state is left to reset. This is
    // local-only on purpose: the old path called the network logout here, which
    // — with no token left — was rejected and re-raised this very event.
    getIt<AuthCubit>().sessionExpired();

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
