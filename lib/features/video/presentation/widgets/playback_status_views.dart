import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../generated/l10n.dart';

/// Shown over the frozen, dimmed frame while a weak-connection failure is
/// being retried: a spinner, which attempt this is, when the next try
/// happens, and where playback will resume. Quiet on purpose — most of these
/// resolve on their own within a few seconds.
class RetryOverlay extends StatelessWidget {
  final int attempt;
  final int maxAttempts;

  /// Seconds until the next try; 0 while the try is in flight.
  final int secondsLeft;

  /// "14:58" — where playback resumes, or null if unknown.
  final String? resumeAt;

  const RetryOverlay({super.key, required this.attempt, required this.maxAttempts, required this.secondsLeft, this.resumeAt});

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    final List<String> details = [
      s.retryAttempt(attempt, maxAttempts),
      if (secondsLeft > 0) s.retryInSeconds(secondsLeft) else s.retryingNow,
      if (resumeAt != null) s.resumeFrom(resumeAt!),
    ];
    return Semantics(
      liveRegion: true,
      label: '${s.weakConnectionRetrying} ${details.join('، ')}',
      excludeSemantics: true,
      child: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 3, sigmaY: 3),
          child: Container(
            color: Colors.black.withValues(alpha: 0.55),
            alignment: Alignment.center,
            padding: const EdgeInsets.all(AppTokens.s16),
            child: FittedBox(
              fit: BoxFit.scaleDown,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const SizedBox(width: 52, height: 52, child: _RetryRing()),
                  const SizedBox(height: AppTokens.s8),
                  Text(
                    s.weakConnectionRetrying,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.playerInk, fontSize: 14, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    details.join(' · '),
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.playerInk2, fontSize: 11.5),
                  ),
                  const SizedBox(height: AppTokens.s8),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        for (int i = 1; i <= maxAttempts; i++)
                          _Step(state: i < attempt ? _StepKind.done : (i == attempt ? _StepKind.now : _StepKind.todo)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _RetryRing extends StatefulWidget {
  const _RetryRing();

  @override
  State<_RetryRing> createState() => _RetryRingState();
}

class _RetryRingState extends State<_RetryRing> with SingleTickerProviderStateMixin {
  late final AnimationController _spin = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..repeat();

  @override
  void dispose() {
    _spin.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.expand,
      children: [
        RotationTransition(turns: _spin, child: const CustomPaint(painter: _ArcPainter())),
        const Icon(Icons.wifi_rounded, color: AppColors.warningBright, size: 20),
      ],
    );
  }
}

class _ArcPainter extends CustomPainter {
  const _ArcPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = (Offset.zero & size).deflate(2);
    canvas.drawArc(rect, 0, math.pi * 2, false, Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..color = Colors.white.withValues(alpha: 0.12));
    canvas.drawArc(rect, -math.pi / 2, math.pi * 0.6, false, Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..color = AppColors.warningBright);
  }

  @override
  bool shouldRepaint(_ArcPainter oldDelegate) => false;
}

enum _StepKind { done, now, todo }

class _Step extends StatefulWidget {
  final _StepKind state;
  const _Step({required this.state});

  @override
  State<_Step> createState() => _StepViewState();
}

class _StepViewState extends State<_Step> with SingleTickerProviderStateMixin {
  late final AnimationController _pulse = AnimationController(vsync: this, duration: const Duration(seconds: 1));

  @override
  void initState() {
    super.initState();
    _sync();
  }

  @override
  void didUpdateWidget(_Step oldWidget) {
    super.didUpdateWidget(oldWidget);
    _sync();
  }

  void _sync() {
    if (widget.state == _StepKind.now) {
      if (!_pulse.isAnimating) _pulse.repeat(reverse: true);
    } else {
      _pulse
        ..stop()
        ..value = 0;
    }
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final Color color = widget.state == _StepKind.todo ? Colors.white.withValues(alpha: 0.2) : AppColors.warningBright;
    return FadeTransition(
      opacity: Tween<double>(begin: 1, end: 0.45).animate(_pulse),
      child: Container(
        width: 18,
        height: 4,
        margin: const EdgeInsets.symmetric(horizontal: 2),
        decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
      ),
    );
  }
}

/// Error / processing state for the player area: an icon, a title, a short
/// explanation, a primary action (retry) and "back".
class PlaybackMessageView extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String? message;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final bool compact;

  const PlaybackMessageView({
    super.key,
    required this.icon,
    required this.title,
    required this.primaryLabel,
    required this.onPrimary,
    this.message,
    this.iconColor = AppColors.errorBright,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final S s = S.of(context);
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: const Alignment(0, -0.2),
          radius: 0.9,
          colors: [iconColor.withValues(alpha: 0.16), AppColors.playerBg.withValues(alpha: 0.95)],
        ),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.all(AppTokens.s16),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 360),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: compact ? 48 : 64,
                height: compact ? 48 : 64,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: iconColor.withValues(alpha: 0.18),
                  boxShadow: [BoxShadow(color: iconColor.withValues(alpha: 0.08), spreadRadius: 6)],
                ),
                child: Icon(icon, color: iconColor, size: compact ? 24 : 30),
              ),
              const SizedBox(height: AppTokens.s12),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.playerInk, fontSize: compact ? 14 : 17, fontWeight: FontWeight.w800),
              ),
              if (message != null) ...[
                const SizedBox(height: AppTokens.s4),
                Text(
                  message!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.playerInk2, fontSize: compact ? 11.5 : 13.5, height: 1.5),
                ),
              ],
              SizedBox(height: compact ? AppTokens.s12 : AppTokens.s20),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _GradientButton(label: primaryLabel, icon: Icons.refresh_rounded, onTap: onPrimary, compact: compact),
                  const SizedBox(width: AppTokens.s8),
                  OutlinedButton(
                    onPressed: () => Navigator.of(context).maybePop(),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.playerInk,
                      backgroundColor: Colors.white.withValues(alpha: 0.08),
                      side: const BorderSide(color: AppColors.playerLine),
                      minimumSize: Size(0, compact ? 38 : 46),
                      shape: RoundedRectangleBorder(borderRadius: AppTokens.radiusSM),
                    ),
                    child: Text(s.back),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GradientButton extends StatelessWidget {
  final String label;
  final IconData icon;
  final VoidCallback onTap;
  final bool compact;
  const _GradientButton({required this.label, required this.icon, required this.onTap, required this.compact});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Ink(
        decoration: BoxDecoration(gradient: AppTokens.brandGradient, borderRadius: AppTokens.radiusSM, boxShadow: AppTokens.shadowPrimary),
        child: InkWell(
          onTap: onTap,
          borderRadius: AppTokens.radiusSM,
          child: Container(
            height: compact ? 38 : 46,
            padding: const EdgeInsets.symmetric(horizontal: AppTokens.s16),
            alignment: Alignment.center,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(icon, color: AppColors.playerInk, size: 18),
                const SizedBox(width: 6),
                Text(label, style: const TextStyle(color: AppColors.playerInk, fontWeight: FontWeight.w700)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
