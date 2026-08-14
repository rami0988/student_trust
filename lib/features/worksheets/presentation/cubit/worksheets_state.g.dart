// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'worksheets_state.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$WorksheetsState extends WorksheetsState {
  @override
  final Status status;
  @override
  final Failure? failure;
  @override
  final List<Worksheet> worksheets;

  factory _$WorksheetsState([void Function(WorksheetsStateBuilder)? updates]) =>
      (WorksheetsStateBuilder()..update(updates))._build();

  _$WorksheetsState._({
    required this.status,
    this.failure,
    required this.worksheets,
  }) : super._();
  @override
  WorksheetsState rebuild(void Function(WorksheetsStateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  WorksheetsStateBuilder toBuilder() => WorksheetsStateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is WorksheetsState &&
        status == other.status &&
        failure == other.failure &&
        worksheets == other.worksheets;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, failure.hashCode);
    _$hash = $jc(_$hash, worksheets.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'WorksheetsState')
          ..add('status', status)
          ..add('failure', failure)
          ..add('worksheets', worksheets))
        .toString();
  }
}

class WorksheetsStateBuilder
    implements Builder<WorksheetsState, WorksheetsStateBuilder> {
  _$WorksheetsState? _$v;

  Status? _status;
  Status? get status => _$this._status;
  set status(Status? status) => _$this._status = status;

  Failure? _failure;
  Failure? get failure => _$this._failure;
  set failure(Failure? failure) => _$this._failure = failure;

  List<Worksheet>? _worksheets;
  List<Worksheet>? get worksheets => _$this._worksheets;
  set worksheets(List<Worksheet>? worksheets) =>
      _$this._worksheets = worksheets;

  WorksheetsStateBuilder();

  WorksheetsStateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _status = $v.status;
      _failure = $v.failure;
      _worksheets = $v.worksheets;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(WorksheetsState other) {
    _$v = other as _$WorksheetsState;
  }

  @override
  void update(void Function(WorksheetsStateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  WorksheetsState build() => _build();

  _$WorksheetsState _build() {
    final _$result =
        _$v ??
        _$WorksheetsState._(
          status: BuiltValueNullFieldError.checkNotNull(
            status,
            r'WorksheetsState',
            'status',
          ),
          failure: failure,
          worksheets: BuiltValueNullFieldError.checkNotNull(
            worksheets,
            r'WorksheetsState',
            'worksheets',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
