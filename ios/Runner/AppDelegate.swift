import Flutter
import UIKit
import UserNotifications

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {

  private let securityChannelName = "com.edushield/security"
  private let screenCaptureChannelName = "com.edushield/screen_capture"

  private var screenCaptureEventSink: FlutterEventSink?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    // Lets background_downloader show (and react to taps on) lesson download
    // notifications. Background URLSession completion itself needs NO code
    // here: the plugin registers as an application delegate and handles
    // application(_:handleEventsForBackgroundURLSession:completionHandler:)
    // itself — implementing it here too would double-handle the OS callback.
    UNUserNotificationCenter.current().delegate = self as UNUserNotificationCenterDelegate
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)

    let messenger = engineBridge.applicationRegistrar.messenger()

    // --- MethodChannel: secure screen toggle (FLAG_SECURE-equivalent on iOS) ---
    let securityChannel = FlutterMethodChannel(
      name: securityChannelName,
      binaryMessenger: messenger
    )
    securityChannel.setMethodCallHandler { (call, result) in
      switch call.method {
      case "setSecureScreen":
        // iOS has no FLAG_SECURE; screen-recording is surfaced via the
        // EventChannel below. We acknowledge the call so the shared Dart
        // SecurityService works on both platforms.
        result(nil)
      case "getFreeDiskBytes":
        // "Important usage" capacity counts space iOS will reclaim from
        // purgeable caches for a user-initiated task — the right figure for a
        // download the student explicitly asked for.
        let home = URL(fileURLWithPath: NSHomeDirectory())
        if let values = try? home.resourceValues(forKeys: [.volumeAvailableCapacityForImportantUsageKey]),
           let capacity = values.volumeAvailableCapacityForImportantUsage {
          result(NSNumber(value: capacity))
        } else {
          result(FlutterError(code: "CAPACITY_UNAVAILABLE", message: nil, details: nil))
        }
      default:
        result(FlutterMethodNotImplemented)
      }
    }

    // --- EventChannel: stream UIScreen.isCaptured changes ---
    let screenCaptureChannel = FlutterEventChannel(
      name: screenCaptureChannelName,
      binaryMessenger: messenger
    )
    screenCaptureChannel.setStreamHandler(self)
  }

  @objc private func screenCaptureChanged() {
    screenCaptureEventSink?(UIScreen.main.isCaptured)
  }
}

extension AppDelegate: FlutterStreamHandler {
  func onListen(
    withArguments arguments: Any?,
    eventSink events: @escaping FlutterEventSink
  ) -> FlutterError? {
    screenCaptureEventSink = events

    // Emit the current state immediately so Dart starts in sync.
    events(UIScreen.main.isCaptured)

    NotificationCenter.default.addObserver(
      self,
      selector: #selector(screenCaptureChanged),
      name: UIScreen.capturedDidChangeNotification,
      object: nil
    )
    return nil
  }

  func onCancel(withArguments arguments: Any?) -> FlutterError? {
    NotificationCenter.default.removeObserver(
      self,
      name: UIScreen.capturedDidChangeNotification,
      object: nil
    )
    screenCaptureEventSink = nil
    return nil
  }
}
