import 'package:dio/dio.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/error/error_handler.dart';
import '../../../../core/network/endpoints.dart';
import '../models/login_response_model.dart';
import 'auth_remote_data_source.dart';

/// This backend returns raw, unwrapped JSON (no {success, message, data,
/// meta} envelope — see core/network/endpoints.dart NOTE(migration)), so this
/// data source talks to [Dio] directly instead of extending
/// BaseRemoteDataSourceImpl, whose performXRequest helpers require the
/// envelope shape. Errors are still normalized through [ErrorHandler] so the
/// repository/BaseRepositoryImpl.execute contract is unaffected.
@LazySingleton(as: AuthRemoteDataSource)
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSourceImpl(this._dio);

  @override
  Future<LoginResponseModel> login({
    required String username,
    required String password,
    required String deviceUuid,
  }) async {
    try {
      final Response<Map<String, dynamic>> response = await _dio.post(
        Endpoints.login,
        data: {'username': username, 'password': password},
        options: Options(headers: {'X-Device-ID': deviceUuid}),
      );
      return LoginResponseModel.fromJson(response.data ?? {});
    } catch (error) {
      throw ErrorHandler.handleExceptionError(error);
    }
  }

  @override
  Future<void> logout() async {
    // Best-effort: local session teardown (AuthRepositoryImpl.logout) must
    // succeed even if this network call fails — mirrors FRONT's
    // AuthRemoteDataSourceImpl.logout().
    try {
      await _dio.post<dynamic>(Endpoints.logout);
    } catch (_) {
      // Ignored — see above.
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {
      await _dio.delete(Endpoints.deleteAccount);
    } catch (error) {
      throw ErrorHandler.handleExceptionError(error);
    }
  }
}
