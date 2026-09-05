import 'dart:async';

import 'package:better_player_plus/better_player_plus.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/di.dart';
import '../../../../core/network/endpoints.dart';
import '../../../../core/services/device_service.dart';
import '../../../../core/services/security_service.dart';
import '../../../../core/theme/colors_manager.dart';
import '../../../../core/utils/duration_utils.dart';
import '../../../../core/utils/local_storage_keys.dart';
import '../../../../core/utils/shared_preferences_helper.dart';
import '../../../../generated/l10n.dart';
import '../../../downloads/data/services/encrypted_download_service.dart';
import '../../../lessons/domain/repositories/lessons_repository.dart';
import '../cubit/video_cubit.dart';
import '../cubit/video_state.dart';
import '../widgets/security_overlay.dart';
import '../widgets/video_watermark.dart';
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

class _VideoPlayerViewState extends State<_VideoPlayerView> with WidgetsBindingObserver {
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
  bool _refreshing = false;

  /// Ceiling on URL re-resolves. Two covers the real case (a signature that
  /// expired, plus one race); beyond that the failure isn't about the URL.
  static const int _maxRefreshAttempts = 2;
  int _refreshAttempts = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
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
    context.read<VideoCubit>().loadVideo(
      lessonId: widget.args.lessonId,
      isOffline: widget.args.isOffline,
      studentId: _studentId,
      deviceUuid: _deviceUuid,
      savedPosition: widget.args.savedPosition,
      streamEndpoint: widget.args.streamEndpoint,
    );
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

  Future<void> _saveCurrentProgress() async {
    if (!widget.args.trackProgress) return;
    final int pos = _currentPositionSeconds;
    if (pos <= 0) return;
    try {
      await _lessonsRepository.saveProgress(widget.args.lessonId, pos, false);
    } catch (_) {
      // Offline / transient — ignore; progress will be retried next tick.
    }
  }

