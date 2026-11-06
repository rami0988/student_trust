import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/endpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../generated/l10n.dart';
import '../../domain/entities/download_item.dart';
import '../cubit/download_cubit.dart';
import '../cubit/download_state.dart';

/// A self-contained download control for a single lesson: one 40dp circle
/// whose look and tap action follow the download's state —
///
/// * idle → download
/// * downloading → progress ring, tap to pause (× badge cancels)
/// * paused → grey ring, tap to resume (× badge cancels)
/// * done → check, tap to delete (confirmed)
/// * failed → retry
///
/// Reads its state from the shared (app-level) [DownloadCubit].
class DownloadButton extends StatelessWidget {
  final String lessonId;
  final String lessonTitle;
  final int durationSeconds;

  /// Thumbnail cached locally at download time for the offline page.
  final String? thumbnailUrl;

  const DownloadButton({super.key, required this.lessonId, this.lessonTitle = '', this.durationSeconds = 0, this.thumbnailUrl});

  String get _videoUrl => '${Endpoints.baseURL}${Endpoints.videoStream(lessonId)}';

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DownloadCubit, DownloadState>(
      buildWhen: (prev, curr) => prev.of(lessonId) != curr.of(lessonId),
      builder: (context, state) {
        final DownloadCubit cubit = context.read<DownloadCubit>();
        final S s = S.of(context);
        final DownloadItem? item = state.of(lessonId);
        void start() =>
            cubit.startDownload(lessonId: lessonId, videoUrl: _videoUrl, title: lessonTitle, durationSeconds: durationSeconds, thumbnailUrl: thumbnailUrl);

        switch (item?.status) {
          case DownloadItemStatus.queued:
          case DownloadItemStatus.downloading:
            return _ProgressControl(
              progress: item!.progress,
              paused: false,
              tooltip: s.pauseDownload,
              cancelTooltip: s.cancelDownload,
              onTap: () => cubit.pauseDownload(lessonId),
              onCancel: () => cubit.cancelDownload(lessonId),
            );
          case DownloadItemStatus.paused:
            return _ProgressControl(
              progress: item!.progress,
              paused: true,
              tooltip: s.resumeDownload,
              cancelTooltip: s.cancelDownload,
              onTap: () => cubit.resumeDownload(lessonId),
              onCancel: () => cubit.cancelDownload(lessonId),
            );
          case DownloadItemStatus.completed:
            return _CircleControl(
              icon: Icons.download_done_rounded,
              color: AppColors.success,
              tooltip: s.deleteDownload,
              onTap: () => _confirmDelete(context, cubit),
            );
          case DownloadItemStatus.waitingForNetwork:
            // Resumes by itself when the connection returns; a tap pauses it.
            return _CircleControl(
              icon: Icons.cloud_off_rounded,
              color: AppColors.warning,
              tooltip: s.waitingForNetwork,
              onTap: () => cubit.pauseDownload(lessonId),
            );
          case DownloadItemStatus.failed:
            return _CircleControl(
              icon: Icons.refresh_rounded,
              color: AppColors.error,
              tooltip: s.retryDownload,
              onTap: () => cubit.resumeDownload(lessonId).then((_) {
                // No record to resume (e.g. an older failure): start afresh.
                if (context.mounted && cubit.state.of(lessonId)?.status == DownloadItemStatus.failed) start();
              }),
            );
          case DownloadItemStatus.deleted:
          case DownloadItemStatus.expired:
          case null:
            // No in-session item: fall back to the persistent store.
            if (item == null && cubit.isDownloaded(lessonId)) {
              return _CircleControl(
                icon: Icons.download_done_rounded,
                color: AppColors.success,
                tooltip: s.deleteDownload,
                onTap: () => _confirmDelete(context, cubit),
              );
            }
            return _CircleControl(icon: Icons.download_rounded, color: AppColors.primary, tooltip: s.download, onTap: start, emphasis: true);
        }
      },
    );
  }

  Future<void> _confirmDelete(BuildContext context, DownloadCubit cubit) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(S.of(context).deleteDownload),
        content: Text(S.of(context).deleteDownloadConfirm),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(S.of(context).back)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(S.of(context).deleteDownload, style: const TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await cubit.deleteDownload(lessonId);
    }
  }
}

