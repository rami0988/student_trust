// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'example_item_details_state.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ExampleItemDetailsState extends ExampleItemDetailsState {
  @override
  final Status status;
  @override
  final Failure? failure;
  @override
  final ExampleItem? item;

  factory _$ExampleItemDetailsState([
    void Function(ExampleItemDetailsStateBuilder)? updates,
  ]) => (ExampleItemDetailsStateBuilder()..update(updates))._build();

  _$ExampleItemDetailsState._({required this.status, this.failure, this.item})
    : super._();
  @override
  ExampleItemDetailsState rebuild(
    void Function(ExampleItemDetailsStateBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ExampleItemDetailsStateBuilder toBuilder() =>
      ExampleItemDetailsStateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ExampleItemDetailsState &&
        status == other.status &&
        failure == other.failure &&
        item == other.item;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, failure.hashCode);
    _$hash = $jc(_$hash, item.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ExampleItemDetailsState')
          ..add('status', status)
          ..add('failure', failure)
          ..add('item', item))
        .toString();
  }
}

class ExampleItemDetailsStateBuilder
    implements
        Builder<ExampleItemDetailsState, ExampleItemDetailsStateBuilder> {
  _$ExampleItemDetailsState? _$v;

  Status? _status;
  Status? get status => _$this._status;
  set status(Status? status) => _$this._status = status;

  Failure? _failure;
  Failure? get failure => _$this._failure;
  set failure(Failure? failure) => _$this._failure = failure;

  ExampleItem? _item;
  ExampleItem? get item => _$this._item;
  set item(ExampleItem? item) => _$this._item = item;

  ExampleItemDetailsStateBuilder();

  ExampleItemDetailsStateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _status = $v.status;
      _failure = $v.failure;
      _item = $v.item;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ExampleItemDetailsState other) {
    _$v = other as _$ExampleItemDetailsState;
  }

  @override
  void update(void Function(ExampleItemDetailsStateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ExampleItemDetailsState build() => _build();

  _$ExampleItemDetailsState _build() {
    final _$result =
        _$v ??
        _$ExampleItemDetailsState._(
          status: BuiltValueNullFieldError.checkNotNull(
            status,
            r'ExampleItemDetailsState',
            'status',
          ),
          failure: failure,
          item: item,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
