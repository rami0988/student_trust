/// Fired by `TokenRefreshInterceptor` when a 401 could **not** be recovered
/// by refreshing the access token — i.e. the refresh token itself is expired,
/// already rotated, or revoked — so the app shell can drop the student back to
/// the login screen no matter which screen they were on.
///
/// An ordinary expired access token no longer reaches here: it is renewed
/// silently and the failed request replayed.
class SessionExpiredEvent {
  const SessionExpiredEvent();
}
