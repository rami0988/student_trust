import 'package:dio/dio.dart';
import 'package:event_bus/event_bus.dart';

import '../di/di.dart';
import '../event_bus/session_expired_event.dart';

/// Detects an expired/invalid access token and fires a [SessionExpiredEvent]
/// so the app shell can drop back to the login screen.
///
/// There is no refresh-token flow wired up here (see the NOTE in
/// `dio_factory.dart`), so unlike a refresh interceptor this never retries
/// the request — it only signals the session is over. The failed request
/// still surfaces to its caller via `handler.next(err)` as an ordinary error.
class SessionInterceptor extends Interceptor {
  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      getIt<EventBus>().fire(const SessionExpiredEvent());
    }
    handler.next(err);
  }
}
