import 'package:built_value/built_value.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/app_enums.dart';
import '../../domain/entities/user.dart';

part 'auth_state.g.dart';

abstract class AuthState implements Built<AuthState, AuthStateBuilder> {
  Status get status;
  Failure? get failure;
  User? get user;

  /// True once the silent auto-login check on app start has resolved, so the
  /// splash/router knows whether to show the login page or go straight in.
  bool get isAuthResolved;

  AuthState._();
  factory AuthState([void Function(AuthStateBuilder) updates]) = _$AuthState;

  factory AuthState.initial() => AuthState(
    (b) => b
      ..status = Status.initial
      ..failure = null
      ..user = null
      ..isAuthResolved = false,
  );
}
