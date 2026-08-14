import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/di.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/breakpoints.dart';
import '../../../../core/utils/utils.dart';
import '../../../../core/widgets/app_motion.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../../core/widgets/custom_refresh_indicator.dart';
import '../../../../core/widgets/custom_scaffold.dart';
import '../../../../core/widgets/responsive_list.dart';
import '../../../../core/widgets/shimmer.dart';
import '../../../../generated/l10n.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../downloads/domain/entities/download_item.dart';
import '../../../downloads/presentation/cubit/download_cubit.dart';
import '../../../downloads/presentation/cubit/download_state.dart';
import '../../../video/presentation/pages/video_player_args.dart';
import '../../domain/entities/lesson.dart';
import '../cubit/lessons_cubit.dart';
import '../cubit/lessons_state.dart';
import '../widgets/lesson_tile.dart';
import 'lessons_args.dart';

class LessonsPage extends StatefulWidget {
  final LessonsArgs args;
  const LessonsPage({super.key, required this.args});

  @override
  State<LessonsPage> createState() => _LessonsPageState();
}

class _LessonsPageState extends State<LessonsPage> {
  User? _user;
  DownloadState? _prevDownloads;

  @override
  void initState() {
    super.initState();
    // Page-level cross-feature repository read (not a bloc-to-bloc
    // dependency) — mirrors OLD app's LessonsScreen, needed to stamp the
    // student's name/phone on the video anti-piracy watermark.
    getIt<AuthRepository>().currentUser().then((u) {
      if (mounted) setState(() => _user = u);
    });
  }

  void _play(Lesson lesson, {required bool offline}) {
    Navigator.of(context).pushNamed(
      Routes.videoPlayer,
      arguments: VideoPlayerArgs(
        lessonId: lesson.id,
        lessonTitle: lesson.title,
        studentName: _user?.fullName ?? '',
        studentPhone: _user?.phone ?? '',
        isOffline: offline,
        savedPosition: lesson.progress.positionSeconds,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: widget.args.chapterTitle,
      body: BlocListener<DownloadCubit, DownloadState>(
        listener: (context, state) {
          final DownloadState? prev = _prevDownloads;
          _prevDownloads = state;
          bool listChanged = false;

          for (final MapEntry<String, DownloadItem> entry in state.items.entries) {
            final DownloadItem? before = prev?.of(entry.key);
            final DownloadItem now = entry.value;
            if (before?.status == now.status) continue;
            switch (now.status) {
              case DownloadItemStatus.completed:
                listChanged = true;
                showToastMessage(S.of(context).downloaded);
              case DownloadItemStatus.failed:
                showToastMessage(now.error ?? S.of(context).genericError, isError: true);
              case DownloadItemStatus.deleted:
                listChanged = true;
              case DownloadItemStatus.downloading:
              case DownloadItemStatus.paused:
                break;
            }
          }
          // A cancelled download disappears from the map entirely.
          if (prev != null && prev.items.keys.any((k) => !state.items.containsKey(k))) {
            listChanged = true;
          }
          if (listChanged) {
            context.read<LessonsCubit>().refreshDownloadState();
          }
        },
        child: LayoutBuilder(
          builder: (context, constraints) {
            final Breakpoints bp = Breakpoints.of(constraints.maxWidth);
            return BlocBuilder<LessonsCubit, LessonsState>(
              builder: (context, state) {
                if (state.status.isInitial || state.status.isLoading) {
                  return const SkeletonListLoader(itemHeight: 88);
                }
                if (state.status.isFailure) {
                  return AppErrorWidget(
                    message: state.failure?.statusMessage ?? S.of(context).genericError,
                    onRetry: () => context.read<LessonsCubit>().getLessons(widget.args.chapterId),
                  );
                }
                if (state.status.isEmpty) {
                  return EmptyStateWidget(icon: Icons.play_circle_outline_rounded, title: S.of(context).noLessons);
                }
                return CustomRefreshIndicator(
                  onRefresh: () => context.read<LessonsCubit>().getLessons(widget.args.chapterId),
                  child: ResponsiveList(
                    breakpoints: bp,
                    gridItemHeight: 130,
                    padding: EdgeInsets.fromLTRB(bp.horizontalPadding, AppTokens.s16, bp.horizontalPadding, AppTokens.s16),
                    itemCount: state.lessons.length,
                    itemBuilder: (context, index) {
                      final lesson = state.lessons[index];
                      final bool isDownloaded = state.downloadedLessonIds.contains(lesson.id);
                      return FadeSlideIn.staggered(
                        index: index,
                        child: LessonTile(
                          lesson: lesson,
                          isDownloaded: isDownloaded,
                          onPlayOnline: () => _play(lesson, offline: false),
                          onPlayOffline: () => _play(lesson, offline: true),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
