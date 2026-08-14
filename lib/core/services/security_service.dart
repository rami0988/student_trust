import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

/// Bridges the native platform channels that protect video playback:
///  * `setSecureScreen` (MethodChannel) — applies FLAG_SECURE on Android so the
///    screen cannot be captured/recorded while a lesson is playing.
///  * screen-capture stream (EventChannel) — iOS reports `UIScreen.isCaptured`
///    changes so the UI can react to active screen recording.
@lazySingleton
class SecurityService {
  static const MethodChannel _method = MethodChannel('com.edushield/security');
  static const EventChannel _screenCapture = EventChannel('com.edushield/screen_capture');

  /// Enable the secure (non-recordable) window flag.
  Future<void> enableSecureScreen() => _setSecure(true);

  /// Disable the secure window flag.
  Future<void> disableSecureScreen() => _setSecure(false);

  Future<void> _setSecure(bool secure) async {
    try {
      await _method.invokeMethod('setSecureScreen', secure);
    } on PlatformException {
      // Channel not implemented on this platform — ignore gracefully.
    } on MissingPluginException {
      // No native handler (e.g. running in a test) — ignore.
    }
  }

  /// Emits `true` when the screen is being captured/recorded (iOS), `false`
  /// otherwise. On Android, FLAG_SECURE blocks capture so this stays quiet.
  Stream<bool> get screenCaptureStream =>
      _screenCapture.receiveBroadcastStream().map((event) => event == true).handleError((_) {});
}
