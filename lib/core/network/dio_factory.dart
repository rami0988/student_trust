import 'package:dio/dio.dart';

import 'auth_interceptor.dart';
import 'endpoints.dart';
import 'logging_interceptor.dart';
import 'session_interceptor.dart';

// NOTE(migration): OLD app's DioClient had an onError(401) interceptor that
// silently refreshed the access token and retried the failed request. That
// silent-refresh behavior is still NOT present here — sessions do not
// transparently renew. What IS wired up (SessionInterceptor, below) is the
// hard-logout half: a 401 fires SessionExpiredEvent so the app shell drops
// the student back to the login screen instead of leaving them stuck on a
// screen that will just keep failing. Flagging the missing refresh half as a
// known gap rather than guessing at where it belongs.
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
      _dio!.interceptors.add(SessionInterceptor());
      _dio!.interceptors.add(LoggingInterceptor());
      return _dio!;
    } else {
      return _dio!;
    }
  }
}
