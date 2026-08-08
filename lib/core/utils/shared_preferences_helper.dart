import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../di/di.dart';
import 'local_storage_keys.dart';
import 'logger.dart';

abstract class SharedPreferencesHelper {
  SharedPreferencesHelper._();

  static final SharedPreferences _sharedPreferences = getIt<SharedPreferences>();
  static final FlutterSecureStorage _flutterSecureStorage = getIt<FlutterSecureStorage>();

  /// Removes a value from SharedPreferences with given [key].
  static Future<void> removeData(String key) async {
    await _sharedPreferences.remove(key);
  }

  /// Removes all keys and values in the SharedPreferences
  static Future<void> clearAllData() async {
    await _sharedPreferences.clear();
  }

  /// Saves a [value] with a [key] in the SharedPreferences.
  static Future<void> setData(String key, value) async {
    switch (value.runtimeType) {
      case const (String):
        await _sharedPreferences.setString(key, value);
        break;
      case const (int):
        await _sharedPreferences.setInt(key, value);
        break;
      case const (bool):
        await _sharedPreferences.setBool(key, value);
        break;
      case const (double):
        await _sharedPreferences.setDouble(key, value);
        break;
    }
  }

  /// Gets a bool value from SharedPreferences with given [key].
  static bool getBool(String key, {bool defaultValue = false}) {
    return _sharedPreferences.getBool(key) ?? defaultValue;
  }

  /// Gets a double value from SharedPreferences with given [key].
  static double getDouble(String key) {
    return _sharedPreferences.getDouble(key) ?? 0.0;
  }

  /// Gets an int value from SharedPreferences with given [key].
  static int getInt(String key) {
    return _sharedPreferences.getInt(key) ?? 0;
  }

  /// Gets an String value from SharedPreferences with given [key].
  static String getString(String key, {String defaultValue = ''}) {
    return _sharedPreferences.getString(key) ?? defaultValue;
  }

  /// Gets an String List value from SharedPreferences with given [key].
  static List<String> getStringList(String key) {
    return _sharedPreferences.getStringList(key) ?? [];
  }

  static Future<void> setStringList(String key, List<String> value) async {
    await _sharedPreferences.setStringList(key, value);
  }

  /// Saves a [value] with a [key] in the FlutterSecureStorage.
  static Future<void> setSecuredString(String key, String value) async {
    await _flutterSecureStorage.write(key: key, value: value);
  }

  /// Gets an String value from FlutterSecureStorage with given [key].
  static Future<String> getSecuredString(String key) async {
    final String value = await _flutterSecureStorage.read(key: key) ?? '';
    return value;
  }

  /// Removes all keys and values in the FlutterSecureStorage
  static Future<void> clearAllSecuredData() async {
    await _flutterSecureStorage.deleteAll();
  }

  static Future<void> removeSecureData(String key) async {
    await _flutterSecureStorage.delete(key: key);
  }

  static Future<void> isFirstTimeOpeningApp() async {
    try {
      final bool? isFirstOpen = _sharedPreferences.getBool(
        LocalStorageKeys.isFirstTime,
      );
      if (isFirstOpen == null || isFirstOpen == true) {
        await _flutterSecureStorage.deleteAll();
        await _sharedPreferences.clear();
        await _sharedPreferences.setBool(LocalStorageKeys.isFirstTime, false);
        Logger.debug(
          name: 'SharedPreferencesHelper',
          'isFirstTimeOpeningApp: Clear Shared preferences and Flutter secure storage Successfully',
        );
      }
    } catch (error, stackTrace) {
      Logger.error(
        name: 'SharedPreferencesHelper',
        'isFirstTimeOpeningApp: Error checking first time opening app',
        error: error,
        stackTrace: stackTrace,
      );
      return;
    }
  }
}