/// Soft-tinted 40dp circle with an icon (48dp hit area).
class _CircleControl extends StatefulWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final VoidCallback onTap;

  /// Idle "download" fills with the brand color on press.
  final bool emphasis;

  const _CircleControl({required this.icon, required this.color, required this.tooltip, required this.onTap, this.emphasis = false});

  @override
  State<_CircleControl> createState() => _CircleControlState();
}

class _CircleControlState extends State<_CircleControl> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final bool filled = widget.emphasis && _pressed;
    return Tooltip(
      message: widget.tooltip,
      child: Semantics(
        button: true,
        label: widget.tooltip,
        excludeSemantics: true,
        child: GestureDetector(
          onTapDown: (_) => setState(() => _pressed = true),
          onTapCancel: () => setState(() => _pressed = false),
          onTapUp: (_) => setState(() => _pressed = false),
          onTap: widget.onTap,
          child: SizedBox(
            width: 48,
            height: 48,
            child: Center(
              child: AnimatedScale(
                scale: _pressed ? 0.92 : 1,
                duration: AppTokens.dFast,
                child: AnimatedContainer(
                  duration: AppTokens.dMed,
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: filled ? widget.color : widget.color.withValues(alpha: 0.10),
                  ),
                  child: Icon(widget.icon, size: 20, color: filled ? AppColors.surface : widget.color),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Progress ring with pause/resume in the middle and a small × badge that
/// cancels the download.
class _ProgressControl extends StatelessWidget {
  final double progress;
  final bool paused;
  final String tooltip;
  final String cancelTooltip;
  final VoidCallback onTap;
  final VoidCallback onCancel;

  const _ProgressControl({
    required this.progress,
    required this.paused,
    required this.tooltip,
    required this.cancelTooltip,
    required this.onTap,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    final Color color = paused ? AppColors.textSecondary : AppColors.primary;
    return SizedBox(
      width: 48,
      height: 48,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          Positioned.fill(
            child: Tooltip(
              message: tooltip,
              child: Semantics(
                button: true,
                label: '$tooltip ${(progress * 100).round()}%',
                excludeSemantics: true,
                child: InkResponse(
                  onTap: onTap,
                  radius: 24,
                  child: Center(
                    child: SizedBox(
                      width: 40,
                      height: 40,
                      child: CustomPaint(
                        painter: _RingPainter(progress: progress, color: color, track: AppColors.divider),
                        child: Icon(paused ? Icons.play_arrow_rounded : Icons.pause_rounded, size: 16, color: color),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
          PositionedDirectional(
            top: 0,
            end: 0,
            child: Tooltip(
              message: cancelTooltip,
              child: Semantics(
                button: true,
                label: cancelTooltip,
                excludeSemantics: true,
                child: GestureDetector(
                  onTap: onCancel,
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.all(2),
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: AppColors.surface,
                        shape: BoxShape.circle,
                        border: Border.all(color: AppColors.divider),
                      ),
                      child: const Icon(Icons.close_rounded, size: 11, color: AppColors.error),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final Color track;
  _RingPainter({required this.progress, required this.color, required this.track});

  @override
  void paint(Canvas canvas, Size size) {
    final Rect rect = (Offset.zero & size).deflate(2);
    final Paint base = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3;
    canvas.drawArc(rect, 0, math.pi * 2, false, base..color = track);
    // Indeterminate start: show a short arc instead of nothing.
    final double sweep = (progress <= 0 ? 0.08 : progress.clamp(0.0, 1.0)) * math.pi * 2;
    canvas.drawArc(rect, -math.pi / 2, sweep, false, base
      ..color = color
      ..strokeCap = StrokeCap.round);
  }

  @override
  bool shouldRepaint(_RingPainter old) => old.progress != progress || old.color != color;
}
