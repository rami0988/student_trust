import 'dart:convert';
import 'dart:io';

import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:event_bus/event_bus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:injectable/injectable.dart';

import '../event_bus/notification_received_event.dart';
import '../extensions/strings.dart';
import 'logger.dart';

@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  final Map<String, dynamic> data = message.data;
  Logger.debug(
    'Notification Data: $data',
    name: '_firebaseMessagingBackgroundHandler',
  );
}

/// Push-notifications plumbing (FCM + local notifications).
///
/// Fully optional: nothing resolves this singleton until you call
/// `getIt<NotificationsHelper>().initNotifications()` — do that only after
/// Firebase is configured (see CHECKLIST.md).
///
/// TODO(template): implement [onTapNotification] with your own payload model
/// and navigation (the original project parses a NotificationDataModel and
/// pushes the matching route via the injected navigator key).
@lazySingleton
class NotificationsHelper {
  static const String _channelId = 'template_notifications_channel_id';
  static const String _channelName = 'Template Notifications';
  static const String _launcherIcon = '@mipmap/ic_launcher';
  static const String _notificationIcon = '@mipmap/ic_launcher';

  static const AndroidInitializationSettings _androidSettings = AndroidInitializationSettings(
    _notificationIcon,
  );
  static const DarwinInitializationSettings _iosSettings = DarwinInitializationSettings();
  static const InitializationSettings _initializationSettings = InitializationSettings(
    android: _androidSettings,
    iOS: _iosSettings,
  );

  bool _isInitialized = false;
  int _notificationId = 1;

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin;
  final Dio _dio;
  final GlobalKey<NavigatorState> _navigatorKey;
  final FirebaseMessaging _firebaseMessaging;
  final EventBus _eventBus;
  final DeviceInfoPlugin _deviceInfoPlugin;

  NotificationsHelper(
    this._dio,
    this._firebaseMessaging,
    this._navigatorKey,
    this._flutterLocalNotificationsPlugin,
    this._eventBus,
    this._deviceInfoPlugin,
  );

