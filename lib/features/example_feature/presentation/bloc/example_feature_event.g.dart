// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'example_feature_event.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$GetExampleItems extends GetExampleItems {
  @override
  final bool reInitialData;

  factory _$GetExampleItems([void Function(GetExampleItemsBuilder)? updates]) =>
      (GetExampleItemsBuilder()..update(updates))._build();

  _$GetExampleItems._({required this.reInitialData}) : super._();
  @override
  GetExampleItems rebuild(void Function(GetExampleItemsBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  GetExampleItemsBuilder toBuilder() => GetExampleItemsBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is GetExampleItems && reInitialData == other.reInitialData;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, reInitialData.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
      r'GetExampleItems',
    )..add('reInitialData', reInitialData)).toString();
  }
}

class GetExampleItemsBuilder
    implements Builder<GetExampleItems, GetExampleItemsBuilder> {
  _$GetExampleItems? _$v;

  bool? _reInitialData;
  bool? get reInitialData => _$this._reInitialData;
  set reInitialData(bool? reInitialData) =>
      _$this._reInitialData = reInitialData;

  GetExampleItemsBuilder();

  GetExampleItemsBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _reInitialData = $v.reInitialData;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(GetExampleItems other) {
    _$v = other as _$GetExampleItems;
  }

  @override
  void update(void Function(GetExampleItemsBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  GetExampleItems build() => _build();

  _$GetExampleItems _build() {
    final _$result =
        _$v ??
        _$GetExampleItems._(
          reInitialData: BuiltValueNullFieldError.checkNotNull(
            reInitialData,
            r'GetExampleItems',
            'reInitialData',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

class _$LikeExampleItem extends LikeExampleItem {
  @override
  final int itemId;

  factory _$LikeExampleItem([void Function(LikeExampleItemBuilder)? updates]) =>
      (LikeExampleItemBuilder()..update(updates))._build();

  _$LikeExampleItem._({required this.itemId}) : super._();
  @override
  LikeExampleItem rebuild(void Function(LikeExampleItemBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  LikeExampleItemBuilder toBuilder() => LikeExampleItemBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is LikeExampleItem && itemId == other.itemId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, itemId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
      r'LikeExampleItem',
    )..add('itemId', itemId)).toString();
  }
}

class LikeExampleItemBuilder
    implements Builder<LikeExampleItem, LikeExampleItemBuilder> {
  _$LikeExampleItem? _$v;

  int? _itemId;
  int? get itemId => _$this._itemId;
  set itemId(int? itemId) => _$this._itemId = itemId;

  LikeExampleItemBuilder();

  LikeExampleItemBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _itemId = $v.itemId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(LikeExampleItem other) {
    _$v = other as _$LikeExampleItem;
  }

  @override
  void update(void Function(LikeExampleItemBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  LikeExampleItem build() => _build();

  _$LikeExampleItem _build() {
    final _$result =
        _$v ??
        _$LikeExampleItem._(
          itemId: BuiltValueNullFieldError.checkNotNull(
            itemId,
            r'LikeExampleItem',
            'itemId',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

class _$UnlikeExampleItem extends UnlikeExampleItem {
  @override
  final int itemId;

  factory _$UnlikeExampleItem([
    void Function(UnlikeExampleItemBuilder)? updates,
  ]) => (UnlikeExampleItemBuilder()..update(updates))._build();

  _$UnlikeExampleItem._({required this.itemId}) : super._();
  @override
  UnlikeExampleItem rebuild(void Function(UnlikeExampleItemBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  UnlikeExampleItemBuilder toBuilder() =>
      UnlikeExampleItemBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is UnlikeExampleItem && itemId == other.itemId;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, itemId.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(
      r'UnlikeExampleItem',
    )..add('itemId', itemId)).toString();
  }
}

class UnlikeExampleItemBuilder
    implements Builder<UnlikeExampleItem, UnlikeExampleItemBuilder> {
  _$UnlikeExampleItem? _$v;

  int? _itemId;
  int? get itemId => _$this._itemId;
  set itemId(int? itemId) => _$this._itemId = itemId;

  UnlikeExampleItemBuilder();

  UnlikeExampleItemBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _itemId = $v.itemId;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(UnlikeExampleItem other) {
    _$v = other as _$UnlikeExampleItem;
  }

  @override
  void update(void Function(UnlikeExampleItemBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  UnlikeExampleItem build() => _build();

  _$UnlikeExampleItem _build() {
    final _$result =
        _$v ??
        _$UnlikeExampleItem._(
          itemId: BuiltValueNullFieldError.checkNotNull(
            itemId,
            r'UnlikeExampleItem',
            'itemId',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

class _$ChangeExampleItemLikeStateInternally
    extends ChangeExampleItemLikeStateInternally {
  @override
  final int itemId;
  @override
  final bool isLiked;

  factory _$ChangeExampleItemLikeStateInternally([
    void Function(ChangeExampleItemLikeStateInternallyBuilder)? updates,
  ]) =>
      (ChangeExampleItemLikeStateInternallyBuilder()..update(updates))._build();

  _$ChangeExampleItemLikeStateInternally._({
    required this.itemId,
    required this.isLiked,
  }) : super._();
  @override
  ChangeExampleItemLikeStateInternally rebuild(
    void Function(ChangeExampleItemLikeStateInternallyBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  ChangeExampleItemLikeStateInternallyBuilder toBuilder() =>
      ChangeExampleItemLikeStateInternallyBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is ChangeExampleItemLikeStateInternally &&
        itemId == other.itemId &&
        isLiked == other.isLiked;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, itemId.hashCode);
    _$hash = $jc(_$hash, isLiked.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'ChangeExampleItemLikeStateInternally')
          ..add('itemId', itemId)
          ..add('isLiked', isLiked))
        .toString();
  }
}

class ChangeExampleItemLikeStateInternallyBuilder
    implements
        Builder<
          ChangeExampleItemLikeStateInternally,
          ChangeExampleItemLikeStateInternallyBuilder
        > {
  _$ChangeExampleItemLikeStateInternally? _$v;

  int? _itemId;
  int? get itemId => _$this._itemId;
  set itemId(int? itemId) => _$this._itemId = itemId;

  bool? _isLiked;
  bool? get isLiked => _$this._isLiked;
  set isLiked(bool? isLiked) => _$this._isLiked = isLiked;

  ChangeExampleItemLikeStateInternallyBuilder();

  ChangeExampleItemLikeStateInternallyBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _itemId = $v.itemId;
      _isLiked = $v.isLiked;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(ChangeExampleItemLikeStateInternally other) {
    _$v = other as _$ChangeExampleItemLikeStateInternally;
  }

  @override
  void update(
    void Function(ChangeExampleItemLikeStateInternallyBuilder)? updates,
  ) {
    if (updates != null) updates(this);
  }

  @override
  ChangeExampleItemLikeStateInternally build() => _build();

  _$ChangeExampleItemLikeStateInternally _build() {
    final _$result =
        _$v ??
        _$ChangeExampleItemLikeStateInternally._(
          itemId: BuiltValueNullFieldError.checkNotNull(
            itemId,
            r'ChangeExampleItemLikeStateInternally',
            'itemId',
          ),
          isLiked: BuiltValueNullFieldError.checkNotNull(
            isLiked,
            r'ChangeExampleItemLikeStateInternally',
            'isLiked',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
