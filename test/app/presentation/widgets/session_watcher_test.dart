import 'dart:async';

import 'package:event_bus/event_bus.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_template/app/presentation/widgets/session_watcher.dart';
import 'package:mobile_template/core/di/di.dart';
import 'package:mobile_template/core/event_bus/session_expired_event.dart';
import 'package:mobile_template/core/routing/routes.dart';
import 'package:mobile_template/core/utils/request_result.dart';
import 'package:mobile_template/features/auth/domain/entities/user.dart';
import 'package:mobile_template/features/auth/domain/repositories/auth_repository.dart';
import 'package:mobile_template/features/auth/presentation/cubit/auth_cubit.dart';

/// Counts calls; the point of these tests is that session expiry never reaches
/// the network-backed `logout`.
class _FakeAuthRepository implements AuthRepository {
  int logoutCalls = 0;

  @override
  Future<void> logout() async => logoutCalls++;

  @override
  Future<User?> currentUser() async => null;

  @override
  Future<RequestResult<User>> login({required String username, required String password}) =>
      throw UnimplementedError();

  @override
  Future<RequestResult<void>> deleteAccount() => throw UnimplementedError();

  @override
  Future<RequestResult<T>> execute<T, TM>(FutureOr<TM> Function() apiRequest, {FutureOr<T> Function(TM)? converter}) =>
      throw UnimplementedError();

  @override
  RequestResult<T> executeSync<T, TM>(TM Function() request, {T Function(TM)? converter}) =>
      throw UnimplementedError();
}

void main() {
  late EventBus eventBus;
  late _FakeAuthRepository repository;
  late GlobalKey<NavigatorState> navigatorKey;
  late List<String> visited;

  setUp(() async {
    await getIt.reset();
    eventBus = EventBus();
    repository = _FakeAuthRepository();
    navigatorKey = GlobalKey<NavigatorState>();
    visited = <String>[];
    getIt
      ..registerSingleton<EventBus>(eventBus)
      ..registerSingleton<GlobalKey<NavigatorState>>(navigatorKey)
      ..registerSingleton<AuthCubit>(AuthCubit(repository));
  });

  tearDown(() async => getIt.reset());

  Future<void> pumpApp(WidgetTester tester) => tester.pumpWidget(
    MaterialApp(
      navigatorKey: navigatorKey,
      initialRoute: '/home',
      onGenerateRoute: (settings) {
        visited.add(settings.name ?? '');
        return MaterialPageRoute<void>(builder: (_) => Text(settings.name ?? ''), settings: settings);
      },
      builder: (context, child) => SessionWatcher(child: child!),
    ),
  );

  testWidgets('session expiry resets auth state locally and never calls the network logout', (tester) async {
    await pumpApp(tester);

    eventBus.fire(const SessionExpiredEvent());
    await tester.pumpAndSettle();

    expect(repository.logoutCalls, 0, reason: 'a network logout here is what re-triggered the loop');
    final AuthCubit cubit = getIt<AuthCubit>();
    expect(cubit.state.user, isNull);
    expect(cubit.state.isAuthResolved, isTrue);
  });

  testWidgets('goes back to the auth gate once', (tester) async {
    await pumpApp(tester);

    eventBus.fire(const SessionExpiredEvent());
    await tester.pumpAndSettle();

    expect(visited.where((r) => r == Routes.authGate).length, 1);
  });

  testWidgets('a burst of expiry events (one per in-flight request) navigates only once', (tester) async {
    await pumpApp(tester);

    for (int i = 0; i < 8; i++) {
      eventBus.fire(const SessionExpiredEvent());
    }
    await tester.pumpAndSettle();

    expect(visited.where((r) => r == Routes.authGate).length, 1);
    expect(repository.logoutCalls, 0);
  });
}
