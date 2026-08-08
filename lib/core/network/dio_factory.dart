import 'package:dio/dio.dart';

import 'auth_interceptor.dart';
import 'endpoints.dart';
import 'logging_interceptor.dart';
import 'mock_api_interceptor.dart';

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
      // Template only: serves fake BaseModel-shaped responses while the app
      // points at Endpoints.mockServerUrl. Remove once you have a real backend.
      if (Endpoints.isMockServer) {
        _dio!.interceptors.add(MockApiInterceptor());
      }
      _dio!.interceptors.add(AuthInterceptor());
      _dio!.interceptors.add(LoggingInterceptor());
      return _dio!;
    } else {
      return _dio!;
    }
  }
}
