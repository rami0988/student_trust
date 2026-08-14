import 'package:dio/dio.dart';

import 'auth_interceptor.dart';
import 'endpoints.dart';
import 'logging_interceptor.dart';

// NOTE(migration): OLD app's DioClient had an onError(401) interceptor that
// silently refreshed the access token and retried the failed request. This
// core class is intentionally left untouched (see ARCHITECTURE.md / migration
// rules), so that behavior is NOT present here yet — sessions will currently
// hard-logout on token expiry instead of silently refreshing. Flagging as a
// known gap rather than guessing at where a refresh interceptor belongs.
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
      _dio!.interceptors.add(LoggingInterceptor());
      return _dio!;
    } else {
      return _dio!;
    }
  }
}