  Future<bool> initNotifications() async {
    if (_isInitialized) return false;
    FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
    _isInitialized = true;
    final bool granted = await _requestPermissions();
    if (!granted) {
      Logger.warning(
        name: 'NotificationsHelper -> initNotifications',
        'Notification permission denied by user — notifications disabled.',
      );
      return false;
    }
    await _flutterLocalNotificationsPlugin.initialize(
      settings: _initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );
    await _createNotificationChannel();
    _setupNotificationListeners();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _handleNotificationsFromScratch();
    });
    return true;
  }

  Future<void> _createNotificationChannel() async {
    if (Platform.isIOS) return; // iOS doesn't use channels, so skip this step.
    final androidPlugin = _flutterLocalNotificationsPlugin
        .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
    await androidPlugin?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelId,
        _channelName,
        importance: Importance.max,
        playSound: true,
        enableVibration: true,
        enableLights: true,
      ),
    );
  }

  Future<bool> _requestPermissions() async {
    // FCM permission (remote notifications)
    final settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      provisional: true,
      sound: true,
    );

    // Local notifications permission (Android 13+)
    bool localNotificationsGranted = true;
    if (Platform.isAndroid && (await _deviceInfoPlugin.androidInfo).version.sdkInt >= 33) {
      localNotificationsGranted =
          await _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()
              ?.requestNotificationsPermission() ??
          true;
    }
    final AuthorizationStatus status = settings.authorizationStatus;
    Logger.debug(
      name: 'NotificationsHelper -> _requestPermissions',
      'Authorization status: ${status.name}',
    );

    return (status == AuthorizationStatus.authorized || status == AuthorizationStatus.provisional) &&
        localNotificationsGranted;
  }

  void _setupNotificationListeners() {
    FirebaseMessaging.onMessage.listen(_handleForegroundNotification);
    FirebaseMessaging.onMessageOpenedApp.listen(_handleBackgroundNotification);
  }

  void _onDidReceiveNotificationResponse(
    NotificationResponse notificationResponse,
  ) {
    Logger.debug(
      name: 'NotificationsHelper -> _onDidReceiveNotificationResponse',
      'Payload: ${notificationResponse.payload}',
    );
    if (notificationResponse.payload.isNullOrEmpty()) return;
    final Map<String, dynamic> decodedData = json.decode(
      notificationResponse.payload!,
    );
    onTapNotification(decodedData);
  }

  void _handleBackgroundNotification(RemoteMessage remoteMessage) {
    Logger.debug(
      name: 'NotificationsHelper -> _handleBackgroundNotification',
      'Data: ${remoteMessage.data}',
    );
    _eventBus.fire(NotificationReceivedEvent());
    onTapNotification(remoteMessage.data);
  }

  void _handleForegroundNotification(RemoteMessage remoteMessage) {
    final RemoteNotification? notification = remoteMessage.notification;
    final Map<String, dynamic> notificationDataMap = remoteMessage.data;

    if (notification != null) {
      Logger.info(
        name: 'NotificationsHelper -> _handleForegroundNotification',
        "Title: ${remoteMessage.notification?.title}\n\nBody: ${remoteMessage.notification?.body}",
      );
      if (notification.title.isNullOrEmpty() || notification.body.isNullOrEmpty()) {
        return;
      }
      _eventBus.fire(NotificationReceivedEvent());

      _showNotificationWithRemoteImage(
        notificationId: _notificationId,
        title: notification.title!,
        body: notification.body!,
        imageUrl: remoteMessage.notification?.android?.imageUrl,
        payload: json.encode(notificationDataMap),
      );
      _notificationId++;
    }
  }

  void _handleNotificationsFromScratch() async {
    final RemoteMessage? remoteMessage = await _firebaseMessaging.getInitialMessage();
    if (remoteMessage == null) return;
    onTapNotification(remoteMessage.data);
  }

  Future<void> _showNotificationWithRemoteImage({
    required int notificationId,
    required String title,
    required String body,
    String? imageUrl,
    String? payload,
  }) async {
    StyleInformation? styleInformation;

    if (!imageUrl.isNullOrEmpty()) {
      try {
        // Download the image
        final Response response = await _dio.get(
          imageUrl!,
          options: Options(
            responseType: ResponseType.bytes,
            connectTimeout: const Duration(seconds: 5),
            receiveTimeout: const Duration(seconds: 5),
          ),
        );
        if (response.statusCode == 200) {
          styleInformation = BigPictureStyleInformation(
            ByteArrayAndroidBitmap(response.data),
            largeIcon: ByteArrayAndroidBitmap(response.data),
            contentTitle: title,
            htmlFormatContentTitle: true,
            summaryText: body,
            htmlFormatSummaryText: true,
          );
        }
      } catch (error, stackTrace) {
        Logger.error(
          name: 'NotificationsHelper -> _showNotificationWithRemoteImage',
          'Error',
          error: error,
          stackTrace: stackTrace,
        );
      }
    }
    final AndroidNotificationDetails androidNotificationDetails = _buildAndroidDetails(
      styleInformation: styleInformation,
    );
    await _flutterLocalNotificationsPlugin.show(
      id: notificationId,
      title: title,
      body: body,
      payload: payload,
      notificationDetails: NotificationDetails(
        android: androidNotificationDetails,
        iOS: const DarwinNotificationDetails(
          presentAlert: true,
          presentBadge: true,
          presentSound: true,
        ),
      ),
    );
  }

  AndroidNotificationDetails _buildAndroidDetails({
    StyleInformation? styleInformation,
  }) {
    return AndroidNotificationDetails(
      _channelId,
      _channelName,
      playSound: true,
      importance: Importance.max,
      priority: Priority.high,
      enableLights: true,
      icon: _notificationIcon,
      largeIcon: const DrawableResourceAndroidBitmap(_launcherIcon),
      styleInformation: styleInformation,
    );
  }

  /// Route the user based on the notification payload.
  ///
  /// TODO(template): parse [data] into your own model and push the matching
  /// route, e.g.:
  /// `_navigatorKey.currentContext?.pushNamed(Routes.orderDetails, arguments: ...)`
  void onTapNotification(Map<String, dynamic>? data) {
    Logger.debug(
      name: 'NotificationsHelper -> onTapNotification',
      'Notification Data: $data',
    );
    final BuildContext? context = _navigatorKey.currentContext;
    if (context == null) return;
  }

  Future<String?> getFCMToken(String className) async {
    try {
      final String? fcmToken = await _firebaseMessaging.getToken();
      Logger.success(
        name: 'NotificationsHelper:-> $className',
        'FCM Token: ${fcmToken ?? 'Null'}',
      );
      return fcmToken;
    } catch (error, stackTrace) {
      Logger.error(
        name: 'NotificationsHelper:-> $className',
        'Error getting FCM token',
        error: error,
        stackTrace: stackTrace,
      );
      return null;
    }
  }
}
