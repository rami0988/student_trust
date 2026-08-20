// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'lessons_state.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$LessonsState extends LessonsState {
  @override
  final Status status;
  @override
  final Failure? failure;
  @override
  final List<Lesson> lessons;
  @override
  final List<String> downloadedLessonIds;
  @override
  final PaginationModel? pagination;
  @override
  final bool isLoadingMore;

  factory _$LessonsState([void Function(LessonsStateBuilder)? updates]) =>
      (LessonsStateBuilder()..update(updates))._build();

  _$LessonsState._({
    required this.status,
    this.failure,
    required this.lessons,
    required this.downloadedLessonIds,
    this.pagination,
    required this.isLoadingMore,
  }) : super._();
  @override
  LessonsState rebuild(void Function(LessonsStateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  LessonsStateBuilder toBuilder() => LessonsStateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is LessonsState &&
        status == other.status &&
        failure == other.failure &&
        lessons == other.lessons &&
        downloadedLessonIds == other.downloadedLessonIds &&
        pagination == other.pagination &&
        isLoadingMore == other.isLoadingMore;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, failure.hashCode);
    _$hash = $jc(_$hash, lessons.hashCode);
    _$hash = $jc(_$hash, downloadedLessonIds.hashCode);
    _$hash = $jc(_$hash, pagination.hashCode);
    _$hash = $jc(_$hash, isLoadingMore.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'LessonsState')
          ..add('status', status)
          ..add('failure', failure)
          ..add('lessons', lessons)
          ..add('downloadedLessonIds', downloadedLessonIds)
          ..add('pagination', pagination)
          ..add('isLoadingMore', isLoadingMore))
        .toString();
  }
}

class LessonsStateBuilder
    implements Builder<LessonsState, LessonsStateBuilder> {
  _$LessonsState? _$v;

  Status? _status;
  Status? get status => _$this._status;
  set status(Status? status) => _$this._status = status;

  Failure? _failure;
  Failure? get failure => _$this._failure;
  set failure(Failure? failure) => _$this._failure = failure;

  List<Lesson>? _lessons;
  List<Lesson>? get lessons => _$this._lessons;
  set lessons(List<Lesson>? lessons) => _$this._lessons = lessons;

  List<String>? _downloadedLessonIds;
  List<String>? get downloadedLessonIds => _$this._downloadedLessonIds;
  set downloadedLessonIds(List<String>? downloadedLessonIds) =>
      _$this._downloadedLessonIds = downloadedLessonIds;

  PaginationModel? _pagination;
  PaginationModel? get pagination => _$this._pagination;
  set pagination(PaginationModel? pagination) =>
      _$this._pagination = pagination;

  bool? _isLoadingMore;
  bool? get isLoadingMore => _$this._isLoadingMore;
  set isLoadingMore(bool? isLoadingMore) =>
      _$this._isLoadingMore = isLoadingMore;

  LessonsStateBuilder();

  LessonsStateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _status = $v.status;
      _failure = $v.failure;
      _lessons = $v.lessons;
      _downloadedLessonIds = $v.downloadedLessonIds;
      _pagination = $v.pagination;
      _isLoadingMore = $v.isLoadingMore;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(LessonsState other) {
    _$v = other as _$LessonsState;
  }

  @override
  void update(void Function(LessonsStateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  LessonsState build() => _build();

  _$LessonsState _build() {
    final _$result =
        _$v ??
        _$LessonsState._(
          status: BuiltValueNullFieldError.checkNotNull(
            status,
            r'LessonsState',
            'status',
          ),
          failure: failure,
          lessons: BuiltValueNullFieldError.checkNotNull(
            lessons,
            r'LessonsState',
            'lessons',
          ),
          downloadedLessonIds: BuiltValueNullFieldError.checkNotNull(
            downloadedLessonIds,
            r'LessonsState',
            'downloadedLessonIds',
          ),
          pagination: pagination,
          isLoadingMore: BuiltValueNullFieldError.checkNotNull(
            isLoadingMore,
            r'LessonsState',
            'isLoadingMore',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
