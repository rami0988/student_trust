import '../models/login_response_model.dart';

abstract class AuthRemoteDataSource {
  Future<LoginResponseModel> login({required String username, required String password, required String deviceUuid});
  Future<void> deleteAccount();
}
