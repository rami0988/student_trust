import 'dart:async';

import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/di.dart';
import '../../../../core/network/endpoints.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/services/device_service.dart';
import '../../../../core/services/security_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/duration_utils.dart';
import '../../../../core/utils/local_storage_keys.dart';
import '../../../../core/utils/shared_preferences_helper.dart';
import '../../../../core/widgets/app_network_image.dart';
import '../../../../generated/l10n.dart';
import '../../../lessons/domain/repositories/lessons_repository.dart';
import '../cubit/video_cubit.dart';
import '../cubit/video_state.dart';
import '../utils/playback_snapshot.dart';
import '../utils/playback_time.dart';
import '../utils/zoom_geometry.dart';
import '../widgets/lesson_info_panel.dart';
import '../widgets/playback_settings_sheet.dart';
import '../widgets/playback_status_views.dart';
import '../widgets/player_chrome.dart';
import '../widgets/player_controls_overlay.dart';
import '../widgets/security_overlay.dart';
import '../widgets/video_watermark.dart';
import '../widgets/zoom_controls.dart';
import 'video_player_args.dart';

class VideoPlayerPage extends StatelessWidget {
  final VideoPlayerArgs args;
  const VideoPlayerPage({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    return BlocProvider<VideoCubit>(create: (_) => getIt<VideoCubit>(), child: _VideoPlayerView(args: args));
  }
}

class _VideoPlayerView extends StatefulWidget {
  final VideoPlayerArgs args;
  const _VideoPlayerView({required this.args});

  @override
  State<_VideoPlayerView> createState() => _VideoPlayerViewState();
}

class _VideoPlayerViewState extends State<_VideoPlayerView> with WidgetsBindingObserver, TickerProviderStateMixin {
  final SecurityService _securityService = getIt<SecurityService>();
  final DeviceService _deviceService = getIt<DeviceService>();
  // Page-level cross-feature repository read (not a bloc-to-bloc dependency)
  // — mirrors OLD app's VideoPlayerScreen, needed to persist playback
  // position periodically.
  final LessonsRepository _lessonsRepository = getIt<LessonsRepository>();

  BetterPlayerController? _betterPlayerController;
  StreamSubscription<bool>? _captureSub;
  Timer? _progressTimer;

  /// Keeps the [BetterPlayer] element alive when the layout switches between
  /// the portrait and landscape branches (reparenting instead of rebuild), so
  /// rotation never recreates the underlying platform view.
  final GlobalKey _playerKey = GlobalKey();

  String _studentId = '';
  String _deviceUuid = '';

  /// The URL currently loaded into the player, used to detect a refreshed
  /// (rotated) BunnyCDN signed URL so we can swap the data source in place.
  String? _currentUrl;

  /// Set by "retry" on the error view: reload the source even if the URL that
  /// comes back is the same one that failed.
  bool _forceReload = false;

  // ── Recovery ladder ────────────────────────────────────────────

  /// Ceiling on playback-recovery attempts before the student is shown a real
  /// error. Four retries with backoff covers a tunnel, a lift, or a cell/Wi-Fi
  /// handover; past that the problem isn't transient.
  static const int _maxRecoveryAttempts = 4;
  int _recoveryAttempts = 0;

  /// True while a recovery attempt is scheduled or in flight, so the burst of
  /// exception events a single failure produces collapses into one retry.
  bool _recovering = false;

  /// Drives the retry overlay (instead of an error screen).
  bool _isRecovering = false;
  Timer? _recoveryTimer;

  /// When the scheduled retry fires; the overlay counts down to it.
  DateTime? _retryAt;
  Timer? _retryTicker;

  /// Last position known to be playing, so a recovery resumes where the
  /// student was rather than at 0 — reading it after the failure returns 0.
  int _lastGoodPositionSeconds = 0;

  // ── Custom controls ────────────────────────────────────────────

  /// Snapshot of the native player for the custom controls, refreshed from
  /// the video controller's listener.
  final ValueNotifier<PlaybackSnapshot> _playback = ValueNotifier<PlaybackSnapshot>(PlaybackSnapshot.empty);

  /// The video controller we're listening to (better_player doesn't export
  /// its type, only the value it carries).
  Listenable? _observedVideo;
  bool _wasPlaying = false;

  bool _controlsVisible = true;
  bool _scrubbing = false;
  Timer? _hideTimer;
  static const Duration _autoHideAfter = Duration(seconds: 3);

  static const int _skipSeconds = 10;

  /// −1 / 1 while the "skipped" flash is up.
  int _skipFlash = 0;
  Timer? _skipFlashTimer;

  /// Current playback speed; restored from the student's last choice.
  double _speed = 1.0;

  /// Quality the student picked in the sheet; null = backend default.
  String? _selectedQuality;

  // ── Zoom ───────────────────────────────────────────────────────

  /// Pinch-zoom on the video only — the watermark, the controls and the
  /// security overlay sit outside the zoomed area, so zooming can never push
  /// them off screen or magnify them.
  final TransformationController _zoomController = TransformationController();
  late final AnimationController _zoomAnimation = AnimationController(vsync: this, duration: AppTokens.dSlow);
  Animation<Matrix4>? _zoomTween;
  bool _isZoomed = false;
  Size _viewport = Size.zero;

