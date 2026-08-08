// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'example_feature_state.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$ExampleFeatureState extends ExampleFeatureState {
  @override
  final Status status;
  @override
  final Failure? failure;
  @override
  final PaginationStateData<ExampleItem> items;

  factory _$ExampleFeatureState([
    void Function(ExampleFeatureStateBuilder)? updates,
  ]) => (ExampleFeatureStateBuilder()..update(updates))._build();

  _$ExampleFeatureState._({
    required this.status,
    this.failure,
    required this.items,
  }) : super._();
  @override
  ExampleFeatureState rebuild(
    void Function(ExampleFeatureStateBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ExampleFeatureStateBuilder toBuilder() =>
      ExampleFeatureStateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ExampleFeatureState &&
        status == other.status &&
        failure == other.failure &&
        items == other.items;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, failure.hashCode);
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ExampleFeatureState')
          ..add('status', status)
          ..add('failure', failure)
          ..add('items', items))
        .toString();
  }
}

class ExampleFeatureStateBuilder
    implements Builder<ExampleFeatureState, ExampleFeatureStateBuilder> {
  _$ExampleFeatureState? _$v;

  Status? _status;
  Status? get status => _$this._status;
  set status(Status? status) => _$this._status = status;

  Failure? _failure;
  Failure? get failure => _$this._failure;
  set failure(Failure? failure) => _$this._failure = failure;

  PaginationStateDataBuilder<ExampleItem>? _items;
  PaginationStateDataBuilder<ExampleItem> get items =>
      _$this._items ??= PaginationStateDataBuilder<ExampleItem>();
  set items(PaginationStateDataBuilder<ExampleItem>? items) =>
      _$this._items = items;

  ExampleFeatureStateBuilder();

  ExampleFeatureStateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _status = $v.status;
      _failure = $v.failure;
      _items = $v.items.toBuilder();
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ExampleFeatureState other) {
    _$v = other as _$ExampleFeatureState;
  }

  @override
  void update(void Function(ExampleFeatureStateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  ExampleFeatureState build() => _build();

  _$ExampleFeatureState _build() {
    _$ExampleFeatureState _$result;
    try {
      _$result =
          _$v ??
          _$ExampleFeatureState._(
            status: BuiltValueNullFieldError.checkNotNull(
              status,
              r'ExampleFeatureState',
              'status',
            ),
            failure: failure,
            items: items.build(),
          );
    } catch (_) {
      late String _$failedField;
      try {
        _$failedField = 'items';
        items.build();
      } catch (e) {
        throw BuiltValueNestedFieldError(
          r'ExampleFeatureState',
          _$failedField,
          e.toString(),
        );
      }
      rethrow;
    }
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
