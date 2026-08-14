// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'download_state.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$DownloadState extends DownloadState {
  @override
  final Map<String, DownloadItem> items;

  factory _$DownloadState([void Function(DownloadStateBuilder)? updates]) =>
      (DownloadStateBuilder()..update(updates))._build();

  _$DownloadState._({required this.items}) : super._();
  @override
  DownloadState rebuild(void Function(DownloadStateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  DownloadStateBuilder toBuilder() => DownloadStateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is DownloadState && items == other.items;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, items.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
      r'DownloadState',
    )..add('items', items)).toString();
  }
}

class DownloadStateBuilder
    implements Builder<DownloadState, DownloadStateBuilder> {
  _$DownloadState? _$v;

  Map<String, DownloadItem>? _items;
  Map<String, DownloadItem>? get items => _$this._items;
  set items(Map<String, DownloadItem>? items) => _$this._items = items;

  DownloadStateBuilder();

  DownloadStateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _items = $v.items;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(DownloadState other) {
    _$v = other as _$DownloadState;
  }

  @override
  void update(void Function(DownloadStateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  DownloadState build() => _build();

  _$DownloadState _build() {
    final _$result =
        _$v ??
        _$DownloadState._(
          items: BuiltValueNullFieldError.checkNotNull(
            items,
            r'DownloadState',
            'items',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
