import 'package:dio/dio.dart';

import '../di/di.dart';
import '../extensions/strings.dart';
import '../services/device_service.dart';
import '../utils/local_storage_keys.dart';
import '../utils/shared_preferences_helper.dart';
import 'network_info.dart';

class AuthInterceptor extends Interceptor {
  final NetworkInfo _networkInfo = getIt<NetworkInfo>();
  final DeviceService _deviceService = getIt<DeviceService>();

  String get _language => SharedPreferencesHelper.getString(LocalStorageKeys.language);

  Future<String?> get _accessToken async => await SharedPreferencesHelper.getSecuredString(
    LocalStorageKeys.accessToken,
  );

  Future<bool> get _isConnected async => await _networkInfo.isConnected;

  @override
  void onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final bool isConnected = await _isConnected;
    if (!isConnected) {
      final String message = _language == 'ar'
          ? "هناك مشكلة بالاتصال بالشبكة الرجاء إعادة المحاولة لاحقاً"
          : "There is problem with your connection, please try again";
      return handler.reject(
        DioException(
          requestOptions: options,
          error: message,
          type: DioExceptionType.connectionError,
        ),
      );
    }

    if (!_language.isNullOrEmpty()) {
      options.headers['Accept-Language'] = _language;
    }

    options.headers['Accept'] = 'application/json';

    if (options.path.startsWith('https://maps.googleapis.com') || _isImageRequest(options.path)) {
      return handler.next(options);
    }

    final String? accessToken = await _accessToken;
    if (!accessToken.isNullOrEmpty()) {
      options.headers['Authorization'] = 'Bearer $accessToken';
    }

    // Sent on every request, not just login: the backend re-checks the bound
    // device on each student call, so that a copied token alone is not enough
    // to use the account from a second phone. Best effort — if the id can't be
    // read we still send the request and let the server decide, rather than
    // blocking the student on a local storage hiccup.
    try {
      options.headers['X-Device-ID'] = await _deviceService.getDeviceUuid();
    } catch (_) {}

    return handler.next(options);
  }

  /// 🖼️ Image filter
  bool _isImageRequest(String url) {
    final path = url.toLowerCase();
    return path.endsWith('.png') ||
        path.endsWith('.jpg') ||
        path.endsWith('.jpeg') ||
        path.endsWith('.svg') ||
        path.endsWith('.webp');
  }
}
