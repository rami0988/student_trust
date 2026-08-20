/// Fired by [SessionInterceptor] whenever the backend rejects a request with
/// 401 (expired/invalid access token), so the app shell can drop the student
/// back to the login screen no matter which screen they were on.
class SessionExpiredEvent {
  const SessionExpiredEvent();
}