  /// Layout the zoom was applied in; a rotation resets it, since the matrix
  /// is in the old viewport's coordinates.
  bool? _lastLandscape;

  /// One-time "pinch to zoom" hint.
  bool _showPinchHint = false;
  Timer? _pinchHintTimer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final double savedSpeed = SharedPreferencesHelper.getDouble(LocalStorageKeys.playbackSpeed);
    _speed = PlaybackTime.speeds.contains(savedSpeed) ? savedSpeed : 1.0;
    _zoomController.addListener(_onZoomChanged);
    _zoomAnimation.addListener(() {
      final Animation<Matrix4>? tween = _zoomTween;
      if (tween != null) _zoomController.value = tween.value;
    });
    // Allow landscape for fullscreen video watching (overrides the global
    // portrait lock) and go fullscreen.
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    _securityService.enableSecureScreen();
    _init();
    _startScreenRecordingCheck();
    _startProgressSaveTimer();
  }

  Future<void> _init() async {
    _studentId = await SharedPreferencesHelper.getSecuredString(LocalStorageKeys.userId);
    _deviceUuid = await _deviceService.getDeviceUuid();
    if (!mounted) return;
    final int startAt = _resumePosition();
    _lastGoodPositionSeconds = startAt;
    context.read<VideoCubit>().loadVideo(
      lessonId: widget.args.lessonId,
      isOffline: widget.args.isOffline,
      studentId: _studentId,
      deviceUuid: _deviceUuid,
      savedPosition: startAt,
      streamEndpoint: widget.args.streamEndpoint,
    );
  }

  /// Where to start: this device's last saved position, else the server's.
  ///
  /// The server value alone is why lessons "didn't continue from where we
  /// stopped": it comes from the lessons list loaded BEFORE the last watch
  /// (never refreshed after leaving the player), offline playback never passed
  /// one at all, and a save that failed on a weak connection was simply lost.
  /// The account is bound to this one device, so the local copy is always
  /// the most recent.
  int _resumePosition() {
    if (!widget.args.trackProgress) return widget.args.savedPosition;
    final int local = SharedPreferencesHelper.getInt(LocalStorageKeys.videoPosition(widget.args.lessonId));
    return local > 0 ? local : widget.args.savedPosition;
  }

  void _startScreenRecordingCheck() {
    _captureSub = _securityService.screenCaptureStream.listen((isCapturing) {
      if (!mounted) return;
      final cubit = context.read<VideoCubit>();
      if (isCapturing) {
        _betterPlayerController?.pause();
        cubit.screenRecordingDetected();
      } else if (cubit.state.isRecordingDetected) {
        cubit.resumeVideo();
      }
    });
  }

  void _startProgressSaveTimer() {
    if (!widget.args.trackProgress) return;
    _progressTimer = Timer.periodic(const Duration(seconds: 10), (_) => _saveCurrentProgress());
  }

  int get _currentPositionSeconds => _betterPlayerController?.videoPlayerController?.value.position.inSeconds ?? 0;

  /// Remembers the newest non-zero position while playback is healthy. After a
  /// failure the controller reports 0, so recovery needs this to resume where
  /// the student actually was instead of restarting the lesson.
  void _rememberPosition() {
    final int pos = _currentPositionSeconds;
    if (pos > 0) _lastGoodPositionSeconds = pos;
  }

  Future<void> _saveCurrentProgress() async {
    _rememberPosition();
    if (!widget.args.trackProgress || _finished) return;
    final int pos = _currentPositionSeconds;
    if (pos <= 0) return;
    // Local first: it survives no connection and an app kill, and it is what
    // the next open resumes from (see [_resumePosition]).
    await SharedPreferencesHelper.setData(LocalStorageKeys.videoPosition(widget.args.lessonId), pos);
    try {
      await _lessonsRepository.saveProgress(widget.args.lessonId, pos, false);
    } catch (_) {
      // Offline / transient — ignore; progress will be retried next tick.
    }
  }

  /// Set once the lesson plays to the end, so the periodic/dispose saves
  /// don't write the end position back over the "start from 0" reset.
  bool _finished = false;

  /// The lesson played to the end: mark it completed and start the next
  /// watch from the beginning instead of the last second.
  Future<void> _onFinished() async {
    if (!widget.args.trackProgress || _finished) return;
    _finished = true;
    await SharedPreferencesHelper.setData(LocalStorageKeys.videoPosition(widget.args.lessonId), 0);
    try {
      await _lessonsRepository.saveProgress(widget.args.lessonId, 0, true);
    } catch (_) {}
  }

  /// Buffering tuned for the slow, intermittent mobile connections most
  /// students are on.
  ///
  /// ExoPlayer's defaults start playback after only 2.5s of buffer and resume
  /// after a stall on 5s, which on a weak link means a seek into unbuffered
  /// video repeatedly starves and gives up. Asking for a deeper cushion makes
  /// a seek wait and fill rather than fail, at the cost of a slightly longer
  /// spinner.
  ///
  /// `maxBufferMs` is capped at 2 minutes. The package default (~109 min,
  /// "buffer as far ahead as you like") kept downloading far beyond what the
  /// student watched — someone who opened a lesson and left after 5 minutes
  /// still paid for much of it in mobile data, and every seek or recovery
  /// threw that buffer away. Two minutes ahead is plenty to ride out a weak
  /// connection.
  static const BetterPlayerBufferingConfiguration _buffering = BetterPlayerBufferingConfiguration(
    minBufferMs: 50000,
    maxBufferMs: 120000,
    bufferForPlaybackMs: 5000,
    bufferForPlaybackAfterRebufferMs: 10000,
  );

