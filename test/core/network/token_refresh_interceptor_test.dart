import 'dart:async';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_template/core/di/di.dart';
import 'package:mobile_template/core/event_bus/session_expired_event.dart';
import 'package:mobile_template/core/network/endpoints.dart';
import 'package:mobile_template/core/network/token_refresh_interceptor.dart';
import 'package:mobile_template/core/utils/local_storage_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// In-memory stand-in for the platform keychain, which has no implementation
/// under `flutter test`.
class _InMemorySecureStorage extends FlutterSecureStorage {
  final Map<String, String> store = <String, String>{};

  _InMemorySecureStorage();

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => store[key];

  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    if (value == null) {
      store.remove(key);
    } else {
      store[key] = value;
    }
  }

  @override
  Future<void> deleteAll({
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => store.clear();
}

/// Counts `/auth/refresh` calls and lets each test script the outcome, so the
/// single-flight guarantee can be asserted directly.
class _FakeRefreshAdapter implements HttpClientAdapter {
  int refreshCallCount = 0;
  int replayCallCount = 0;

  /// Delays the refresh response, widening the window in which concurrent
  /// 401s can pile up — without it they could serialize by luck and pass.
  Duration refreshDelay = const Duration(milliseconds: 50);
  bool refreshSucceeds = true;
  String issuedAccessToken = 'new-access-token';
  String? issuedRefreshToken = 'new-refresh-token';

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    if (options.path.contains(Endpoints.refreshToken)) {
      refreshCallCount++;
      await Future<void>.delayed(refreshDelay);
      if (!refreshSucceeds) {
        return ResponseBody.fromString('{"error":"INVALID_REFRESH_TOKEN"}', 401);
      }
      final String refreshPart = issuedRefreshToken == null
          ? ''
          : ',"refreshToken":"$issuedRefreshToken"';
      return ResponseBody.fromString(
        '{"accessToken":"$issuedAccessToken"$refreshPart}',
        200,
        headers: {
          Headers.contentTypeHeader: [Headers.jsonContentType],
        },
      );
    }

    // Any other call reaching the adapter is a replayed request.
    replayCallCount++;
    return ResponseBody.fromString(
      '{"ok":true,"auth":"${options.headers['Authorization']}"}',
      200,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// Sends `/auth/refresh` to one adapter and everything else to another, so a
/// test can let the refresh succeed while the replayed request still 401s.
class _SplitAdapter implements HttpClientAdapter {
  final HttpClientAdapter refresh;
  final HttpClientAdapter other;

  _SplitAdapter({required this.refresh, required this.other});

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) => options.path.contains(Endpoints.refreshToken)
      ? refresh.fetch(options, requestStream, cancelFuture)
      : other.fetch(options, requestStream, cancelFuture);

  @override
  void close({bool force = false}) {}
}

/// Always 401s, standing in for the API with an expired access token.
class _AlwaysUnauthorizedAdapter implements HttpClientAdapter {
  int callCount = 0;

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    callCount++;
    return ResponseBody.fromString('{"error":"TOKEN_EXPIRED"}', 401);
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _InMemorySecureStorage storage;
  late _FakeRefreshAdapter refreshAdapter;
  late _AlwaysUnauthorizedAdapter apiAdapter;
  late Dio dio;
  late EventBus eventBus;

  // SharedPreferencesHelper caches both dependencies in `static final` fields,
  // resolved from getIt on first touch. So the storage instance registered here
  // is the one it uses for the whole run — re-registering a fresh stub per test
  // would leave the helper writing to the original while assertions read the
  // new one. Register ONCE, and clear the shared map between tests instead.
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!getIt.isRegistered<SharedPreferences>()) {
      getIt.registerSingleton<SharedPreferences>(prefs);
    }

    storage = _InMemorySecureStorage();
    if (getIt.isRegistered<FlutterSecureStorage>()) {
      await getIt.unregister<FlutterSecureStorage>();
    }
    getIt.registerSingleton<FlutterSecureStorage>(storage);

    // Same reasoning: the interceptor resolves EventBus from getIt on each
    // fire, but keeping one instance keeps listener wiring predictable.
    eventBus = EventBus();
    if (getIt.isRegistered<EventBus>()) {
      await getIt.unregister<EventBus>();
    }
    getIt.registerSingleton<EventBus>(eventBus);
  });

  setUp(() async {
    Endpoints.setServerUrl('https://api.test');
    TokenRefreshInterceptor.resetForTest();

    storage.store
      ..clear()
      ..[LocalStorageKeys.accessToken] = 'expired-access-token'
      ..[LocalStorageKeys.refreshToken] = 'valid-refresh-token';

    refreshAdapter = _FakeRefreshAdapter();
    apiAdapter = _AlwaysUnauthorizedAdapter();

    dio = Dio(BaseOptions(baseUrl: Endpoints.baseURL))
      ..httpClientAdapter = apiAdapter
      ..interceptors.add(
        TokenRefreshInterceptor(
          refreshClientFactory: () => Dio(BaseOptions(baseUrl: Endpoints.baseURL))
            ..httpClientAdapter = refreshAdapter,
        ),
      );
  });

  group('single-flight', () {
    // The backend rotates refresh tokens (one-time use), so a second
    // concurrent refresh would present an already-deleted jti and get a 401 —
    // logging the student out precisely because we tried to keep them in.
    test('5 concurrent 401s trigger exactly ONE refresh call', () async {
      final List<Future<Response<dynamic>>> requests = List.generate(
        5,
        (i) => dio.get<dynamic>('/student/subjects?page=$i'),
      );

      await Future.wait(requests);

      expect(refreshAdapter.refreshCallCount, 1);
    });

    test('all 5 requests are replayed and resolve successfully', () async {
      final List<Response<dynamic>> responses = await Future.wait(
        List.generate(5, (i) => dio.get<dynamic>('/student/subjects?page=$i')),
      );

      expect(responses.length, 5);
      expect(responses.every((r) => r.statusCode == 200), isTrue);
      expect(refreshAdapter.replayCallCount, 5);
    });

    test('every replayed request carries the NEW access token', () async {
      final List<Response<dynamic>> responses = await Future.wait(
        List.generate(5, (i) => dio.get<dynamic>('/student/subjects?page=$i')),
      );

      for (final Response<dynamic> response in responses) {
        expect(response.data['auth'], 'Bearer new-access-token');
      }
    });

    test('a later, separate 401 starts a fresh refresh (latch is released)', () async {
      await dio.get<dynamic>('/student/subjects');
      expect(refreshAdapter.refreshCallCount, 1);

      await dio.get<dynamic>('/student/subjects');
      expect(refreshAdapter.refreshCallCount, 2);
    });
  });

  group('token persistence', () {
    test('stores the new access token', () async {
      await dio.get<dynamic>('/student/subjects');

      expect(storage.store[LocalStorageKeys.accessToken], 'new-access-token');
    });

    // Rotation means the presented refresh token is dead after use. Not
    // persisting the replacement would work exactly once, then hard-logout.
    test('stores the ROTATED refresh token', () async {
      await dio.get<dynamic>('/student/subjects');

      expect(storage.store[LocalStorageKeys.refreshToken], 'new-refresh-token');
    });

    test('keeps the existing refresh token when none is returned', () async {
      refreshAdapter.issuedRefreshToken = null;

      await dio.get<dynamic>('/student/subjects');

      expect(storage.store[LocalStorageKeys.refreshToken], 'valid-refresh-token');
    });
  });

  group('session expiry fallback', () {
    test('fires SessionExpiredEvent when the refresh itself fails', () async {
      refreshAdapter.refreshSucceeds = false;
      final Future<SessionExpiredEvent> fired = eventBus
          .on<SessionExpiredEvent>()
          .first
          .timeout(const Duration(seconds: 2));

      await dio.get<dynamic>('/student/subjects').catchError((_) => Response<dynamic>(requestOptions: RequestOptions(path: '/')));

      await expectLater(fired, completes);
    });

    test('clears stored credentials when the refresh fails', () async {
      refreshAdapter.refreshSucceeds = false;

      await dio.get<dynamic>('/student/subjects').catchError((_) => Response<dynamic>(requestOptions: RequestOptions(path: '/')));

      expect(storage.store, isEmpty);
    });

    test('does NOT fire SessionExpiredEvent when the refresh succeeds', () async {
      bool fired = false;
      final StreamSubscription<SessionExpiredEvent> sub = eventBus
          .on<SessionExpiredEvent>()
          .listen((_) => fired = true);
      addTearDown(sub.cancel);

      // The replay resolves 200, so this must not throw at all.
      final Response<dynamic> response = await dio.get<dynamic>('/student/subjects');
      await Future<void>.delayed(const Duration(milliseconds: 20));

      expect(response.statusCode, 200);
      expect(fired, isFalse);
    });

    test('fires SessionExpiredEvent when no refresh token is stored', () async {
      storage.store.remove(LocalStorageKeys.refreshToken);
      final Future<SessionExpiredEvent> fired = eventBus
          .on<SessionExpiredEvent>()
          .first
          .timeout(const Duration(seconds: 2));

      await dio.get<dynamic>('/student/subjects').catchError((_) => Response<dynamic>(requestOptions: RequestOptions(path: '/')));

      await expectLater(fired, completes);
      expect(refreshAdapter.refreshCallCount, 0);
    });
  });

  group('recursion guards', () {
    test('a 401 from /auth/refresh itself does not trigger another refresh', () async {
      await dio
          .post<dynamic>(Endpoints.refreshToken, data: {'refreshToken': 'x'})
          .catchError((_) => Response<dynamic>(requestOptions: RequestOptions(path: '/')));

      expect(refreshAdapter.refreshCallCount, 0);
    });

    // Guards against an infinite refresh->replay->401->refresh loop when the
    // backend keeps rejecting even a freshly minted token.
    test('a replayed request that 401s again is not retried a second time', () async {
      // Route the replay back to the always-401 adapter so the retry fails
      // exactly the way it would if the new token were still rejected.
      final Dio loopingDio = Dio(BaseOptions(baseUrl: Endpoints.baseURL))
        ..httpClientAdapter = apiAdapter
        ..interceptors.add(
          TokenRefreshInterceptor(
            refreshClientFactory: () {
              final Dio client = Dio(BaseOptions(baseUrl: Endpoints.baseURL));
              // Refresh calls succeed; replays (any other path) 401 again.
              client.httpClientAdapter = _SplitAdapter(
                refresh: refreshAdapter,
                other: apiAdapter,
              );
              return client;
            },
          ),
        );

      await expectLater(
        loopingDio.get<dynamic>('/student/subjects'),
        throwsA(isA<DioException>()),
      );

      // Exactly one refresh — the retried flag stopped a second cycle.
      expect(refreshAdapter.refreshCallCount, 1);
    });
  });
}
