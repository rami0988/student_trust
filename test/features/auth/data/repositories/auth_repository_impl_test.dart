import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_template/core/di/di.dart';
import 'package:mobile_template/core/services/device_service.dart';
import 'package:mobile_template/core/utils/local_storage_keys.dart';
import 'package:mobile_template/features/auth/data/data_sources/auth_remote_data_source.dart';
import 'package:mobile_template/features/auth/data/models/login_response_model.dart';
import 'package:mobile_template/features/auth/data/repositories/auth_repository_impl.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// In-memory stand-in for the platform keychain, which has no implementation
/// under `flutter test` — mirrors token_refresh_interceptor_test.dart's fake.
class _InMemorySecureStorage extends FlutterSecureStorage {
  final Map<String, String> store = <String, String>{};

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => store[key];

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
    if (value == null) {
      store.remove(key);
    } else {
      store[key] = value;
    }
  }

  @override
  Future<void> deleteAll({
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => store.clear();
}

class _FakeAuthRemoteDataSource implements AuthRemoteDataSource {
  int logoutCallCount = 0;

  @override
  Future<void> logout() async {
    logoutCallCount++;
  }

  @override
  Future<void> deleteAccount() async {}

  @override
  Future<LoginResponseModel> login({
    required String username,
    required String password,
    required String deviceUuid,
  }) => throw UnimplementedError();
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late _InMemorySecureStorage storage;
  late _FakeAuthRemoteDataSource dataSource;
  late AuthRepositoryImpl repository;

  // SharedPreferencesHelper resolves both dependencies from getIt into
  // `static final` fields on first access, so whichever instance is
  // registered when that first happens is what the whole test run uses —
  // register ONCE here and clear the shared map between tests instead of
  // re-registering (mirrors token_refresh_interceptor_test.dart's approach).
  setUpAll(() async {
    SharedPreferences.setMockInitialValues({});
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (!getIt.isRegistered<SharedPreferences>()) {
      getIt.registerSingleton<SharedPreferences>(prefs);
    }

    storage = _InMemorySecureStorage();
    if (!getIt.isRegistered<FlutterSecureStorage>()) {
      getIt.registerSingleton<FlutterSecureStorage>(storage);
    }
  });

  setUp(() {
    storage.store.clear();
    dataSource = _FakeAuthRemoteDataSource();
    repository = AuthRepositoryImpl(
      dataSource,
      DeviceService(storage, DeviceInfoPlugin()),
    );
  });

  test('logout calls the remote data source before clearing local storage', () async {
    storage.store[LocalStorageKeys.accessToken] = 'token';
    storage.store[LocalStorageKeys.deviceId] = 'device-1';

    await repository.logout();

    expect(dataSource.logoutCallCount, 1);
  });

  test('logout clears secured data but preserves the device id', () async {
    storage.store[LocalStorageKeys.accessToken] = 'token';
    storage.store[LocalStorageKeys.refreshToken] = 'refresh';
    storage.store[LocalStorageKeys.deviceId] = 'device-1';

    await repository.logout();

    expect(storage.store[LocalStorageKeys.accessToken], isNull);
    expect(storage.store[LocalStorageKeys.refreshToken], isNull);
    expect(storage.store[LocalStorageKeys.deviceId], 'device-1');
  });
}
