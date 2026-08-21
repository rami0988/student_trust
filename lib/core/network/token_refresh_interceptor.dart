import 'dart:async';

import 'package:dio/dio.dart';
import 'package:event_bus/event_bus.dart';

import '../di/di.dart';
import '../event_bus/session_expired_event.dart';
import '../utils/local_storage_keys.dart';
import '../utils/shared_preferences_helper.dart';
import 'endpoints.dart';

/// Silently renews an expired access token and replays the request that hit
/// the 401, so a student is never bounced to the login screen mid-lesson.
///
/// The access token lives 15 minutes while the refresh token lives 7 days
/// (see the backend's `authController.signAccessToken` / `issueRefreshToken`),
/// and login already persists the refresh token — it was simply never used.
/// Without this, every student session died after 15 minutes.
///
/// ## Single-flight
///
/// The backend **rotates** refresh tokens: `/auth/refresh` deletes the
/// presented `jti` and issues a new one, so a refresh token is strictly
/// single-use. That makes naive per-request refreshing actively harmful — the
/// video player alone fires overlapping range requests, so an expiry produces
/// a burst of simultaneous 401s. If each one posted the same refresh token,
/// the first would succeed and every later one would be rejected against a
/// now-deleted `jti`, logging the student out *because* we tried to keep them
/// signed in.
///
/// So at most one refresh is ever in flight: the first 401 starts it, and
/// every concurrent 401 awaits that same [Completer] instead of starting its
/// own. All of them then replay with whatever token the single refresh
/// produced.
class TokenRefreshInterceptor extends Interceptor {
  /// The refresh call deliberately uses its own bare [Dio] rather than the
  /// app's instance: the shared one carries this interceptor, so a 401 from
  /// `/auth/refresh` itself would re-enter here and recurse.
  final Dio Function() _refreshClientFactory;

  TokenRefreshInterceptor({Dio Function()? refreshClientFactory})
    : _refreshClientFactory = refreshClientFactory ?? _defaultRefreshClient;

  static Dio _defaultRefreshClient() => Dio(
    BaseOptions(
      baseUrl: Endpoints.baseURL,
      headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
    ),
  );

  /// Non-null only while a refresh is in flight. Concurrent 401s await it.
  static Completer<String?>? _inFlight;

  /// Visible for tests — clears the shared single-flight latch between cases.
  static void resetForTest() => _inFlight = null;

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    // A 401 from the refresh/login calls themselves means the credentials are
    // genuinely dead — refreshing again would just recurse.
    final String path = err.requestOptions.path;
    if (path.contains(Endpoints.refreshToken) || path.contains(Endpoints.login)) {
      return handler.next(err);
    }

    // Already retried once and still 401 — the new token is not the problem,
    // so stop rather than loop.
    if (err.requestOptions.extra[_retriedFlag] == true) {
      return handler.next(err);
    }

    final String? newAccessToken = await _refreshOnce();

    if (newAccessToken == null || newAccessToken.isEmpty) {
      // Refresh genuinely failed (expired/rotated/revoked refresh token, or
      // the account was deactivated). This is the only path that ends the
      // session — the student is dropped to login by [SessionWatcher].
      await SharedPreferencesHelper.clearAllSecuredData();
      getIt<EventBus>().fire(const SessionExpiredEvent());
      return handler.next(err);
    }

    try {
      final RequestOptions options = err.requestOptions;
      options.headers['Authorization'] = 'Bearer $newAccessToken';
      options.extra[_retriedFlag] = true;

      // Replay through a client that carries no interceptors: AuthInterceptor
      // would otherwise re-read the token from storage and could overwrite the
      // fresh one we just set, and re-entering this interceptor risks a loop.
      final Response<dynamic> response = await _refreshClientFactory().fetch<dynamic>(options);
      return handler.resolve(response);
    } on DioException catch (retryError) {
      // The replay failed for some other reason (500, timeout, …). Surface
      // that error — the session itself is fine, so don't log the student out.
      return handler.next(retryError);
    } catch (_) {
      return handler.next(err);
    }
  }

  /// Runs at most one refresh at a time. Returns the new access token, or
  /// null when the session is genuinely over.
  Future<String?> _refreshOnce() {
    final Completer<String?>? existing = _inFlight;
    if (existing != null) return existing.future;

    final Completer<String?> completer = Completer<String?>();
    _inFlight = completer;

    // Never let the latch outlive the attempt, or every later 401 would await
    // a Completer that can no longer complete and hang forever.
    unawaited(
      _performRefresh()
          .then(completer.complete)
          .catchError((_) => completer.complete(null))
          .whenComplete(() => _inFlight = null),
    );

    return completer.future;
  }

  Future<String?> _performRefresh() async {
    // NOTE: getSecuredString returns '' (not null) when a key is absent —
    // unlike FRONT's nullable helper — so emptiness is the real check here.
    final String refreshToken = await SharedPreferencesHelper.getSecuredString(
      LocalStorageKeys.refreshToken,
    );
    if (refreshToken.isEmpty) return null;

    final Response<dynamic> response = await _refreshClientFactory().post<dynamic>(
      Endpoints.refreshToken,
      data: {'refreshToken': refreshToken},
    );

    final dynamic body = response.data;
    if (body is! Map) return null;

    final String? accessToken = body['accessToken'] as String?;
    if (accessToken == null || accessToken.isEmpty) return null;

    await SharedPreferencesHelper.setSecuredString(LocalStorageKeys.accessToken, accessToken);

    // The backend rotates on every refresh, so the old refresh token is now
    // dead. Failing to persist the replacement would work exactly once and
    // then log the student out on the next expiry.
    final String? rotatedRefreshToken = body['refreshToken'] as String?;
    if (rotatedRefreshToken != null && rotatedRefreshToken.isNotEmpty) {
      await SharedPreferencesHelper.setSecuredString(
        LocalStorageKeys.refreshToken,
        rotatedRefreshToken,
      );
    }

    return accessToken;
  }

  /// Marks a replayed request so a second 401 can't start another cycle.
  static const String _retriedFlag = 'token_refresh_retried';
}
