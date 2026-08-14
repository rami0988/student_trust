abstract class Routes {
  Routes._();

  /// The app's entry decision point (security check → silent auto-login →
  /// subjects or login). Also the route `ConnectivityWatcher` returns to when
  /// the connection comes back, so the auth decision is re-made in one place
  /// instead of being duplicated at the call site.
  static const String authGate = '/authGate';
  static const String login = '/login';
  static const String subjects = '/subjects';
  static const String chapters = '/chapters';
  static const String lessons = '/lessons';
  static const String videoPlayer = '/videoPlayer';
  static const String worksheets = '/worksheets';
  static const String worksheetView = '/worksheetView';
  static const String pdfViewer = '/pdfViewer';
  static const String offlineHome = '/offlineHome';
  static const String settings = '/settings';
}
