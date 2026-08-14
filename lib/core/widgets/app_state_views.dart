import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_tokens.dart';
import '../utils/breakpoints.dart';
import '../../generated/l10n.dart';
import 'app_motion.dart';
import 'shake.dart';

/// Centered error state with an optional retry action. Ported from
/// front_student_app's core/widgets/error_widget.dart (see
/// [[unified-design-system]] memory) — the canonical replacement for
/// [ErrorView] across every screen. The retry button shakes itself on tap —
/// a tactile "acknowledged" cue while the retry is in flight.
class AppErrorWidget extends StatefulWidget {
  final String message;
  final VoidCallback? onRetry;
  final IconData icon;

  const AppErrorWidget({super.key, required this.message, this.onRetry, this.icon = Icons.error_outline});

  @override
  State<AppErrorWidget> createState() => _AppErrorWidgetState();
}

class _AppErrorWidgetState extends State<AppErrorWidget> {
  final GlobalKey<ShakeWidgetState> _shakeKey = GlobalKey<ShakeWidgetState>();

  void _handleRetry() {
    _shakeKey.currentState?.shake();
    widget.onRetry?.call();
  }

  @override
  Widget build(BuildContext context) {
    final bool isTabletOrLarger = Breakpoints.of_(context).isTabletOrLarger;
    return Center(
      child: FadeSlideIn(
        child: Padding(
          padding: const EdgeInsets.all(AppTokens.s24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(AppTokens.s24),
                decoration: BoxDecoration(color: AppColors.errorSoft, shape: BoxShape.circle),
                child: Icon(widget.icon, size: isTabletOrLarger ? 56 : 48, color: AppColors.error),
              ),
              const SizedBox(height: AppTokens.s16),
              Text(
                widget.message,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textPrimary, fontSize: isTabletOrLarger ? 18 : 16, fontWeight: FontWeight.w600, height: 1.5),
              ),
              if (widget.onRetry != null) ...[
                const SizedBox(height: AppTokens.s16),
                ShakeWidget(
                  key: _shakeKey,
                  child: ElevatedButton.icon(
                    onPressed: _handleRetry,
                    icon: const Icon(Icons.refresh_rounded, size: 20),
                    label: Text(S.of(context).retry),
                    style: ElevatedButton.styleFrom(minimumSize: const Size(180, 48)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Specialised offline/no-connection error.
class NetworkErrorWidget extends StatelessWidget {
  final VoidCallback? onRetry;

  const NetworkErrorWidget({super.key, this.onRetry});

  @override
  Widget build(BuildContext context) {
    return AppErrorWidget(icon: Icons.wifi_off_rounded, message: S.of(context).networkErrorSubtitle, onRetry: onRetry);
  }
}

/// Centered empty-state placeholder. Ported from front_student_app's
/// core/widgets/error_widget.dart — the canonical replacement for
/// [EmptyView] across every screen.
class EmptyStateWidget extends StatelessWidget {
  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget? action;

  const EmptyStateWidget({super.key, required this.icon, required this.title, this.subtitle, this.action});

  @override
  Widget build(BuildContext context) {
    final bool isTabletOrLarger = Breakpoints.of_(context).isTabletOrLarger;
    return Center(
      child: FadeSlideIn(
        child: Padding(
          padding: const EdgeInsets.all(AppTokens.s24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(AppTokens.s24),
                decoration: BoxDecoration(color: AppColors.primarySoft, shape: BoxShape.circle),
                child: Icon(icon, size: isTabletOrLarger ? 56 : 48, color: AppColors.primary),
              ),
              const SizedBox(height: AppTokens.s16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(color: AppColors.textPrimary, fontSize: isTabletOrLarger ? 20 : 18, fontWeight: FontWeight.w700),
              ),
              if (subtitle != null) ...[
                const SizedBox(height: AppTokens.s8),
                Text(
                  subtitle!,
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppColors.textSecondary, fontSize: isTabletOrLarger ? 15 : 14, height: 1.5),
                ),
              ],
              if (action != null) ...[const SizedBox(height: AppTokens.s16), action!],
            ],
          ),
        ),
      ),
    );
  }
}
