import 'dart:convert';

import 'package:injectable/injectable.dart';

import '../../../../core/repositories/base_repository_impl.dart';
import '../../../../core/services/device_service.dart';
import '../../../../core/utils/local_storage_keys.dart';
import '../../../../core/utils/request_result.dart';
import '../../../../core/utils/shared_preferences_helper.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../data_sources/auth_remote_data_source.dart';
import '../models/user_model.dart';

@LazySingleton(as: AuthRepository)
class AuthRepositoryImpl extends BaseRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _authRemoteDataSource;
  final DeviceService _deviceService;

  AuthRepositoryImpl(this._authRemoteDataSource, this._deviceService) : super('AuthRepository');

  @override
  Future<RequestResult<User>> login({required String username, required String password}) => execute(
    () async {
      // Ensure a device UUID exists before the request (sent via X-Device-ID).
      final String deviceUuid = await _deviceService.getDeviceUuid();
      final response = await _authRemoteDataSource.login(
        username: username,
        password: password,
        deviceUuid: deviceUuid,
      );
      if (response.accessToken != null) {
        await SharedPreferencesHelper.setSecuredString(LocalStorageKeys.accessToken, response.accessToken!);
      }
      if (response.refreshToken != null) {
        await SharedPreferencesHelper.setSecuredString(LocalStorageKeys.refreshToken, response.refreshToken!);
      }
      await SharedPreferencesHelper.setSecuredString(LocalStorageKeys.userId, response.user.id);
      await SharedPreferencesHelper.setSecuredString(LocalStorageKeys.user, jsonEncode(response.user.toJson()));
      return response.user;
    },
    converter: (UserModel model) => model.toDomain(),
  );

  @override
  Future<User?> currentUser() async {
    final String token = await SharedPreferencesHelper.getSecuredString(LocalStorageKeys.accessToken);
    final String raw = await SharedPreferencesHelper.getSecuredString(LocalStorageKeys.user);
    if (token.isEmpty || raw.isEmpty) return null;
    try {
      return UserModel.fromJson(jsonDecode(raw) as Map<String, dynamic>).toDomain();
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> logout() async {
    // Best-effort — see AuthRemoteDataSourceImpl.logout(). Revokes this
    // session's tokens server-side; the local wipe below always happens
    // regardless of whether the network call succeeded.
    await _authRemoteDataSource.logout();
    // Keep the device id so single-device binding survives a re-login.
    final String deviceId = await SharedPreferencesHelper.getSecuredString(LocalStorageKeys.deviceId);
    await SharedPreferencesHelper.clearAllSecuredData();
    if (deviceId.isNotEmpty) {
      await SharedPreferencesHelper.setSecuredString(LocalStorageKeys.deviceId, deviceId);
    }
  }

  @override
  Future<RequestResult<void>> deleteAccount() => execute(() async {
    await _authRemoteDataSource.deleteAccount();
    final String deviceId = await SharedPreferencesHelper.getSecuredString(LocalStorageKeys.deviceId);
    await SharedPreferencesHelper.clearAllSecuredData();
    if (deviceId.isNotEmpty) {
      await SharedPreferencesHelper.setSecuredString(LocalStorageKeys.deviceId, deviceId);
    }
  });
}
