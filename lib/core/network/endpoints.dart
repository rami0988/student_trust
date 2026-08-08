abstract class Endpoints {
  Endpoints._();

  static String get serverURL => _serverURL;

  static void setServerUrl(String url) {
    _serverURL = url;
  }

  static String _serverURL = '';
  static String get baseURL => '$_serverURL/api/v1';

  /// Placeholder server URL that activates the bundled [MockApiInterceptor],
  /// so the template runs end-to-end without a backend.
  /// Replace the `Endpoints.setServerUrl(...)` calls in main.dart /
  /// main_development.dart with your real server URLs.
  static const String mockServerUrl = 'https://mock.example.com';

  static bool get isMockServer => _serverURL == mockServerUrl;

  /// *** Example Feature ***
  static const String exampleItems = '/example-items';
  static String exampleItemById(int id) => '/example-items/$id';
  static String likeExampleItem(int id) => '/example-items/$id/like';
}
