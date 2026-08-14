// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_state.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AuthState extends AuthState {
  @override
  final Status status;
  @override
  final Failure? failure;
  @override
  final User? user;
  @override
  final bool isAuthResolved;

  factory _$AuthState([void Function(AuthStateBuilder)? updates]) =>
      (AuthStateBuilder()..update(updates))._build();

  _$AuthState._({
    required this.status,
    this.failure,
    this.user,
    required this.isAuthResolved,
  }) : super._();
  @override
  AuthState rebuild(void Function(AuthStateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AuthStateBuilder toBuilder() => AuthStateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AuthState &&
        status == other.status &&
        failure == other.failure &&
        user == other.user &&
        isAuthResolved == other.isAuthResolved;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, failure.hashCode);
    _$hash = $jc(_$hash, user.hashCode);
    _$hash = $jc(_$hash, isAuthResolved.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AuthState')
          ..add('status', status)
          ..add('failure', failure)
          ..add('user', user)
          ..add('isAuthResolved', isAuthResolved))
        .toString();
  }
}

class AuthStateBuilder implements Builder<AuthState, AuthStateBuilder> {
  _$AuthState? _$v;

  Status? _status;
  Status? get status => _$this._status;
  set status(Status? status) => _$this._status = status;

  Failure? _failure;
  Failure? get failure => _$this._failure;
  set failure(Failure? failure) => _$this._failure = failure;

  User? _user;
  User? get user => _$this._user;
  set user(User? user) => _$this._user = user;

  bool? _isAuthResolved;
  bool? get isAuthResolved => _$this._isAuthResolved;
  set isAuthResolved(bool? isAuthResolved) =>
      _$this._isAuthResolved = isAuthResolved;

  AuthStateBuilder();

  AuthStateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _status = $v.status;
      _failure = $v.failure;
      _user = $v.user;
      _isAuthResolved = $v.isAuthResolved;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AuthState other) {
    _$v = other as _$AuthState;
  }

  @override
  void update(void Function(AuthStateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AuthState build() => _build();

  _$AuthState _build() {
    final _$result =
        _$v ??
        _$AuthState._(
          status: BuiltValueNullFieldError.checkNotNull(
            status,
            r'AuthState',
            'status',
          ),
          failure: failure,
          user: user,
          isAuthResolved: BuiltValueNullFieldError.checkNotNull(
            isAuthResolved,
            r'AuthState',
            'isAuthResolved',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
