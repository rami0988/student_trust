import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/network/endpoints.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/utils.dart';
import '../../../../generated/l10n.dart';
import '../../domain/entities/download_item.dart';
import '../cubit/download_cubit.dart';
import '../cubit/download_state.dart';

/// A self-contained download control for a single lesson. Reads its state
/// from the shared (app-level) [DownloadCubit], filtered by [lessonId].
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
        final DownloadItem? item = state.of(lessonId);

        if (item != null) {
          switch (item.status) {
            case DownloadItemStatus.queued:
              return _ActiveControls(
                progress: item.progress,
                state: _ControlsState.queued,
                onPauseResume: () => cubit.pauseDownload(lessonId),
                onCancel: () => cubit.cancelDownload(lessonId),
              );
            case DownloadItemStatus.downloading:
              return _ActiveControls(
                progress: item.progress,
                state: _ControlsState.downloading,
                onPauseResume: () => cubit.pauseDownload(lessonId),
                onCancel: () => cubit.cancelDownload(lessonId),
              );
            case DownloadItemStatus.paused:
              return _ActiveControls(
                progress: item.progress,
                state: _ControlsState.paused,
                onPauseResume: () => cubit.resumeDownload(lessonId),
                onCancel: () => cubit.cancelDownload(lessonId),
              );
            case DownloadItemStatus.completed:
              return _downloadedButton(context, cubit);
            case DownloadItemStatus.failed:
              // Surface the reason instead of silently reverting to a plain
              // download icon, which reads as "nothing happened".
              return _failedButton(context, cubit, item.error);
            case DownloadItemStatus.deleted:
              return _downloadButton(context, cubit);
          }
        }

        // No in-session item: fall back to the persistent store.
        if (cubit.isDownloaded(lessonId)) {
          return _downloadedButton(context, cubit);
        }
        return _downloadButton(context, cubit);
      },
    );
  }

  Widget _downloadButton(BuildContext context, DownloadCubit cubit) {
    return Semantics(
      button: true,
      label: S.of(context).download,
      child: IconButton(
        tooltip: S.of(context).download,
        icon: const Icon(Icons.download_outlined, color: AppColors.primary),
        onPressed: () =>
            cubit.startDownload(lessonId: lessonId, videoUrl: _videoUrl, title: lessonTitle, durationSeconds: durationSeconds, thumbnailUrl: thumbnailUrl),
      ),
    );
  }

  /// Failed download: a retry affordance plus the reason on long-press, so a
  /// student isn't left guessing why the lesson never arrived.
  Widget _failedButton(BuildContext context, DownloadCubit cubit, String? error) {
    return Semantics(
      button: true,
      label: S.of(context).retryDownload,
      child: IconButton(
        tooltip: error?.isNotEmpty == true ? error : S.of(context).downloadFailed,
        icon: const Icon(Icons.refresh_rounded, color: AppColors.error),
        onPressed: () {
          if (error != null && error.isNotEmpty) showToastMessage(error);
          cubit.startDownload(lessonId: lessonId, videoUrl: _videoUrl, title: lessonTitle, durationSeconds: durationSeconds, thumbnailUrl: thumbnailUrl);
        },
      ),
    );
  }

  Widget _downloadedButton(BuildContext context, DownloadCubit cubit) {
    return Semantics(
      button: true,
      label: S.of(context).deleteDownload,
      child: IconButton(
        tooltip: S.of(context).deleteDownload,
        icon: const Icon(Icons.download_done_rounded, color: AppColors.success),
        onPressed: () => _confirmDelete(context, cubit),
      ),
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
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: Text(S.of(context).deleteDownload, style: const TextStyle(color: AppColors.error))),
        ],
      ),
    );
    if (confirmed == true) {
      await cubit.deleteDownload(lessonId);
    }
  }
}

/// Which of the three in-flight shapes the control is showing.
enum _ControlsState { queued, downloading, paused }

/// Progress ring with a pause/resume tap target, plus a cancel button.
class _ActiveControls extends StatelessWidget {
  final double progress;
  final _ControlsState state;
  final VoidCallback onPauseResume;
  final VoidCallback onCancel;

  const _ActiveControls({required this.progress, required this.state, required this.onPauseResume, required this.onCancel});

  bool get _paused => state == _ControlsState.paused;
  bool get _queued => state == _ControlsState.queued;

  @override
  Widget build(BuildContext context) {
    final Color color = _paused || _queued ? AppColors.textSecondary : AppColors.primary;
    final String tooltip = _queued
        ? S.of(context).queuedDownload
        : (_paused ? S.of(context).resumeDownload : S.of(context).pauseDownload);

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Tooltip(
          message: tooltip,
          child: InkWell(
            onTap: onPauseResume,
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: 44,
              height: 44,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  CircularProgressIndicator(
                    // Queued has no progress of its own yet - an indeterminate
                    // spinner reads as "waiting" rather than "stuck at 0%".
                    value: _queued || progress == 0 ? null : progress,
                    strokeWidth: 3,
                    color: color,
                  ),
                  Icon(
                    _queued ? Icons.schedule_rounded : (_paused ? Icons.play_arrow_rounded : Icons.pause_rounded),
                    size: 18,
                    color: color,
                  ),
                ],
              ),
            ),
          ),
        ),
        Semantics(
          button: true,
          label: S.of(context).cancelDownload,
          child: IconButton(
            tooltip: S.of(context).cancelDownload,
            visualDensity: VisualDensity.compact,
            icon: const Icon(Icons.close_rounded, color: AppColors.error),
            onPressed: onCancel,
          ),
        ),
      ],
    );
  }
}
