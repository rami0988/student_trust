abstract class LocalStorageKeys {
  LocalStorageKeys._();

  static const String isFirstTime = 'is_first_time';
  static const String authRole = 'auth_role';
  static const String language = 'language';
  static const String accessToken = 'access_token';
  static const String isAuthenticated = 'is_authenticated';
  static const String hasSeenOnboarding = 'has_seen_onboarding';
  static const String refreshToken = 'refresh_token';
  static const String userId = 'user_id';
  static const String user = 'user';
  static const String deviceId = 'device_id';
  static const String notificationsEnabled = 'notifications_enabled';

  /// Last playback position (seconds) of a lesson on this device, so a
  /// lesson resumes where the student stopped even when the server save
  /// failed (offline/weak connection) or the lessons list is stale.
  static String videoPosition(String lessonId) => 'video_position_$lessonId';

  /// The student's chosen playback speed, applied to every lesson.
  static const String playbackSpeed = 'playback_speed';

  /// Whether the one-time "pinch to zoom" hint has been shown.
  static const String zoomHintSeen = 'zoom_hint_seen';
}
