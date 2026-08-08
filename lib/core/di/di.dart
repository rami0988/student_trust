import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:event_bus/event_bus.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get_it/get_it.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:injectable/injectable.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../network/dio_factory.dart';
import 'di.config.dart';

final GetIt getIt = GetIt.instance;

@InjectableInit(
  initializerName: r'$initGetIt',
  preferRelativeImports: true,
  asExtension: false,
)
Future<void> configureDependencies() => $initGetIt(getIt);

@module
abstract class RegisterModule {
  @lazySingleton
  @preResolve
  Future<SharedPreferences> getSharedPreferences() => SharedPreferences.getInstance();

  @lazySingleton
  FlutterSecureStorage get flutterSecureStorage => const FlutterSecureStorage();

  @lazySingleton
  GlobalKey<State> get loaderDialogKey => GlobalKey<State>();

  @lazySingleton
  GlobalKey<NavigatorState> get navigatorKey => GlobalKey<NavigatorState>();

  @lazySingleton
  Dio get dio => DioFactory.getDio();

  @lazySingleton
  Connectivity get connectivity => Connectivity();

  @lazySingleton
  EventBus get eventBus => EventBus();

  @lazySingleton
  FirebaseMessaging get firebaseMessaging => FirebaseMessaging.instance;

  @lazySingleton
  FlutterLocalNotificationsPlugin get flutterLocalNotificationsPlugin => FlutterLocalNotificationsPlugin();

  @lazySingleton
  DeviceInfoPlugin get deviceInfoPlugin => DeviceInfoPlugin();

  /// General-purpose local Hive box. Register typed boxes with their adapters
  /// here per feature (see the original cart box pattern in ARCHITECTURE.md).
  @lazySingleton
  @preResolve
  Future<Box> getAppBox() async {
    await Hive.initFlutter();
    return await Hive.openBox('app_box');
  }
}