  BetterPlayerDataSource _dataSourceFor(VideoState state) {
    if (state.isLocal) {
      return BetterPlayerDataSource(BetterPlayerDataSourceType.file, state.videoUrl!.replaceFirst('file://', ''));
    }
    // BunnyCDN pull-zone requests must carry the embed Referer (the library
    // allow-lists it); the dev streaming endpoint needs the bearer instead.
    return BetterPlayerDataSource(
      BetterPlayerDataSourceType.network,
      state.videoUrl!,
      headers: state.authToken != null ? {'Authorization': 'Bearer ${state.authToken}'} : BunnyConstants.cdnHeaders,
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
        controlsConfiguration: const BetterPlayerControlsConfiguration(
          controlBarColor: Colors.black54,
          iconsColor: Colors.white,
          progressBarPlayedColor: ColorsManager.primary,
          progressBarHandleColor: ColorsManager.orange,
          // Disabled: better_player's built-in fullscreen pushes its own
          // route WITHOUT our watermark/security overlays. We provide our
          // own fullscreen toggle that rotates to the landscape layout
          // instead, keeping all overlays mounted.
          enableFullscreen: false,
        ),
      ),
      betterPlayerDataSource: _dataSourceFor(state),
    );
    _betterPlayerController!.addEventsListener(_onPlayerEvent);
  }

  /// Handles a new ready [VideoState] emission: build the player the first
  /// time, or swap in a refreshed signed URL (after token expiry) without
  /// losing state.
  Future<void> _onVideoReady(VideoState state) async {
    if (_betterPlayerController == null) {
      _setupController(state);
      return;
    }
    if (state.videoUrl == _currentUrl) return;
    _currentUrl = state.videoUrl;
    try {
      await _betterPlayerController!.setupDataSource(_dataSourceFor(state));
      if (state.savedPosition > 0) {
        await _betterPlayerController!.seekTo(Duration(seconds: state.savedPosition));
      }
      await _betterPlayerController!.play();
      // Playback resumed on the new URL, so the budget is about consecutive
      // failures, not lifetime ones — a three-hour lesson may legitimately
      // outlive several signatures.
      _refreshAttempts = 0;
    } catch (_) {
      // Ignore — the next event or user retry will recover.
    } finally {
      _refreshing = false;
    }
  }

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

  void _onPlayerEvent(BetterPlayerEvent event) {
    if (event.betterPlayerEventType == BetterPlayerEventType.exception) {
      // The usual cause is an expired BunnyCDN signature, which a fresh URL
      // fixes. But the player raises the same event for a corrupt file or an
      // unsupported codec, and those never recover — without a ceiling the
      // page spins exception → refresh → exception forever, showing the
      // student a permanently loading video instead of an error.
      if (widget.args.isOffline || _refreshing) return;
      if (_refreshAttempts >= _maxRefreshAttempts) {
        _showPlaybackError();
        return;
      }
      _refreshAttempts++;
      _refreshing = true;
      context.read<VideoCubit>().refreshVideoUrl(widget.args.lessonId, savedPosition: _currentPositionSeconds);
    }
  }

  /// Gives up on re-resolving and tells the student plainly. Uses the cubit's
  /// own failure state so this renders as the page's normal error view.
  void _showPlaybackError() {
    if (!mounted) return;
    context.read<VideoCubit>().reportPlaybackFailure(S.of(context).somethingWentWrong);
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
    // Offline playback decrypts the lesson into a plaintext temp file. Leaving
    // it behind hands anyone with file access an unencrypted copy of every
    // lesson the student has watched — which defeats the point of encrypting
    // the chunks at rest — and it accumulates. Fire-and-forget: dispose can't
    // await, and a failed cleanup must never break leaving the screen (the
    // 2-hour staleness check and deleteLesson both still cover it).
    if (widget.args.isOffline) {
      unawaited(getIt<EncryptedDownloadService>().clearTempFile(widget.args.lessonId).catchError((_) {}));
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isLandscape = MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      backgroundColor: Colors.black,
      // Hide the AppBar in landscape so the video can fill the screen.
      appBar: isLandscape
          ? null
          : AppBar(
              backgroundColor: Colors.black,
              foregroundColor: Colors.white,
              title: Text(widget.args.lessonTitle, style: const TextStyle(color: Colors.white), overflow: TextOverflow.ellipsis),
            ),
      body: BlocConsumer<VideoCubit, VideoState>(
        listener: (context, state) {
          if (state.isReady) _onVideoReady(state);
        },
        builder: (context, state) {
          if (state.status.isInitial || state.status.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Colors.white));
          }
          if (state.status.isFailure && state.isProcessing) {
            return _ProcessingView(onRetry: _init);
          }
          if (state.status.isFailure) {
            return _ErrorView(message: state.failure?.statusMessage ?? S.of(context).somethingWentWrong);
          }
          // Ready or recording-detected — keep the player mounted.
          return _buildPlayer(isLandscape, state);
        },
      ),
    );
  }

  Widget _buildPlayer(bool isLandscape, VideoState state) {
    final controller = _betterPlayerController;
    if (controller == null) {
      return const Center(child: CircularProgressIndicator(color: Colors.white));
    }

    final Widget videoStack = Stack(
      fit: StackFit.expand,
      children: [
        BetterPlayer(key: _playerKey, controller: controller),
        VideoWatermark(studentName: widget.args.studentName, phoneNumber: widget.args.studentPhone),
        if (state.isRecordingDetected) const SecurityOverlay(),
      ],
    );

    if (isLandscape) {
      // Fullscreen video with a floating exit button (back to portrait).
      return Stack(
        children: [
          Positioned.fill(child: videoStack),
          Positioned(
            top: 8,
            right: 8,
            child: SafeArea(
              child: _VideoOverlayButton(
                icon: Icons.fullscreen_exit_rounded,
                tooltip: S.of(context).exitFullscreen,
                onPressed: _exitFullscreen,
              ),
            ),
          ),
        ],
      );
    }

    // Portrait: 16:9 video on top (with a fullscreen toggle), scrollable
    // lesson info below.
    return Column(
      children: [
        AspectRatio(
          aspectRatio: 16 / 9,
          child: Stack(
            children: [
              Positioned.fill(child: videoStack),
              Positioned(
                top: 4,
                left: 4,
                child: _VideoOverlayButton(
                  icon: Icons.fullscreen_rounded,
                  tooltip: S.of(context).enterFullscreen,
                  onPressed: _enterFullscreen,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.args.lessonTitle,
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.timer_outlined, color: Colors.white54, size: 14),
                    const SizedBox(width: 4),
                    Text(DurationUtils.format(_currentPositionSeconds), style: const TextStyle(color: Colors.white54, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

/// Small translucent circular button drawn over the video (fullscreen
/// enter/exit). Kept above the player so it works with the controls hidden.
class _VideoOverlayButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  const _VideoOverlayButton({required this.icon, required this.tooltip, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.black45,
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: IconButton(tooltip: tooltip, icon: Icon(icon, color: Colors.white), onPressed: onPressed),
    );
  }
}

/// Friendly "video is still transcoding" screen — not an error: the video
/// exists, BunnyCDN just hasn't finished processing it yet.
class _ProcessingView extends StatelessWidget {
  final VoidCallback onRetry;
  const _ProcessingView({required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.hourglass_top, color: Colors.white, size: 56),
            const SizedBox(height: 16),
            Text(S.of(context).videoProcessingMessage, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 16)),
            const SizedBox(height: 20),
            ElevatedButton.icon(onPressed: onRetry, icon: const Icon(Icons.refresh), label: Text(S.of(context).retry)),
            const SizedBox(height: 8),
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(S.of(context).back, style: const TextStyle(color: Colors.white70)),
            ),
          ],
        ),
      ),
    );
  }
}

class _ErrorView extends StatelessWidget {
  final String message;
  const _ErrorView({required this.message});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 56),
            const SizedBox(height: 16),
            Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white, fontSize: 16)),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: () => Navigator.of(context).pop(), child: Text(S.of(context).back)),
          ],
        ),
      ),
    );
  }
}
