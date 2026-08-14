import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/utils/app_enums.dart';
import '../../domain/repositories/auth_repository.dart';
import 'auth_state.dart';

@lazySingleton
class AuthCubit extends Cubit<AuthState> {
  final AuthRepository _authRepository;

  AuthCubit(this._authRepository) : super(AuthState.initial());

  /// Attempts a silent login from cached credentials on app start.
  Future<void> checkAuth() async {
    final user = await _authRepository.currentUser();
    emit(state.rebuild((b) => b..user = user..isAuthResolved = true));
  }

  Future<void> login(String username, String password) async {
    emit(
      state.rebuild(
        (b) => b
          ..status = Status.loading
          ..failure = null,
      ),
    );
    final result = await _authRepository.login(username: username.trim(), password: password);
    result.fold(
      success: (user) => emit(
        state.rebuild(
          (b) => b
            ..status = Status.success
            ..user = user
            ..isAuthResolved = true
            ..failure = null,
        ),
      ),
      failure: (failure) => emit(
        state.rebuild(
          (b) => b
            ..status = Status.failure
            ..failure = failure,
        ),
      ),
    );
  }

  Future<void> logout() async {
    await _authRepository.logout();
    emit(state.rebuild((b) => b..status = Status.initial..user = null..isAuthResolved = true..failure = null));
  }

  /// Permanently deletes the account. Returns true on success.
  Future<bool> deleteAccount() async {
    final result = await _authRepository.deleteAccount();
    return result.fold(
      success: (_) {
        emit(state.rebuild((b) => b..status = Status.initial..user = null..failure = null));
        return true;
      },
      failure: (failure) {
        emit(state.rebuild((b) => b..status = Status.failure..failure = failure));
        return false;
      },
    );
  }
}