  /// Renditions behind the source currently loaded, to find which quality the
  /// student picked when a refreshed URL arrives.
  Map<String, String> _loadedRenditions = const {};

  /// The quality (e.g. "720p") whose URL the player is playing right now, if
  /// it is one of [_loadedRenditions].
  String? _playingQuality() {
    final String? playing = _betterPlayerController?.betterPlayerDataSource?.url;
    if (playing == null) return null;
    for (final MapEntry<String, String> e in _loadedRenditions.entries) {
      if (e.value == playing) return e.key;
    }
    return null;
  }

  /// [quality] keeps a quality the student chose when the URL is re-signed.
  BetterPlayerDataSource _dataSourceFor(VideoState state, {String? quality}) {
    if (state.isLocal) {
      _loadedRenditions = const {};
      // Downloaded lesson, streamed from the on-device loopback server
      // (OfflineMediaServer), which decrypts chunks on demand. The player's
      // disk cache stays OFF: it would write the decrypted video back to disk,
      // which is exactly what streaming exists to avoid.
      return BetterPlayerDataSource(
        BetterPlayerDataSourceType.network,
        state.videoUrl!,
        cacheConfiguration: const BetterPlayerCacheConfiguration(useCache: false),
      );
    }
    // Every encoded quality, signed by the backend; the playback settings
    // sheet lists them so a student on weak data can drop to 360p (or go up on
    // Wi-Fi). The default URL is the backend's data-friendly pick. Empty on
    // older backends → no quality choice, same behaviour as before.
    final Map<String, String> renditions = state.authToken == null ? context.read<VideoCubit>().renditions : const {};
    _loadedRenditions = renditions;
    final String url = (quality != null ? renditions[quality] : null) ?? state.videoUrl!;
    // BunnyCDN pull-zone requests must carry the embed Referer (the library
    // allow-lists it); the dev streaming endpoint needs the bearer instead.
    return BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      url,
      headers: state.authToken != null ? {'Authorization': 'Bearer ${state.authToken}'} : BunnyConstants.cdnHeaders,
      bufferingConfiguration: _buffering,
    );
  }

  void _setupController(VideoState state) {
    if (_betterPlayerController != null) return;

    _currentUrl = state.videoUrl;
    _betterPlayerController = BetterPlayerController(
      BetterPlayerConfiguration(
        autoPlay: false,
        aspectRatio: 16 / 9,
        fit: BoxFit.contain,
        startAt: Duration(seconds: state.savedPosition),
        // The portrait/landscape layouts mount the player at different spots
        // in the tree. autoDispose (default true) would dispose the
        // controller the moment the old spot unmounts on rotation → "used
        // after being disposed". We dispose it ourselves in [dispose].
        autoDispose: false,
        // better_player's own controls are replaced by [PlayerControlsOverlay]:
        // they live outside the zoomable area (zoom never magnifies them),
        // and its fullscreen route would drop our watermark/security overlay.
        controlsConfiguration: const BetterPlayerControlsConfiguration(
          showControls: false,
          enableFullscreen: false,
          enablePlaybackSpeed: false,
        ),
      ),
      betterPlayerDataSource: _dataSourceFor(state, quality: _selectedQuality),
    );
    _betterPlayerController!.addEventsListener(_onPlayerEvent);
    _attachVideoListener();
  }

  // ── Playback snapshot for the custom controls ──────────────────

  void _attachVideoListener() {
    final Listenable? video = _betterPlayerController?.videoPlayerController;
    if (video == null || identical(video, _observedVideo)) return;
    _observedVideo?.removeListener(_onVideoValue);
    _observedVideo = video..addListener(_onVideoValue);
    _onVideoValue();
  }

  void _onVideoValue() {
    final VideoPlayerValue? v = _betterPlayerController?.videoPlayerController?.value;
    if (v == null) return;
    Duration bufferedEnd = v.position;
    for (final range in v.buffered) {
      if (range.start <= v.position && range.end > bufferedEnd) bufferedEnd = range.end;
    }
    _playback.value = PlaybackSnapshot(
      position: v.position,
      duration: v.duration ?? Duration.zero,
      bufferedEnd: bufferedEnd,
      isPlaying: v.isPlaying,
      isBuffering: v.isBuffering,
    );
    if (v.isPlaying != _wasPlaying) {
      _wasPlaying = v.isPlaying;
      // Paused → controls come back and stay; playing → they fade after a bit.
      if (!v.isPlaying) {
        _showControls();
      } else {
        _scheduleHide();
      }
    }
  }

  void _showControls() {
    if (!mounted) return;
    if (!_controlsVisible) setState(() => _controlsVisible = true);
    _scheduleHide();
  }

  void _scheduleHide() {
    _hideTimer?.cancel();
    if (!_playback.value.isPlaying || _scrubbing) return;
    _hideTimer = Timer(_autoHideAfter, () {
      if (mounted && _playback.value.isPlaying && !_scrubbing) setState(() => _controlsVisible = false);
    });
  }

  void _toggleControls() {
    if (_controlsVisible) {
      _hideTimer?.cancel();
      setState(() => _controlsVisible = false);
    } else {
      _showControls();
    }
  }

  void _onScrubbing(bool scrubbing) {
    _scrubbing = scrubbing;
    if (scrubbing) {
      _hideTimer?.cancel();
    } else {
      _scheduleHide();
    }
  }

  Future<void> _seekTo(Duration target) async {
    final BetterPlayerController? controller = _betterPlayerController;
    if (controller == null) return;
    final Duration duration = _playback.value.duration;
    final Duration clamped = target < Duration.zero ? Duration.zero : (duration > Duration.zero && target > duration ? duration : target);
    if (clamped.inSeconds > 0) _lastGoodPositionSeconds = clamped.inSeconds;
    try {
      await controller.seekTo(clamped);
    } catch (_) {
      // Not initialized yet — nothing to seek.
    }
  }

  void _seekToFraction(double fraction) {
    final Duration duration = _playback.value.duration;
    if (duration <= Duration.zero) return;
    _seekTo(duration * fraction);
    _showControls();
  }

  void _skip(int seconds) {
    _seekTo(_playback.value.position + Duration(seconds: seconds));
    _skipFlashTimer?.cancel();
    setState(() => _skipFlash = seconds < 0 ? -1 : 1);
    _skipFlashTimer = Timer(const Duration(milliseconds: 650), () {
      if (mounted) setState(() => _skipFlash = 0);
    });
    _showControls();
  }

  Future<void> _togglePlay() async {
    final BetterPlayerController? controller = _betterPlayerController;
    if (controller == null) return;
    if (controller.isPlaying() == true) {
      await controller.pause();
    } else {
      final PlaybackSnapshot snap = _playback.value;
      // At the very end, "play" means watch again.
      if (snap.duration > Duration.zero && snap.remaining < const Duration(seconds: 1)) await _seekTo(Duration.zero);
      await controller.play();
    }
  }

  // ── Speed & quality ────────────────────────────────────────────

  /// Applies [_speed] to the player. Called on every `initialized` event too,
  /// because loading a data source (first load, recovery, re-signed URL)
  /// starts the native player back at 1x.
  Future<void> _applySpeed() async {
    final BetterPlayerController? controller = _betterPlayerController;
    if (controller == null || controller.isVideoInitialized() != true) return;
    try {
      await controller.setSpeed(_speed);
    } catch (_) {
      // Not initialized yet — the `initialized` event applies it.
    }
  }

  Future<void> _setSpeed(double speed) async {
    if (speed == _speed) return;
    setState(() => _speed = speed);
    await _applySpeed();
    await SharedPreferencesHelper.setData(LocalStorageKeys.playbackSpeed, speed);
  }

  Map<String, String> get _renditions {
    final VideoCubit cubit = context.read<VideoCubit>();
    return cubit.state.isLocal ? const {} : cubit.renditions;
  }

  /// The quality shown on the chip/sheet, or null when there's no choice.
  String? get _qualityLabel {
    if (_renditions.isEmpty) return null;
    return _selectedQuality ?? _playingQuality() ?? context.read<VideoCubit>().resolution ?? _renditions.keys.first;
  }

  /// Switches to [quality] in place, keeping position and play/pause.
  Future<void> _selectQuality(String quality) async {
    final BetterPlayerController? controller = _betterPlayerController;
    final VideoState state = context.read<VideoCubit>().state;
    if (controller == null || state.isLocal || quality == _qualityLabel) return;
    setState(() => _selectedQuality = quality);
    final Duration position = _playback.value.position;
    final bool wasPlaying = controller.isPlaying() == true;
    try {
      await controller.setupDataSource(_dataSourceFor(state, quality: quality));
      if (position > Duration.zero) await controller.seekTo(position);
      if (wasPlaying) await controller.play();
    } catch (_) {
      // A failed switch surfaces as an exception event → recovery ladder.
    }
  }

  Future<void> _openSettings() async {
    _hideTimer?.cancel();
    final PlaybackSnapshot snap = _playback.value;
    final Duration lesson = snap.duration > Duration.zero ? snap.duration : Duration(seconds: widget.args.durationSeconds);
    final Map<String, String> renditions = _renditions;
    await showPlaybackSettingsSheet(
      context: context,
      speed: _speed,
      onSpeedChanged: _setSpeed,
      lessonDuration: lesson,
      chapterDuration: widget.args.chapterDurationSeconds != null ? Duration(seconds: widget.args.chapterDurationSeconds!) : null,
      qualities: renditions.keys.toList(),
      selectedQuality: _qualityLabel,
      defaultQuality: context.read<VideoCubit>().resolution,
      onQualityChanged: _selectQuality,
    );
    if (mounted) _scheduleHide();
  }

  // ── Zoom ───────────────────────────────────────────────────────

  ZoomGeometry get _zoomGeometry => ZoomGeometry.fromMatrix(_zoomController.value, _viewport);

  void _onZoomChanged() {
    final bool zoomed = _zoomController.value.getMaxScaleOnAxis() > 1.01;
    if (zoomed && _showPinchHint) _dismissPinchHint();
    if (zoomed == _isZoomed) return;
    setState(() => _isZoomed = zoomed);
  }

  /// Moves the zoom to [target]; animated for taps (presets, ±, reset),
  /// immediate for drags so the view tracks the finger.
  void _applyZoom(ZoomGeometry target, {bool animate = false}) {
    if (_viewport.isEmpty) return;
    final Matrix4 end = target.toMatrix(_viewport);
    if (!animate) {
      _zoomAnimation.stop();
      _zoomController.value = end;
      return;
    }
    _zoomTween = Matrix4Tween(begin: _zoomController.value.clone(), end: end)
        .animate(CurvedAnimation(parent: _zoomAnimation, curve: AppTokens.curveEmphasized));
    _zoomAnimation.forward(from: 0);
  }

  void _zoomTo(double scale, {bool animate = true}) => _applyZoom(_zoomGeometry.withScale(scale), animate: animate);

  void _resetZoom() => _applyZoom(ZoomGeometry.identity, animate: true);

  void _maybeShowPinchHint() {
    if (_showPinchHint || SharedPreferencesHelper.getBool(LocalStorageKeys.zoomHintSeen)) return;
    setState(() => _showPinchHint = true);
    _pinchHintTimer = Timer(const Duration(seconds: 4), _dismissPinchHint);
  }

  void _dismissPinchHint() {
    _pinchHintTimer?.cancel();
    if (mounted && _showPinchHint) setState(() => _showPinchHint = false);
    SharedPreferencesHelper.setData(LocalStorageKeys.zoomHintSeen, true);
  }

  // ── Fullscreen & navigation ────────────────────────────────────

  /// Forces the landscape (fullscreen) layout. The screen's landscape branch
  /// renders the video full-bleed with the watermark/security overlays intact.
  void _enterFullscreen() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.landscapeLeft, DeviceOrientation.landscapeRight]);
  }

  /// Returns to the portrait layout. All orientations are re-allowed shortly
  /// after, so physically rotating the phone still enters fullscreen.
  void _exitFullscreen() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp, DeviceOrientation.portraitDown]);
    Future<void>.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.portraitUp,
        DeviceOrientation.portraitDown,
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    });
  }

  bool get _isLandscape => MediaQuery.orientationOf(context) == Orientation.landscape;

  void _toggleFullscreen() => _isLandscape ? _exitFullscreen() : _enterFullscreen();

  /// Back from fullscreen returns to portrait first; from portrait it leaves.
  void _onBack() => _isLandscape ? _exitFullscreen() : Navigator.of(context).maybePop();

  void _playNext(VideoPlayerArgs next) {
    Navigator.of(context).pushReplacementNamed(Routes.videoPlayer, arguments: next);
  }

  // ── Player events & recovery ladder ────────────────────────────

  /// Handles a new ready [VideoState] emission: build the player the first
  /// time, or swap in a refreshed signed URL (after token expiry) without
  /// losing state.
  Future<void> _onVideoReady(VideoState state) async {
    if (_betterPlayerController == null) {
      _setupController(state);
      setState(() {});
      return;
    }
    if (state.videoUrl == _currentUrl && !_forceReload) {
      // Same URL came back (nothing to swap) — still finish the recovery
      // step, or `_recovering` would stay true and block every later retry.
      if (_recovering) await _retryCurrentSource();
      return;
    }
    _forceReload = false;
    _currentUrl = state.videoUrl;
    try {
      await _betterPlayerController!.setupDataSource(_dataSourceFor(state, quality: _selectedQuality ?? _playingQuality()));
      if (state.savedPosition > 0) {
        await _betterPlayerController!.seekTo(Duration(seconds: state.savedPosition));
      }
      await _betterPlayerController!.play();
      // Playback resumed, so the budget is about CONSECUTIVE failures, not
      // lifetime ones — a three-hour lesson may legitimately outlive several
      // signatures and survive several tunnels.
      _recoveryAttempts = 0;
      _endRecoveryOverlay();
    } catch (_) {
      // Ignore — the next exception event continues the recovery ladder.
    } finally {
      _recovering = false;
    }
  }

  void _onPlayerEvent(BetterPlayerEvent event) {
    switch (event.betterPlayerEventType) {
      case BetterPlayerEventType.initialized:
        _attachVideoListener();
        unawaited(_applySpeed());
        if (mounted) _maybeShowPinchHint();
        return;
      case BetterPlayerEventType.progress:
        _rememberPosition();
        return;
      case BetterPlayerEventType.seekTo:
        // A seek into unbuffered video is the most common failure. Remember
        // the TARGET, so recovery resumes where the student jumped to rather
        // than snapping back to where they were before the seek.
        final dynamic target = event.parameters?['duration'];
        if (target is Duration && target.inSeconds > 0) _lastGoodPositionSeconds = target.inSeconds;
        return;
      case BetterPlayerEventType.finished:
        unawaited(_onFinished());
        _showControls();
        return;
      case BetterPlayerEventType.play:
        // Replay after the end — track this new watch normally again.
        if (_finished) _finished = false;
        return;
      case BetterPlayerEventType.exception:
        // A network hiccup — very often a seek into not-yet-buffered video on
        // a weak connection — surfaces here identically to a genuinely broken
        // file. Treating every one as fatal is what put "can't play the video"
        // over a video that would have played a second later.
        //
        // So recover first and only report a failure once recovery is
        // exhausted: reload the same position, backing off between tries.
        // Offline playback gets the same treatment minus the URL re-resolve.
        if (_recovering) return;
        _scheduleRecovery();
        return;
      default:
        return;
    }
  }

  /// One step of the recovery ladder: wait (1s, 2s, 4s, 8s), then reload —
  /// or show the error once the attempts are used up.
  void _scheduleRecovery() {
    if (_recoveryAttempts >= _maxRecoveryAttempts) {
      _endRecoveryOverlay();
      _showPlaybackError();
      return;
    }

    _recovering = true;
    _recoveryAttempts++;
    // 1s, 2s, 4s, 8s — long enough for a phone switching cell/Wi-Fi to settle.
    final Duration backoff = Duration(milliseconds: 500 * (1 << _recoveryAttempts));
    _retryAt = DateTime.now().add(backoff);
    setState(() => _isRecovering = true);
    // Ticks the overlay's countdown once a second.
    _retryTicker ??= Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });

    _recoveryTimer?.cancel();
    _recoveryTimer = Timer(backoff, () {
      if (!mounted) {
        _recovering = false;
        return;
      }
      if (widget.args.isOffline) {
        unawaited(_retryCurrentSource());
      } else {
        // Re-resolving also re-signs the CDN URL, which covers the other
        // common cause (an expired signature) in the same path.
        unawaited(_refreshAndContinue());
      }
    });
  }

  void _endRecoveryOverlay() {
    _retryTicker?.cancel();
    _retryTicker = null;
    _retryAt = null;
    if (mounted && _isRecovering) setState(() => _isRecovering = false);
  }

  int get _retrySecondsLeft {
    final DateTime? at = _retryAt;
    if (at == null) return 0;
    final int ms = at.difference(DateTime.now()).inMilliseconds;
    return ms <= 0 ? 0 : (ms / 1000).ceil();
  }

  /// Re-resolves the URL; when that request itself fails (still no
  /// connection), moves to the next rung of the ladder instead of leaving the
  /// "retrying" overlay up forever.
  Future<void> _refreshAndContinue() async {
    final bool refreshed = await context.read<VideoCubit>().refreshVideoUrl(
      widget.args.lessonId,
      savedPosition: _lastGoodPositionSeconds,
    );
    if (refreshed || !mounted) return;
    _recovering = false;
    _scheduleRecovery();
  }

  /// Reloads the current data source at the last known position. Used for
  /// offline recovery, where there is no URL to re-resolve.
  Future<Duration?> _retryCurrentSource() async {
    final BetterPlayerController? controller = _betterPlayerController;
    final VideoState state = context.read<VideoCubit>().state;
    if (controller == null || state.videoUrl == null) {
      _recovering = false;
      return null;
    }
    final Duration target = Duration(seconds: _lastGoodPositionSeconds);
    try {
      await controller.setupDataSource(_dataSourceFor(state, quality: _selectedQuality ?? _playingQuality()));
      if (target > Duration.zero) await controller.seekTo(target);
      await controller.play();
      _endRecoveryOverlay();
      _recoveryAttempts = 0;
    } catch (_) {
      // Leave the ladder to the next exception event.
    } finally {
      _recovering = false;
    }
    return target;
  }

  /// Gives up on re-resolving and tells the student plainly. Uses the cubit's
  /// own failure state so this renders as the page's normal error view.
  void _showPlaybackError() {
    if (!mounted) return;
    context.read<VideoCubit>().reportPlaybackFailure(S.of(context).somethingWentWrong);
  }

  /// "Retry" on the error view: a fresh load at the last good position, and
  /// a fresh recovery budget.
  void _retryAfterError() {
    _recoveryAttempts = 0;
    _recovering = false;
    _forceReload = true;
    context.read<VideoCubit>().loadVideo(
      lessonId: widget.args.lessonId,
      isOffline: widget.args.isOffline,
      studentId: _studentId,
      deviceUuid: _deviceUuid,
      savedPosition: _lastGoodPositionSeconds > 0 ? _lastGoodPositionSeconds : _resumePosition(),
      streamEndpoint: widget.args.streamEndpoint,
    );
  }

  /// Stops audio when the app is backgrounded — leaving via the home button
  /// or the app switcher never triggers [dispose], so without this the lesson
  /// keeps playing out loud behind other apps. Also saves progress, since
  /// the periodic timer stops running once we're not resumed.
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state != AppLifecycleState.resumed) {
      _betterPlayerController?.pause();
      _saveCurrentProgress();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    // The app has no global orientation lock (see main.dart) — leave every
    // orientation available on exit instead of narrowing back to portrait,
    // so the rest of the app keeps rotating freely.
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    _securityService.disableSecureScreen();
    _saveCurrentProgress();
    _progressTimer?.cancel();
    _recoveryTimer?.cancel();
    _retryTicker?.cancel();
    _hideTimer?.cancel();
    _skipFlashTimer?.cancel();
    _pinchHintTimer?.cancel();
    _observedVideo?.removeListener(_onVideoValue);
    _playback.dispose();
    _zoomAnimation.dispose();
    _zoomController
      ..removeListener(_onZoomChanged)
      ..dispose();
    _captureSub?.cancel();
    // Pause first so audio stops instantly rather than at the end of the exit
    // animation. `forceDispose: true` is REQUIRED:
    // BetterPlayerController.dispose() starts with
    // `if (!autoDispose && !forceDispose) return;` — so with our
    // `autoDispose: false` (set in [_setupController] to survive rotation) a
    // plain dispose() is a silent no-op and the native player keeps playing
    // audio forever after the page is gone.
    _betterPlayerController?.pause();
    _betterPlayerController?.dispose(forceDispose: true);
    // Offline playback writes no plaintext file, so there is nothing to clean
    // up here; VideoCubit.close() stops serving the lesson.
    super.dispose();
  }

  // ── Layout ─────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final bool isLandscape = _isLandscape;
    return Scaffold(
      backgroundColor: AppColors.playerBg,
      body: BlocConsumer<VideoCubit, VideoState>(
        listener: (context, state) {
          if (state.isReady) _onVideoReady(state);
        },
        builder: (context, state) {
          final Widget playerArea = _buildPlayerArea(state, isLandscape);
          if (isLandscape) return playerArea;
          // Portrait: 16:9 player on top, lesson info (or the zoom panel
          // while zoomed) below.
          return SafeArea(
            bottom: false,
            child: Column(
              children: [
                AspectRatio(aspectRatio: 16 / 9, child: playerArea),
                Expanded(
                  child: AnimatedSwitcher(
                    duration: AppTokens.dMed,
                    child: _isZoomed && state.isReady
                        ? SingleChildScrollView(
                            key: const ValueKey('zoom-panel'),
                            child: ValueListenableBuilder<Matrix4>(
                              valueListenable: _zoomController,
                              builder: (context, _, _) => ZoomPanel(geometry: _zoomGeometry, onScale: _zoomTo),
                            ),
                          )
                        : LessonInfoPanel(
                            key: const ValueKey('lesson-info'),
                            args: widget.args,
                            playback: _playback,
                            speed: _speed,
                            quality: state.isReady ? _qualityLabel : null,
                            onOpenSettings: _openSettings,
                            onPlayNext: _playNext,
                          ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildPlayerArea(VideoState state, bool isLandscape) {
    final S s = S.of(context);
    if (state.status.isFailure && state.isProcessing) {
      return PlaybackMessageView(
        icon: Icons.hourglass_top_rounded,
        iconColor: AppColors.warningBright,
        title: s.videoProcessingMessage,
        primaryLabel: s.retry,
        onPrimary: _init,
        compact: !isLandscape,
      );
    }
    if (state.status.isFailure) {
      final String? resume = _lastGoodPositionSeconds > 0 ? s.resumeFrom(DurationUtils.format(_lastGoodPositionSeconds)) : null;
      return PlaybackMessageView(
        icon: Icons.error_outline_rounded,
        title: s.cannotPlayVideo,
        message: [state.failure?.statusMessage ?? s.somethingWentWrong, ?resume].join(' · '),
        primaryLabel: s.retry,
        onPrimary: _retryAfterError,
        compact: !isLandscape,
      );
    }
    final BetterPlayerController? controller = _betterPlayerController;
    if (!state.isReady || controller == null) {
      return Stack(
        children: [
          const Center(child: CircularProgressIndicator(color: AppColors.playerInk)),
          PositionedDirectional(
            top: 0,
            start: 6,
            child: SafeArea(
              child: OverlayIconButton(
                icon: Directionality.of(context) == TextDirection.rtl ? Icons.arrow_forward_rounded : Icons.arrow_back_rounded,
                tooltip: MaterialLocalizations.of(context).backButtonTooltip,
                onPressed: () => Navigator.of(context).maybePop(),
              ),
            ),
          ),
        ],
      );
    }

    // The zoom matrix is in the old viewport's coordinates, so a rotation
    // starts unzoomed (after this frame — the listener calls setState).
    if (_lastLandscape != null && _lastLandscape != isLandscape && _isZoomed) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _zoomController.value = Matrix4.identity();
      });
    }
    _lastLandscape = isLandscape;

    return LayoutBuilder(
      builder: (context, constraints) {
        _viewport = constraints.biggest;
        return Stack(
          fit: StackFit.expand,
          children: [
            // Only the video is zoomable. Pinch to zoom (up to 4x); drag to pan
            // once zoomed. Panning is off at 1x so it can't fight the seek bar.
            InteractiveViewer(
              transformationController: _zoomController,
              minScale: ZoomGeometry.minScale,
              maxScale: ZoomGeometry.maxScale,
              panEnabled: _isZoomed,
              child: BetterPlayer(key: _playerKey, controller: controller),
            ),
            // Outside the zoom: the watermark always covers the visible frame.
            VideoWatermark(studentName: widget.args.studentName, phoneNumber: widget.args.studentPhone),
            // Taps toggle the controls; translucent so pinches still reach the
            // InteractiveViewer underneath.
            Positioned.fill(
              child: GestureDetector(behavior: HitTestBehavior.translucent, onTap: _toggleControls, child: const SizedBox.expand()),
            ),
            if (_isZoomed)
              _buildZoomHud(isLandscape)
            else
              PlayerControlsOverlay(
                playback: _playback,
                visible: _controlsVisible,
                isFullscreen: isLandscape,
                title: widget.args.lessonTitle,
                subtitle: _subtitle(s),
                speed: _speed,
                quality: _qualityLabel,
                skipSeconds: _skipSeconds,
                skipFlash: _skipFlash,
                onBack: _onBack,
                onTogglePlay: _togglePlay,
                onToggleFullscreen: _toggleFullscreen,
                onOpenSettings: _openSettings,
                onSkip: _skip,
                onSeek: _seekToFraction,
                onScrubbing: _onScrubbing,
              ),
            if (_showPinchHint && !_isZoomed)
              Positioned(
                top: isLandscape ? 70 : 52,
                left: 0,
                right: 0,
                child: IgnorePointer(child: Center(child: _PinchHint(label: s.pinchToZoom))),
              ),
            // Non-intrusive: the video stays mounted and keeps its position
            // underneath, so a recovered hiccup resumes rather than restarts.
            if (_isRecovering)
              RetryOverlay(
                attempt: _recoveryAttempts.clamp(1, _maxRecoveryAttempts),
                maxAttempts: _maxRecoveryAttempts,
                secondsLeft: _retrySecondsLeft,
                resumeAt: _lastGoodPositionSeconds > 0 ? DurationUtils.format(_lastGoodPositionSeconds) : null,
              ),
            if (state.isRecordingDetected) const SecurityOverlay(),
          ],
        );
      },
    );
  }

  String? _subtitle(S s) {
    final VideoPlayerArgs a = widget.args;
    final List<String> parts = [
      if (a.lessonNumber != null && a.lessonCount != null) s.lessonOfCount(a.lessonNumber!, a.lessonCount!),
      if (a.chapterTitle != null && a.chapterTitle!.isNotEmpty) a.chapterTitle!,
    ];
    return parts.isEmpty ? null : parts.join(' · ');
  }

  /// While zoomed: a compact toolbar (play/pause, reset, speed), the zoom
  /// badge, the vertical zoom rail and the PiP mini-map.
  Widget _buildZoomHud(bool isLandscape) {
    final S s = S.of(context);
    final String? thumb = context.read<VideoCubit>().state.thumbnailUrl ?? widget.args.thumbnailUrl;
    final Widget preview = thumb != null && thumb.isNotEmpty
        ? AppNetworkImage(
            url: thumb,
            httpHeaders: BunnyConstants.cdnHeaders,
            cacheKey: BunnyConstants.stableCacheKey(thumb),
            errorWidget: const _MiniMapPlaceholder(),
          )
        : const _MiniMapPlaceholder();
    final double inset = isLandscape ? 24 : 10;

    return ValueListenableBuilder<Matrix4>(
      valueListenable: _zoomController,
      builder: (context, _, _) {
        final ZoomGeometry geometry = _zoomGeometry;
        return Directionality(
          textDirection: TextDirection.ltr,
          child: Stack(
            children: [
              Positioned(
                top: isLandscape ? 8 : 2,
                left: inset - 6,
                child: SafeArea(
                  child: ValueListenableBuilder<PlaybackSnapshot>(
                    valueListenable: _playback,
                    builder: (context, snap, _) => Row(
                      children: [
                        OverlayIconButton(
                          icon: snap.isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
                          tooltip: snap.isPlaying ? s.pauseVideo : s.playVideo,
                          onPressed: _togglePlay,
                        ),
                        OverlayIconButton(icon: Icons.zoom_out_map_rounded, tooltip: s.resetZoom, onPressed: _resetZoom),
                        OverlayChip(label: PlaybackTime.speedLabel(_speed), tooltip: s.playbackSpeed, onPressed: _openSettings),
                        if (isLandscape)
                          OverlayIconButton(icon: Icons.fullscreen_exit_rounded, tooltip: s.exitFullscreen, onPressed: _exitFullscreen),
                      ],
                    ),
                  ),
                ),
              ),
              Positioned(
                top: isLandscape ? 20 : 12,
                right: inset + 50,
                child: SafeArea(child: _ZoomBadge(label: geometry.label)),
              ),
              Positioned(
                right: inset,
                top: isLandscape ? 64 : 50,
                bottom: inset,
                child: ZoomRail(geometry: geometry, onScale: (v) => _zoomTo(v, animate: false)),
              ),
              Positioned(
                left: inset,
                bottom: inset,
                child: ZoomMiniMap(
                  geometry: geometry,
                  preview: preview,
                  onCenter: (c) => _applyZoom(geometry.withCenter(c)),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _ZoomBadge extends StatelessWidget {
  final String label;
  const _ZoomBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: AppTokens.s8 + 2),
      decoration: overlayDecoration(),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 6, height: 6, decoration: const BoxDecoration(color: AppColors.accentLight, shape: BoxShape.circle)),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: AppColors.playerInk, fontSize: 12.5, fontWeight: FontWeight.w800)),
        ],
      ),
    );
  }
}

class _PinchHint extends StatelessWidget {
  final String label;
  const _PinchHint({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 30,
      padding: const EdgeInsets.symmetric(horizontal: AppTokens.s12),
      decoration: overlayDecoration(color: AppColors.glassStrong),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.pinch_rounded, color: AppColors.playerInk, size: 15),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(color: AppColors.playerInk, fontSize: 11.5, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

class _MiniMapPlaceholder extends StatelessWidget {
  const _MiniMapPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(gradient: AppTokens.brandGradient),
      child: Center(child: Icon(Icons.crop_free_rounded, color: AppColors.playerInk2, size: 20)),
    );
  }
}
