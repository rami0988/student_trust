import 'package:dio/dio.dart';

import 'auth_interceptor.dart';
import 'endpoints.dart';
import 'logging_interceptor.dart';
import 'token_refresh_interceptor.dart';

// The silent-refresh half of session handling is now wired up:
// [TokenRefreshInterceptor] renews the 15-minute access token off the 7-day
// refresh token and replays the failed request, so a student is no longer
// logged out mid-lesson. It still fires SessionExpiredEvent — but only when
// the refresh itself genuinely fails, which is what the old
// SessionInterceptor did on *every* 401. That interceptor is now redundant
// and has been removed from the chain.
abstract class DioFactory {
  DioFactory._();

  static Dio? _dio;

  static const Duration timeout = Duration(seconds: 60);

  static Dio getDio() {
    if (_dio == null) {
      _dio = Dio();
      _dio!.options.baseUrl = Endpoints.baseURL;
      _dio!.options.sendTimeout = timeout;
      _dio!.options.receiveTimeout = timeout;
      _dio!.options.connectTimeout = timeout;
      _dio!.interceptors.add(AuthInterceptor());
      _dio!.interceptors.add(TokenRefreshInterceptor());
      _dio!.interceptors.add(LoggingInterceptor());
      return _dio!;
    } else {
      return _dio!;
    }
  }
}
