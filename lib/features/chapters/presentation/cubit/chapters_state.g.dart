// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'chapters_state.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ChaptersState extends ChaptersState {
  @override
  final Status status;
  @override
  final Failure? failure;
  @override
  final List<Chapter> chapters;

  factory _$ChaptersState([void Function(ChaptersStateBuilder)? updates]) =>
      (ChaptersStateBuilder()..update(updates))._build();

  _$ChaptersState._({
    required this.status,
    this.failure,
    required this.chapters,
  }) : super._();
  @override
  ChaptersState rebuild(void Function(ChaptersStateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  ChaptersStateBuilder toBuilder() => ChaptersStateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ChaptersState &&
        status == other.status &&
        failure == other.failure &&
        chapters == other.chapters;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, failure.hashCode);
    _$hash = $jc(_$hash, chapters.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ChaptersState')
          ..add('status', status)
          ..add('failure', failure)
          ..add('chapters', chapters))
        .toString();
  }
}

class ChaptersStateBuilder
    implements Builder<ChaptersState, ChaptersStateBuilder> {
  _$ChaptersState? _$v;

  Status? _status;
  Status? get status => _$this._status;
  set status(Status? status) => _$this._status = status;

  Failure? _failure;
  Failure? get failure => _$this._failure;
  set failure(Failure? failure) => _$this._failure = failure;

  List<Chapter>? _chapters;
  List<Chapter>? get chapters => _$this._chapters;
  set chapters(List<Chapter>? chapters) => _$this._chapters = chapters;

  ChaptersStateBuilder();

  ChaptersStateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _status = $v.status;
      _failure = $v.failure;
      _chapters = $v.chapters;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ChaptersState other) {
    _$v = other as _$ChaptersState;
  }

  @override
  void update(void Function(ChaptersStateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ChaptersState build() => _build();

  _$ChaptersState _build() {
    final _$result =
        _$v ??
        _$ChaptersState._(
          status: BuiltValueNullFieldError.checkNotNull(
            status,
            r'ChaptersState',
            'status',
          ),
          failure: failure,
          chapters: BuiltValueNullFieldError.checkNotNull(
            chapters,
            r'ChaptersState',
            'chapters',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
