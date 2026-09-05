import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/di.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/breakpoints.dart';
import '../../../../core/utils/duration_utils.dart';
import '../../../../core/utils/utils.dart';
import '../../../../core/widgets/app_motion.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../../core/widgets/responsive_list.dart';
import '../../../../generated/l10n.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../offline/presentation/widgets/downloaded_video_tile.dart';
import '../../../video/presentation/pages/video_player_args.dart';
import '../../data/services/encrypted_download_service.dart';
import '../../domain/entities/downloaded_lesson_info.dart';
import '../cubit/download_cubit.dart';
import '../cubit/download_state.dart';

/// Manages downloaded lessons **while online** — play, delete one, delete all,
/// and see how much storage they take.
///
/// The offline screen ([OfflinePage]) shows the same list, but it only appears
/// when there's no connection. Without this page a connected student has no
/// way to review or clear what they've downloaded, which is how devices end up
/// full of lessons the student finished weeks ago.
class DownloadsPage extends StatefulWidget {
  const DownloadsPage({super.key});

  @override
  State<DownloadsPage> createState() => _DownloadsPageState();
}

class _DownloadsPageState extends State<DownloadsPage> {
  final EncryptedDownloadService _service = getIt<EncryptedDownloadService>();

  late List<DownloadedLessonInfo> _items;
  User? _user;
  bool _deletingAll = false;

  @override
  void initState() {
    super.initState();
    _items = _service.getDownloadedLessons();
    // Needed for the player watermark; loaded up front so tapping a tile
    // immediately doesn't race it.
    getIt<AuthRepository>().currentUser().then((user) {
      if (mounted) setState(() => _user = user);
    });
  }

  void _refresh() {
    if (!mounted) return;
    setState(() => _items = _service.getDownloadedLessons());
  }

  Future<void> _play(DownloadedLessonInfo lesson) async {
    _user ??= await getIt<AuthRepository>().currentUser();
    if (!mounted) return;
    await Navigator.of(context).pushNamed(
      Routes.videoPlayer,
      arguments: VideoPlayerArgs(
        lessonId: lesson.lessonId,
        lessonTitle: lesson.title.isEmpty ? S.of(context).lessons : lesson.title,
        studentName: _user?.fullName ?? '',
        studentPhone: _user?.phone ?? '',
        isOffline: true,
      ),
    );
    // Playback can discover a damaged download and drop it — re-read so the
    // list doesn't keep offering a lesson that's no longer there.
    _refresh();
  }

  Future<bool> _confirmDelete(DownloadedLessonInfo lesson) async {
    final bool confirmed = await _confirm(title: S.of(context).deleteDownload, message: S.of(context).deleteDownloadConfirm);
    if (!confirmed || !mounted) return false;
    final DownloadCubit cubit = context.read<DownloadCubit>();
    final String message = S.of(context).downloadDeleted;
    await cubit.deleteDownload(lesson.lessonId);
    _refresh();
    if (mounted) showToastMessage(message);
    return true;
  }

  Future<void> _deleteAll() async {
    final bool confirmed = await _confirm(title: S.of(context).deleteAllDownloads, message: S.of(context).deleteAllDownloadsConfirm);
    if (!confirmed || !mounted) return;
    setState(() => _deletingAll = true);
    final int removed = await context.read<DownloadCubit>().deleteAllDownloads();
    if (!mounted) return;
    setState(() => _deletingAll = false);
    _refresh();
    showToastMessage(S.of(context).downloadsDeleted(removed));
  }

