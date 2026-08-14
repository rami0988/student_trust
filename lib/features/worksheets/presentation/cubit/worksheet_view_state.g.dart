// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'worksheet_view_state.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$WorksheetViewState extends WorksheetViewState {
  @override
  final Status status;
  @override
  final Failure? failure;
  @override
  final List<WorksheetFile> files;
  @override
  final List<WorksheetVideo> videos;
  @override
  final Map<String, double> downloading;
  @override
  final Map<String, String> savedPaths;
  @override
  final String? notice;
  @override
  final String? downloadError;

  factory _$WorksheetViewState([
    void Function(WorksheetViewStateBuilder)? updates,
  ]) => (WorksheetViewStateBuilder()..update(updates))._build();

  _$WorksheetViewState._({
    required this.status,
    this.failure,
    required this.files,
    required this.videos,
    required this.downloading,
    required this.savedPaths,
    this.notice,
    this.downloadError,
  }) : super._();
  @override
  WorksheetViewState rebuild(
    void Function(WorksheetViewStateBuilder) updates,
  ) => (toBuilder()..update(updates)).build();

  @override
  WorksheetViewStateBuilder toBuilder() =>
      WorksheetViewStateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is WorksheetViewState &&
        status == other.status &&
        failure == other.failure &&
        files == other.files &&
        videos == other.videos &&
        downloading == other.downloading &&
        savedPaths == other.savedPaths &&
        notice == other.notice &&
        downloadError == other.downloadError;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, failure.hashCode);
    _$hash = $jc(_$hash, files.hashCode);
    _$hash = $jc(_$hash, videos.hashCode);
    _$hash = $jc(_$hash, downloading.hashCode);
    _$hash = $jc(_$hash, savedPaths.hashCode);
    _$hash = $jc(_$hash, notice.hashCode);
    _$hash = $jc(_$hash, downloadError.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'WorksheetViewState')
          ..add('status', status)
          ..add('failure', failure)
          ..add('files', files)
          ..add('videos', videos)
          ..add('downloading', downloading)
          ..add('savedPaths', savedPaths)
          ..add('notice', notice)
          ..add('downloadError', downloadError))
        .toString();
  }
}

class WorksheetViewStateBuilder
    implements Builder<WorksheetViewState, WorksheetViewStateBuilder> {
  _$WorksheetViewState? _$v;

  Status? _status;
  Status? get status => _$this._status;
  set status(Status? status) => _$this._status = status;

  Failure? _failure;
  Failure? get failure => _$this._failure;
  set failure(Failure? failure) => _$this._failure = failure;

  List<WorksheetFile>? _files;
  List<WorksheetFile>? get files => _$this._files;
  set files(List<WorksheetFile>? files) => _$this._files = files;

  List<WorksheetVideo>? _videos;
  List<WorksheetVideo>? get videos => _$this._videos;
  set videos(List<WorksheetVideo>? videos) => _$this._videos = videos;

  Map<String, double>? _downloading;
  Map<String, double>? get downloading => _$this._downloading;
  set downloading(Map<String, double>? downloading) =>
      _$this._downloading = downloading;

  Map<String, String>? _savedPaths;
  Map<String, String>? get savedPaths => _$this._savedPaths;
  set savedPaths(Map<String, String>? savedPaths) =>
      _$this._savedPaths = savedPaths;

  String? _notice;
  String? get notice => _$this._notice;
  set notice(String? notice) => _$this._notice = notice;

  String? _downloadError;
  String? get downloadError => _$this._downloadError;
  set downloadError(String? downloadError) =>
      _$this._downloadError = downloadError;

  WorksheetViewStateBuilder();

  WorksheetViewStateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _status = $v.status;
      _failure = $v.failure;
      _files = $v.files;
      _videos = $v.videos;
      _downloading = $v.downloading;
      _savedPaths = $v.savedPaths;
      _notice = $v.notice;
      _downloadError = $v.downloadError;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(WorksheetViewState other) {
    _$v = other as _$WorksheetViewState;
  }

  @override
  void update(void Function(WorksheetViewStateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  WorksheetViewState build() => _build();

  _$WorksheetViewState _build() {
    final _$result =
        _$v ??
        _$WorksheetViewState._(
          status: BuiltValueNullFieldError.checkNotNull(
            status,
            r'WorksheetViewState',
            'status',
          ),
          failure: failure,
          files: BuiltValueNullFieldError.checkNotNull(
            files,
            r'WorksheetViewState',
            'files',
          ),
          videos: BuiltValueNullFieldError.checkNotNull(
            videos,
            r'WorksheetViewState',
            'videos',
          ),
          downloading: BuiltValueNullFieldError.checkNotNull(
            downloading,
            r'WorksheetViewState',
            'downloading',
          ),
          savedPaths: BuiltValueNullFieldError.checkNotNull(
            savedPaths,
            r'WorksheetViewState',
            'savedPaths',
          ),
          notice: notice,
          downloadError: downloadError,
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
