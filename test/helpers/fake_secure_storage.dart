import 'package:flutter_secure_storage/flutter_secure_storage.dart';

/// In-memory stand-in for the platform keychain/keystore, which has no
/// implementation under `flutter test`.
///
/// Records the options each call used, so tests can prove a store wrote to its
/// own namespace rather than the app's default one.
class FakeSecureStorage extends FlutterSecureStorage {
  FakeSecureStorage();

  final Map<String, String> store = <String, String>{};

  /// Android options seen on every call, in order.
  final List<AndroidOptions?> androidOptionsSeen = <AndroidOptions?>[];

  /// iOS options seen on every call, in order.
  final List<AppleOptions?> iosOptionsSeen = <AppleOptions?>[];

  void _record(AndroidOptions? a, AppleOptions? i) {
    androidOptionsSeen.add(a);
    iosOptionsSeen.add(i);
  }

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _record(aOptions, iOptions);
    return store[key];
  }

  @override
  Future<void> write({
    required String key,
    required String? value,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _record(aOptions, iOptions);
    if (value == null) {
      store.remove(key);
    } else {
      store[key] = value;
    }
  }

  @override
  Future<void> delete({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _record(aOptions, iOptions);
    store.remove(key);
  }

  @override
  Future<Map<String, String>> readAll({
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async {
    _record(aOptions, iOptions);
    return Map<String, String>.of(store);
  }
}