  Future<bool> _confirm({required String title, required String message}) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(title),
        content: Text(message),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: Text(S.of(context).back)),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(S.of(context).deleteDownload, style: const TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
    return confirmed == true;
  }

  int get _totalDurationSeconds => _items.fold(0, (sum, item) => sum + item.durationSeconds);

  @override
  Widget build(BuildContext context) {
    // Rebuild when a download completes elsewhere in the app, so a lesson that
    // finishes while this page is open shows up without a manual refresh.
    return BlocListener<DownloadCubit, DownloadState>(
      listenWhen: (prev, curr) => prev.items.length != curr.items.length || _hasNewlyCompleted(prev, curr),
      listener: (_, _) => _refresh(),
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          title: Text(S.of(context).myDownloads),
          actions: [
            if (_items.isNotEmpty)
              IconButton(
                tooltip: S.of(context).deleteAllDownloads,
                onPressed: _deletingAll ? null : _deleteAll,
                icon: _deletingAll
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.error))
                    : const Icon(Icons.delete_sweep_outlined, color: AppColors.error),
              ),
          ],
        ),
        body: Column(
          children: [
            if (_items.isNotEmpty)
              _DownloadsSummary(
                count: _items.length,
                totalDurationSeconds: _totalDurationSeconds,
                totalBytes: _service.totalBytesUsed(),
              ),
            Expanded(
              child: _items.isEmpty
                  ? EmptyStateWidget(
                      icon: Icons.download_for_offline_outlined,
                      title: S.of(context).noDownloadedVideos,
                      subtitle: S.of(context).noDownloadedVideosSubtitle,
                    )
                  : LayoutBuilder(
                      builder: (context, constraints) {
                        final Breakpoints bp = Breakpoints.of(constraints.maxWidth);
                        return Center(
                          child: ConstrainedBox(
                            constraints: BoxConstraints(maxWidth: bp.maxContentWidth ?? double.infinity),
                            child: ResponsiveList(
                              breakpoints: bp,
                              gridItemHeight: 110,
                              padding: EdgeInsets.fromLTRB(
                                bp.horizontalPadding,
                                AppTokens.s16,
                                bp.horizontalPadding,
                                AppTokens.s16 + MediaQuery.of(context).padding.bottom,
                              ),
                              itemCount: _items.length,
                              itemBuilder: (context, index) {
                                final DownloadedLessonInfo lesson = _items[index];
                                return FadeSlideIn.staggered(
                                  index: index,
                                  child: DownloadedVideoTile(
                                    key: ValueKey(lesson.lessonId),
                                    lesson: lesson,
                                    onPlay: () => _play(lesson),
                                    onConfirmDelete: () => _confirmDelete(lesson),
                                  ),
                                );
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  /// True when any lesson moved into `completed` between the two states.
  bool _hasNewlyCompleted(DownloadState prev, DownloadState curr) {
    for (final MapEntry<String, dynamic> entry in curr.items.entries) {
      final dynamic before = prev.items[entry.key];
      if (entry.value.status != before?.status && entry.value.status.toString().endsWith('completed')) {
        return true;
      }
    }
    return false;
  }
}

/// Count / total duration / storage used, so the student can judge what's
/// worth clearing before hunting through the list.
class _DownloadsSummary extends StatelessWidget {
  final int count;
  final int totalDurationSeconds;
  final int totalBytes;

  const _DownloadsSummary({required this.count, required this.totalDurationSeconds, required this.totalBytes});

  String _formatBytes(int bytes) {
    if (bytes <= 0) return '—';
    const List<String> units = ['B', 'KB', 'MB', 'GB'];
    double value = bytes.toDouble();
    int unit = 0;
    while (value >= 1024 && unit < units.length - 1) {
      value /= 1024;
      unit++;
    }
    return '${value.toStringAsFixed(value >= 10 || unit == 0 ? 0 : 1)} ${units[unit]}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.fromLTRB(AppTokens.s16, AppTokens.s16, AppTokens.s16, 0),
      padding: const EdgeInsets.symmetric(horizontal: AppTokens.s16, vertical: AppTokens.s16),
      decoration: BoxDecoration(gradient: AppTokens.brandGradient, borderRadius: AppTokens.radiusLG, boxShadow: AppTokens.shadowSM),
      child: Row(
        children: [
          Expanded(child: _Stat(icon: Icons.video_library_rounded, value: '$count', label: S.of(context).downloadsTitle)),
          _divider(),
          Expanded(child: _Stat(icon: Icons.sd_storage_rounded, value: _formatBytes(totalBytes), label: S.of(context).storageUsed)),
          if (totalDurationSeconds > 0) ...[
            _divider(),
            Expanded(
              child: _Stat(icon: Icons.schedule_rounded, value: DurationUtils.format(totalDurationSeconds), label: S.of(context).totalDuration),
            ),
          ],
        ],
      ),
    );
  }

  Widget _divider() => Container(width: 1, height: 34, color: Colors.white.withValues(alpha: 0.22));
}

class _Stat extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  const _Stat({required this.icon, required this.value, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: Colors.white.withValues(alpha: 0.9)),
        const SizedBox(height: AppTokens.s4),
        Text(
          value,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: Colors.white),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(fontSize: 11, color: Colors.white.withValues(alpha: 0.85)),
        ),
      ],
    );
  }
}
