abstract class Endpoints {
  Endpoints._();

  static String get serverURL => _serverURL;

  static void setServerUrl(String url) {
    _serverURL = url;
  }

  static String _serverURL = '';
  // NOTE(migration): confirmed with the backend owner that this API is raw
  // JSON, unversioned, at '/api' (no envelope, no '/v1') — matches OLD app's
  // ApiConstants.baseUrl. Template default was '$_serverURL/api/v1'; changed
  // to match the real contract. See data sources in each migrated feature:
  // they bypass BaseRemoteDataSourceImpl.performXRequest (which requires the
  // {success, message, data, meta} envelope) and parse raw responses instead.
  static String get baseURL => '$_serverURL/api';

  /// *** Auth ***
  static const String login = '/auth/login';
  static const String refreshToken = '/auth/refresh';
  static const String logout = '/auth/logout';
  static const String deleteAccount = '/auth/account';

  /// *** Subjects ***
  static const String subjects = '/student/subjects';

  /// *** Chapters ***
  static String chapters(String subjectId) => '/student/subjects/$subjectId/chapters';

  /// *** Lessons ***
  static String lessons(String chapterId) => '/student/chapters/$chapterId/lessons';
  static const String progress = '/student/progress';

  /// *** Video ***
  static String videoStream(String lessonId) => '/video/stream/$lessonId';

  /// *** Downloads ***
  static const String registerDownload = '/student/downloads';
  static String validateDownload(String lessonId) => '/student/downloads/$lessonId/validate';

  /// *** Worksheets *** (read-only for students)
  static String worksheetsByChapter(String chapterId) => '/worksheets/chapter/$chapterId';
  static String worksheetFiles(String worksheetId) => '/worksheets/$worksheetId/files';
  static String worksheetVideos(String worksheetId) => '/worksheets/$worksheetId/videos';
  static String worksheetVideoStream(String videoId) => '/worksheets/videos/$videoId/stream';
}

/// BunnyCDN Stream constants — the Stream library's pull zone only allows requests
/// from the official embed (Referer allow-list), so direct playback/thumbnail/download
/// requests must carry this header.
class BunnyConstants {
  BunnyConstants._();

  static const Map<String, String> cdnHeaders = {
    'Referer': 'https://iframe.mediadelivery.net/',
  };
}
