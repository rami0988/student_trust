import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/duration_utils.dart';
import '../../../../generated/l10n.dart';
import '../utils/playback_snapshot.dart';
import '../utils/playback_time.dart';
import 'player_chrome.dart';
import 'player_timeline.dart';
import 'skip_button.dart';

/// The player's own controls, drawn over the video (and outside the zoomable
/// area, so zooming never magnifies them).
///
/// Geometry follows media conventions: the timeline, play and skip controls
/// run left → right in every language. The top bar follows the app's reading
/// direction (back button at the start) and text keeps the app direction.
class PlayerControlsOverlay extends StatelessWidget {
  final ValueListenable<PlaybackSnapshot> playback;
  final bool visible;
  final bool isFullscreen;
  final String title;
  final String? subtitle;
  final double speed;

  /// Quality label ("720p"); null hides the quality chip.
  final String? quality;

  /// Seconds skipped by the ± buttons.
  final int skipSeconds;

  /// −1 / 1 while the "skipped back/forward" flash shows, else 0.
  final int skipFlash;

  final VoidCallback onBack;
  final VoidCallback onTogglePlay;
  final VoidCallback onToggleFullscreen;
  final VoidCallback onOpenSettings;
  final ValueChanged<int> onSkip;
  final ValueChanged<double> onSeek;
  final ValueChanged<bool> onScrubbing;

  const PlayerControlsOverlay({
    super.key,
    required this.playback,
    required this.visible,
    required this.isFullscreen,
    required this.title,
    required this.speed,
    required this.onBack,
    required this.onTogglePlay,
    required this.onToggleFullscreen,
    required this.onOpenSettings,
    required this.onSkip,
    required this.onSeek,
    required this.onScrubbing,
    this.subtitle,
    this.quality,
    this.skipSeconds = 10,
    this.skipFlash = 0,
  });

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final TextDirection appDirection = Directionality.of(context);
    final double side = isFullscreen ? 44 : 12;

