// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'video_state.dart';

// **************************************************************************
// BuiltValueGenerator
// **************************************************************************

class _$VideoState extends VideoState {
  @override
  final Status status;
  @override
  final Failure? failure;
  @override
  final String? videoUrl;
  @override
  final bool isLocal;
  @override
  final String? authToken;
  @override
  final int savedPosition;
  @override
  final String? thumbnailUrl;
  @override
  final String? expiresAt;
  @override
  final bool isProcessing;
  @override
  final bool isRecordingDetected;

  factory _$VideoState([void Function(VideoStateBuilder)? updates]) =>
      (VideoStateBuilder()..update(updates))._build();

  _$VideoState._({
    required this.status,
    this.failure,
    this.videoUrl,
    required this.isLocal,
    this.authToken,
    required this.savedPosition,
    this.thumbnailUrl,
    this.expiresAt,
    required this.isProcessing,
    required this.isRecordingDetected,
  }) : super._();
  @override
  VideoState rebuild(void Function(VideoStateBuilder) updates) =>
      (toBuilder()..update(updates)).build();

  @override
  VideoStateBuilder toBuilder() => VideoStateBuilder()..replace(this);

  @override
  bool operator ==(Object other) {
    if (identical(other, this)) return true;
    return other is VideoState &&
        status == other.status &&
        failure == other.failure &&
        videoUrl == other.videoUrl &&
        isLocal == other.isLocal &&
        authToken == other.authToken &&
        savedPosition == other.savedPosition &&
        thumbnailUrl == other.thumbnailUrl &&
        expiresAt == other.expiresAt &&
        isProcessing == other.isProcessing &&
        isRecordingDetected == other.isRecordingDetected;
  }

  @override
  int get hashCode {
    var _$hash = 0;
    _$hash = $jc(_$hash, status.hashCode);
    _$hash = $jc(_$hash, failure.hashCode);
    _$hash = $jc(_$hash, videoUrl.hashCode);
    _$hash = $jc(_$hash, isLocal.hashCode);
    _$hash = $jc(_$hash, authToken.hashCode);
    _$hash = $jc(_$hash, savedPosition.hashCode);
    _$hash = $jc(_$hash, thumbnailUrl.hashCode);
    _$hash = $jc(_$hash, expiresAt.hashCode);
    _$hash = $jc(_$hash, isProcessing.hashCode);
    _$hash = $jc(_$hash, isRecordingDetected.hashCode);
    _$hash = $jf(_$hash);
    return _$hash;
  }

  @override
  String toString() {
    return (newBuiltValueToStringHelper(r'VideoState')
          ..add('status', status)
          ..add('failure', failure)
          ..add('videoUrl', videoUrl)
          ..add('isLocal', isLocal)
          ..add('authToken', authToken)
          ..add('savedPosition', savedPosition)
          ..add('thumbnailUrl', thumbnailUrl)
          ..add('expiresAt', expiresAt)
          ..add('isProcessing', isProcessing)
          ..add('isRecordingDetected', isRecordingDetected))
        .toString();
  }
}

class VideoStateBuilder implements Builder<VideoState, VideoStateBuilder> {
  _$VideoState? _$v;

  Status? _status;
  Status? get status => _$this._status;
  set status(Status? status) => _$this._status = status;

  Failure? _failure;
  Failure? get failure => _$this._failure;
  set failure(Failure? failure) => _$this._failure = failure;

  String? _videoUrl;
  String? get videoUrl => _$this._videoUrl;
  set videoUrl(String? videoUrl) => _$this._videoUrl = videoUrl;

  bool? _isLocal;
  bool? get isLocal => _$this._isLocal;
  set isLocal(bool? isLocal) => _$this._isLocal = isLocal;

  String? _authToken;
  String? get authToken => _$this._authToken;
  set authToken(String? authToken) => _$this._authToken = authToken;

  int? _savedPosition;
  int? get savedPosition => _$this._savedPosition;
  set savedPosition(int? savedPosition) =>
      _$this._savedPosition = savedPosition;

  String? _thumbnailUrl;
  String? get thumbnailUrl => _$this._thumbnailUrl;
  set thumbnailUrl(String? thumbnailUrl) => _$this._thumbnailUrl = thumbnailUrl;

  String? _expiresAt;
  String? get expiresAt => _$this._expiresAt;
  set expiresAt(String? expiresAt) => _$this._expiresAt = expiresAt;

  bool? _isProcessing;
  bool? get isProcessing => _$this._isProcessing;
  set isProcessing(bool? isProcessing) => _$this._isProcessing = isProcessing;

  bool? _isRecordingDetected;
  bool? get isRecordingDetected => _$this._isRecordingDetected;
  set isRecordingDetected(bool? isRecordingDetected) =>
      _$this._isRecordingDetected = isRecordingDetected;

  VideoStateBuilder();

  VideoStateBuilder get _$this {
    final $v = _$v;
    if ($v != null) {
      _status = $v.status;
      _failure = $v.failure;
      _videoUrl = $v.videoUrl;
      _isLocal = $v.isLocal;
      _authToken = $v.authToken;
      _savedPosition = $v.savedPosition;
      _thumbnailUrl = $v.thumbnailUrl;
      _expiresAt = $v.expiresAt;
      _isProcessing = $v.isProcessing;
      _isRecordingDetected = $v.isRecordingDetected;
      _$v = null;
    }
    return this;
  }

  @override
  void replace(VideoState other) {
    _$v = other as _$VideoState;
  }

  @override
  void update(void Function(VideoStateBuilder)? updates) {
    if (updates != null) updates(this);
  }

  @override
  VideoState build() => _build();

  _$VideoState _build() {
    final _$result =
        _$v ??
        _$VideoState._(
          status: BuiltValueNullFieldError.checkNotNull(
            status,
            r'VideoState',
            'status',
          ),
          failure: failure,
          videoUrl: videoUrl,
          isLocal: BuiltValueNullFieldError.checkNotNull(
            isLocal,
            r'VideoState',
            'isLocal',
          ),
          authToken: authToken,
          savedPosition: BuiltValueNullFieldError.checkNotNull(
            savedPosition,
            r'VideoState',
            'savedPosition',
          ),
          thumbnailUrl: thumbnailUrl,
          expiresAt: expiresAt,
          isProcessing: BuiltValueNullFieldError.checkNotNull(
            isProcessing,
            r'VideoState',
            'isProcessing',
          ),
          isRecordingDetected: BuiltValueNullFieldError.checkNotNull(
            isRecordingDetected,
            r'VideoState',
            'isRecordingDetected',
          ),
        );
    replace(_$result);
    return _$result;
  }
}

// ignore_for_file: deprecated_member_use_from_same_package,type=lint
