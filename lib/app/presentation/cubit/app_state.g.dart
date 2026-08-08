// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_state.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$AppState extends AppState {
  @override
  final Language language;
  @override
  final AppFlavor flavor;

  factory _$AppState([void Function(AppStateBuilder)? updates]) =>
      (AppStateBuilder()..update(updates))._build();

  _$AppState._({required this.language, required this.flavor}) : super._();
  @override
  AppState rebuild(void Function(AppStateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  AppStateBuilder toBuilder() => AppStateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is AppState &&
        language == other.language &&
        flavor == other.flavor;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, language.hashCode);
    _$hash = $jc(_$hash, flavor.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'AppState')
          ..add('language', language)
          ..add('flavor', flavor))
        .toString();
  }
}

class AppStateBuilder implements Builder<AppState, AppStateBuilder> {
  _$AppState? _$v;

  Language? _language;
  Language? get language => _$this._language;
  set language(Language? language) => _$this._language = language;

  AppFlavor? _flavor;
  AppFlavor? get flavor => _$this._flavor;
  set flavor(AppFlavor? flavor) => _$this._flavor = flavor;

  AppStateBuilder();

  AppStateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _language = $v.language;
      _flavor = $v.flavor;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(AppState other) {
    _$v = other as _$AppState;
  }

  @override
  void update(void Function(AppStateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  AppState build() => _build();

  _$AppState _build() {
    final _$result =
        _$v ??
        _$AppState._(
          language: BuiltValueNullFieldError.checkNotNull(
            language,
            r'AppState',
            'language',
          ),
          flavor: BuiltValueNullFieldError.checkNotNull(
            flavor,
            r'AppState',
            'flavor',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
