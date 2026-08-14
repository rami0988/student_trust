import '../../../../core/repositories/base_repository.dart';
import '../../../../core/utils/request_result.dart';
import '../entities/user.dart';

abstract class AuthRepository extends BaseRepository {
  Future<RequestResult<User>> login({required String username, required String password});

  /// Cached user for silent auto-login on app start. Returns null when there
  /// is no valid session — this never fails, so it isn't wrapped in
  /// [RequestResult].
  Future<User?> currentUser();

  /// Clears the local session. Keeps the device id so single-device binding
  /// survives a re-login.
  Future<void> logout();

  Future<RequestResult<void>> deleteAccount();
}
