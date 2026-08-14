// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'subjects_state.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$SubjectsState extends SubjectsState {
  @override
  final Status status;
  @override
  final Failure? failure;
  @override
  final List<Subject> subjects;

  factory _$SubjectsState([void Function(SubjectsStateBuilder)? updates]) =>
      (SubjectsStateBuilder()..update(updates))._build();

  _$SubjectsState._({
    required this.status,
    this.failure,
    required this.subjects,
  }) : super._();
  @override
  SubjectsState rebuild(void Function(SubjectsStateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  SubjectsStateBuilder toBuilder() => SubjectsStateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is SubjectsState &&
        status == other.status &&
        failure == other.failure &&
        subjects == other.subjects;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, failure.hashCode);
    _$hash = $jc(_$hash, subjects.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'SubjectsState')
          ..add('status', status)
          ..add('failure', failure)
          ..add('subjects', subjects))
        .toString();
  }
}

class SubjectsStateBuilder
    implements Builder<SubjectsState, SubjectsStateBuilder> {
  _$SubjectsState? _$v;

  Status? _status;
  Status? get status => _$this._status;
  set status(Status? status) => _$this._status = status;

  Failure? _failure;
  Failure? get failure => _$this._failure;
  set failure(Failure? failure) => _$this._failure = failure;

  List<Subject>? _subjects;
  List<Subject>? get subjects => _$this._subjects;
  set subjects(List<Subject>? subjects) => _$this._subjects = subjects;

  SubjectsStateBuilder();

  SubjectsStateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _status = $v.status;
      _failure = $v.failure;
      _subjects = $v.subjects;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(SubjectsState other) {
    _$v = other as _$SubjectsState;
  }

  @override
  void update(void Function(SubjectsStateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  SubjectsState build() => _build();

  _$SubjectsState _build() {
    final _$result =
        _$v ??
        _$SubjectsState._(
          status: BuiltValueNullFieldError.checkNotNull(
            status,
            r'SubjectsState',
            'status',
          ),
          failure: failure,
          subjects: BuiltValueNullFieldError.checkNotNull(
            subjects,
            r'SubjectsState',
            'subjects',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
