import 'package:flutter/material.dart';

import '../../../../core/di/di.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/services/connectivity_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/breakpoints.dart';
import '../../../../core/utils/duration_utils.dart';
import '../../../../core/utils/utils.dart';
import '../../../../core/widgets/app_motion.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../../core/widgets/custom_app_button.dart';
import '../../../../core/widgets/responsive_list.dart';
import '../../../../generated/l10n.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../downloads/data/services/encrypted_download_service.dart';
import '../../../downloads/domain/entities/downloaded_lesson_info.dart';
import '../../../video/presentation/pages/video_player_args.dart';
import '../widgets/downloaded_video_tile.dart';

/// Shown whenever there's no internet — whether or not the student has a
/// cached session — with a downloaded-lessons list (empty if none) and a
/// "check connection" button. [AuthGate] also watches connectivity itself
/// and swaps this page out automatically the moment a real connection
/// returns, so the button is a manual/on-demand check, not the only way out.
class OfflinePage extends StatefulWidget {
  const OfflinePage({super.key});

  @override
  State<OfflinePage> createState() => _OfflinePageState();
}

class _OfflinePageState extends State<OfflinePage> {
  final EncryptedDownloadService _service = getIt<EncryptedDownloadService>();
  final ConnectivityService _connectivity = getIt<ConnectivityService>();

  late List<DownloadedLessonInfo> _items;
  User? _user;
  bool _checkingConnection = false;

  @override
  void initState() {
    super.initState();
    _items = _service.getDownloadedLessons();
    // Cached at login exactly for this: the watermark (name + phone) must
    // work with zero connectivity.
    getIt<AuthRepository>().currentUser().then((user) {
      if (mounted) setState(() => _user = user);
    });
  }

  void _refresh() {
    setState(() => _items = _service.getDownloadedLessons());
  }

  Future<void> _retryConnection() async {
    setState(() => _checkingConnection = true);
    final bool online = await _connectivity.checkConnection();
    if (!mounted) return;
    setState(() => _checkingConnection = false);
    if (!online) {
      showToastMessage(S.of(context).stillOffline);
      return;
    }
    // With a cached session, drop straight into the app. Without one (a
    // student who has never been online yet), there's nothing to resume —
    // send them to login instead of a subjects screen that would just 401.
    final String route = _user != null ? Routes.subjects : Routes.login;
    Navigator.of(context).pushNamedAndRemoveUntil(route, (route) => false);
  }

  Future<void> _play(DownloadedLessonInfo lesson) async {
    // The watermark must always carry the student identity — make sure the
    // cached user is loaded even if the tile was tapped immediately.
    _user ??= await getIt<AuthRepository>().currentUser();
    if (!mounted) return;
    Navigator.of(context).pushNamed(
      Routes.videoPlayer,
      arguments: VideoPlayerArgs(
        lessonId: lesson.lessonId,
        lessonTitle: lesson.title.isEmpty ? S.of(context).lessons : lesson.title,
        studentName: _user?.fullName ?? '',
        studentPhone: _user?.phone ?? '',
        isOffline: true,
      ),
    );
  }

  Future<bool> _confirmDelete(DownloadedLessonInfo lesson) async {
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
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
    if (confirmed != true) return false;
    await _service.deleteLesson(lesson.lessonId);
    _refresh();
    return true;
  }

  int get _totalDurationSeconds => _items.fold(0, (sum, item) => sum + item.durationSeconds);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _OfflineHeader(count: _items.length, totalDurationSeconds: _totalDurationSeconds),
          Expanded(
            child: _items.isEmpty
                ? EmptyStateWidget(
                    icon: Icons.cloud_off_rounded,
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
                              AppTokens.s20,
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
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(AppTokens.s16, AppTokens.s8, AppTokens.s16, AppTokens.s12),
              child: CustomAppButton(
                text: S.of(context).retryConnection,
                isLoading: _checkingConnection,
                onPressed: _checkingConnection ? null : _retryConnection,
                gradient: const [AppColors.primary, AppColors.gradientEnd],
                icon: const Icon(Icons.refresh_rounded, color: Colors.white, size: 20),
                textStyle: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w600),
                borderRadius: AppTokens.radiusMD,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _OfflineHeader extends StatelessWidget {
  final int count;
  final int totalDurationSeconds;
  const _OfflineHeader({required this.count, required this.totalDurationSeconds});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      decoration: const BoxDecoration(
        gradient: LinearGradient(colors: [AppColors.primary, AppColors.gradientEnd], begin: Alignment.topLeft, end: Alignment.bottomRight),
      ),
      padding: EdgeInsets.fromLTRB(20, MediaQuery.of(context).padding.top + 16, 20, 22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.16), borderRadius: BorderRadius.circular(20)),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.wifi_off_rounded, size: 14, color: Colors.white),
                const SizedBox(width: 6),
                Text(
                  S.of(context).offlineIndicator,
                  style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            S.of(context).downloadsTitle,
            style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: Colors.white),
          ),
          const SizedBox(height: 4),
          Text(S.of(context).offlineBanner, style: TextStyle(fontSize: 13, color: Colors.white.withValues(alpha: 0.85))),
          if (count > 0) ...[
            const SizedBox(height: 18),
            Row(
              children: [
                _StatChip(icon: Icons.video_library_rounded, label: S.of(context).downloadsCount(count)),
                const SizedBox(width: 10),
                if (totalDurationSeconds > 0) _StatChip(icon: Icons.schedule_rounded, label: DurationUtils.format(totalDurationSeconds)),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _StatChip({required this.icon, required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.14), borderRadius: BorderRadius.circular(12)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: Colors.white),
          const SizedBox(width: 6),
          Text(label, style: const TextStyle(fontSize: 12.5, color: Colors.white, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
