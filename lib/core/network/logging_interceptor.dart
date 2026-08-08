import 'package:dio/dio.dart';
import 'package:path/path.dart' as path;

import '../extensions/strings.dart';
import '../utils/logger.dart';

class LoggingInterceptor extends Interceptor {
  String _convertDataToString(dynamic data) {
    if (data == null) return '';

    if (data is FormData) {
      final Map<String, String> allEntries = <String, String>{};
      for (final f in data.fields) {
        allEntries[f.key] = f.value;
      }
      for (final file in data.files) {
        allEntries[file.key] = file.value.filename ?? 'file';
      }
      return allEntries.entries.map((e) => '${e.key}: ${e.value}').join(', ');
    }

    if (data is Map<String, dynamic>) {
      return data.entries.map((e) => '${e.key}: ${e.value}').join(', ');
    }

    return data.toString();
  }

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final String body = _convertDataToString(options.data);
    Logger.debug(name: 'LoggingInterceptor', '*** onRequest ***');
    Logger.debug(name: 'LoggingInterceptor', 'API: ${options.uri}');
    Logger.debug(name: 'LoggingInterceptor', 'Method: ${options.method}');
    Logger.debug(name: 'LoggingInterceptor', 'Headers: ${options.headers}');
    if (!body.isNullOrEmpty()) {
      Logger.debug(name: 'LoggingInterceptor', 'Body: $body');
    }

    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    Logger.success(name: 'LoggingInterceptor', '*** onResponse ***');
    Logger.success(name: 'LoggingInterceptor', 'API: ${response.realUri}');
    Logger.success(
      name: 'LoggingInterceptor',
      'Status Code: ${response.statusCode}',
    );
    Logger.success(
      name: 'LoggingInterceptor',
      'Status Message: ${response.statusMessage}',
    );

    if (!_isImageRequest(response.realUri.path)) {
      Logger.success(name: 'LoggingInterceptor', 'Response: ${response.data}');
    }

    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response != null) {
      Logger.error(name: 'LoggingInterceptor', '*** onError ***');
      Logger.error(
        name: 'LoggingInterceptor',
        'API: ${err.requestOptions.uri}',
      );
      Logger.error(
        name: 'LoggingInterceptor',
        'Status Code: ${err.response!.statusCode}',
      );
      Logger.error(
        name: 'LoggingInterceptor',
        'Status Message: ${err.response!.statusMessage}',
      );
      if (!_isImageRequest(err.requestOptions.uri.path)) {
        Logger.error(
          name: 'LoggingInterceptor',
          'Response: ${err.response!.data}',
        );
      }
    }
    return handler.next(err);
  }

  /// 🖼️ Image filter
  bool _isImageRequest(String api) {
    final String extension = path.basenameWithoutExtension(api);
    return extension == 'png' || extension == 'jpg' || extension == 'jpeg' || extension == 'svg' || extension == 'webp';
  }
}