    return Stack(
      fit: StackFit.expand,
      children: [
        // "Skipped" flash on the side that was skipped — visible even when
        // the controls are hidden.
        _SkipFlash(direction: skipFlash, label: s.secondsShort(skipSeconds), large: isFullscreen),
        IgnorePointer(
          ignoring: !visible,
          child: AnimatedOpacity(
            opacity: visible ? 1 : 0,
            duration: AppTokens.dMed,
            curve: AppTokens.curve,
            child: Stack(
              fit: StackFit.expand,
              children: [
                const IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0x8C000000), Color(0x00000000), Color(0x00000000), Color(0xB8000000)],
                        stops: [0, 0.28, 0.58, 1],
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: isFullscreen ? 8 : 0,
                  left: side - 6,
                  right: side - 6,
                  child: SafeArea(bottom: false, child: _TopBar(overlay: this, appDirection: appDirection)),
                ),
                Positioned.fill(
                  bottom: isFullscreen ? 64 : 48,
                  child: Center(
                    child: ValueListenableBuilder<PlaybackSnapshot>(
                      valueListenable: playback,
                      builder: (context, snap, _) => _CenterButton(
                        playing: snap.isPlaying,
                        buffering: snap.isBuffering,
                        size: isFullscreen ? 72 : 60,
                        tooltip: snap.isPlaying ? s.pauseVideo : s.playVideo,
                        onTap: onTogglePlay,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: side,
                  right: side,
                  bottom: isFullscreen ? 16 : 6,
                  child: SafeArea(top: false, child: _BottomBar(overlay: this, appDirection: appDirection)),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _TopBar extends StatelessWidget {
  final PlayerControlsOverlay overlay;
  final TextDirection appDirection;
  const _TopBar({required this.overlay, required this.appDirection});

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final List<Widget> tools = [
      OverlayChip(label: PlaybackTime.speedLabel(overlay.speed), tooltip: s.playbackSpeed, onPressed: overlay.onOpenSettings),
      if (overlay.quality != null) ...[
        const SizedBox(width: 6),
        OverlayChip(
          label: overlay.quality!,
          tag: qualityTagFor(overlay.quality!),
          tooltip: s.videoQuality,
          onPressed: overlay.onOpenSettings,
        ),
      ],
      OverlayIconButton(
        icon: overlay.isFullscreen ? Icons.fullscreen_exit_rounded : Icons.fullscreen_rounded,
        tooltip: overlay.isFullscreen ? s.exitFullscreen : s.enterFullscreen,
        onPressed: overlay.onToggleFullscreen,
      ),
    ];
    return Directionality(
      textDirection: appDirection,
      child: Row(
        children: [
          OverlayIconButton(
            icon: appDirection == TextDirection.rtl ? Icons.arrow_forward_rounded : Icons.arrow_back_rounded,
            tooltip: MaterialLocalizations.of(context).backButtonTooltip,
            onPressed: overlay.onBack,
          ),
          if (overlay.isFullscreen)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    overlay.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: AppColors.playerInk, fontSize: 15, fontWeight: FontWeight.w800, height: 1.3),
                  ),
                  if (overlay.subtitle != null)
                    Text(
                      overlay.subtitle!,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(color: AppColors.playerInk2, fontSize: 11),
                    ),
                ],
              ),
            )
          else
            const Spacer(),
          ...tools,
        ],
      ),
    );
  }
}

class _CenterButton extends StatelessWidget {
  final bool playing;
  final bool buffering;
  final double size;
  final String tooltip;
  final VoidCallback onTap;

  const _CenterButton({required this.playing, required this.buffering, required this.size, required this.tooltip, required this.onTap});

  @override
  Widget build(BuildContext context) {
    if (buffering) {
      return SizedBox(
        width: size * 0.6,
        height: size * 0.6,
        child: const CircularProgressIndicator(strokeWidth: 3, color: AppColors.playerInk),
      );
    }
    return Tooltip(
      message: tooltip,
      child: Semantics(
        button: true,
        label: tooltip,
        excludeSemantics: true,
        child: Material(
          color: Colors.transparent,
          shape: const CircleBorder(),
          clipBehavior: Clip.antiAlias,
          child: Ink(
            width: size,
            height: size,
            decoration: overlayDecoration(shape: BoxShape.circle),
            child: InkWell(
              onTap: onTap,
              child: AnimatedSwitcher(
                duration: AppTokens.dFast,
                transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
                child: Icon(
                  playing ? Icons.pause_rounded : Icons.play_arrow_rounded,
                  key: ValueKey<bool>(playing),
                  color: AppColors.playerInk,
                  size: size * 0.58,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _BottomBar extends StatelessWidget {
  final PlayerControlsOverlay overlay;
  final TextDirection appDirection;
  const _BottomBar({required this.overlay, required this.appDirection});

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final bool large = overlay.isFullscreen;
    return ValueListenableBuilder<PlaybackSnapshot>(
      valueListenable: overlay.playback,
      builder: (context, snap, _) {
        final Duration remainingAtSpeed = PlaybackTime.atSpeed(snap.remaining, overlay.speed);
        return Directionality(
          textDirection: TextDirection.ltr,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PlayerTimeline(
                played: snap.playedFraction,
                buffered: snap.bufferedFraction,
                onSeek: overlay.onSeek,
                onScrubbing: overlay.onScrubbing,
              ),
              Row(
                children: [
                  SkipButton(
                    seconds: -overlay.skipSeconds,
                    large: large,
                    tooltip: s.skipBack(overlay.skipSeconds),
                    onPressed: () => overlay.onSkip(-overlay.skipSeconds),
                  ),
                  const SizedBox(width: 6),
                  SkipButton(
                    seconds: overlay.skipSeconds,
                    large: large,
                    tooltip: s.skipForward(overlay.skipSeconds),
                    onPressed: () => overlay.onSkip(overlay.skipSeconds),
                  ),
                  const SizedBox(width: AppTokens.s8),
                  Text.rich(
                      TextSpan(
                        children: [
                          TextSpan(
                            text: DurationUtils.format(snap.position.inSeconds),
                            style: const TextStyle(color: AppColors.playerInk),
                          ),
                          TextSpan(
                            text: ' / ${DurationUtils.format(snap.duration.inSeconds)}',
                            style: const TextStyle(color: AppColors.playerInk2),
                          ),
                        ],
                      ),
                    maxLines: 1,
                    softWrap: false,
                    style: TextStyle(fontSize: large ? 13 : 11.5, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(width: AppTokens.s8),
                  // On narrow phones the remaining-time pill shrinks rather
                  // than pushing the skip buttons off the row.
                  if (snap.duration > Duration.zero)
                    Expanded(
                      child: Align(
                        alignment: Alignment.centerRight,
                        child: Container(
                          height: 26,
                          padding: const EdgeInsets.symmetric(horizontal: AppTokens.s8 + 2),
                          decoration: overlayDecoration(),
                          alignment: Alignment.center,
                          child: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              s.remainingAtSpeed(DurationUtils.format(remainingAtSpeed.inSeconds), PlaybackTime.speedLabelInText(overlay.speed)),
                              textDirection: appDirection,
                              style: const TextStyle(color: AppColors.playerInk2, fontSize: 11, fontWeight: FontWeight.w700),
                            ),
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}

/// Brief "10s" flash on the half of the frame that was skipped.
class _SkipFlash extends StatelessWidget {
  final int direction;
  final String label;
  final bool large;
  const _SkipFlash({required this.direction, required this.label, required this.large});

  @override
  Widget build(BuildContext context) {
    Widget side(bool back) {
      final bool active = back ? direction < 0 : direction > 0;
      final Widget icon = Transform.flip(
        flipX: !back,
        child: Icon(Icons.replay_rounded, color: AppColors.playerInk, size: large ? 28 : 22),
      );
      final Widget text = Text(label, style: const TextStyle(color: AppColors.playerInk, fontSize: 13, fontWeight: FontWeight.w800));
      return Expanded(
        flex: 38,
        child: AnimatedOpacity(
          opacity: active ? 1 : 0,
          duration: AppTokens.dMed,
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: back ? Alignment.centerLeft : Alignment.centerRight,
                radius: 1,
                colors: [Colors.white.withValues(alpha: 0.18), Colors.transparent],
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: back ? [icon, const SizedBox(width: 6), text] : [text, const SizedBox(width: 6), icon],
            ),
          ),
        ),
      );
    }

    return IgnorePointer(
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [side(true), const Spacer(flex: 24), side(false)],
        ),
      ),
    );
  }
}
