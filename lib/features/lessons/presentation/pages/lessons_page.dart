import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/di.dart';
import '../../../../core/models/pagination_model.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/breakpoints.dart';
import '../../../../core/utils/utils.dart';
import '../../../../core/widgets/app_motion.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../../core/widgets/custom_refresh_indicator.dart';
import '../../../../core/widgets/custom_scaffold.dart';
import '../../../../generated/l10n.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../downloads/domain/entities/download_item.dart';
import '../../../downloads/presentation/cubit/download_cubit.dart';
import '../../../downloads/presentation/cubit/download_state.dart';
import '../../../video/presentation/pages/video_player_args.dart';
import '../../../../core/utils/spoken_duration.dart';
import '../../domain/entities/chapter_progress.dart';
import '../../domain/entities/lesson.dart';
import '../cubit/lessons_cubit.dart';
import '../cubit/lessons_state.dart';
import '../widgets/chapter_progress_hero.dart';
import '../widgets/lesson_list_parts.dart';
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

  /// Purely presentational, so it lives here rather than in [LessonsState]:
  /// it filters the lessons already loaded.
  LessonFilter _filter = LessonFilter.all;

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

  /// Args for the lesson at [index], chained to the following lessons so the
  /// player's "Up next" can continue through the chapter.
  VideoPlayerArgs _argsFor(LessonsState state, int index, {required bool offline}) {
    final List<Lesson> lessons = state.lessons;
    final Set<String> downloaded = state.downloadedLessonIds.toSet();
    final int total = state.pagination?.total ?? lessons.length;
    final bool chapterComplete = state.pagination == null || !state.pagination!.hasNextPage;
    final int chapterSeconds = lessons.fold(0, (sum, l) => sum + l.durationSeconds);

    VideoPlayerArgs? next;
    for (int i = lessons.length - 1; i >= index; i--) {
      final Lesson lesson = lessons[i];
      final bool isDownloaded = downloaded.contains(lesson.id);
      // Offline, only a downloaded lesson can be "next".
      final bool playable = !offline || isDownloaded;
      final VideoPlayerArgs args = VideoPlayerArgs(
        lessonId: lesson.id,
        lessonTitle: lesson.title,
        studentName: _user?.fullName ?? '',
        studentPhone: _user?.phone ?? '',
        isOffline: i == index ? offline : isDownloaded,
        savedPosition: lesson.progress.isCompleted ? 0 : lesson.progress.positionSeconds,
        description: lesson.description,
        durationSeconds: lesson.durationSeconds,
        lessonNumber: i + 1,
        lessonCount: total,
        chapterTitle: widget.args.chapterTitle,
        chapterDurationSeconds: chapterComplete && chapterSeconds > 0 ? chapterSeconds : null,
        isDownloaded: isDownloaded,
        thumbnailUrl: lesson.thumbnailUrl,
        nextLesson: next,
      );
      next = i == index || playable ? args : next;
      if (i == index) return args;
    }
    throw RangeError.index(index, lessons);
  }

  void _play(LessonsState state, Lesson lesson, {required bool offline}) {
    final int index = state.lessons.indexOf(lesson);
    if (index < 0) return;
    Navigator.of(context).pushNamed(Routes.videoPlayer, arguments: _argsFor(state, index, offline: offline));
  }

  void _onDownloadsChanged(BuildContext context, DownloadState state) {
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
          showToastMessage(S.of(context).downloaded, type: ToastType.success);
        case DownloadItemStatus.failed:
          showToastMessage(now.error ?? S.of(context).genericError, isError: true);
        case DownloadItemStatus.waitingForNetwork:
          showToastMessage(S.of(context).waitingForNetwork, type: ToastType.warning);
        case DownloadItemStatus.deleted:
        case DownloadItemStatus.expired:
          listChanged = true;
        case DownloadItemStatus.queued:
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
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: widget.args.subjectName ?? widget.args.chapterTitle,
      body: BlocListener<DownloadCubit, DownloadState>(
        listener: _onDownloadsChanged,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final Breakpoints bp = Breakpoints.of(constraints.maxWidth);
            return BlocBuilder<LessonsCubit, LessonsState>(
              builder: (context, state) {
                if (state.status.isInitial || state.status.isLoading) {
                  return LessonsSkeleton(padding: EdgeInsets.symmetric(horizontal: bp.horizontalPadding, vertical: AppTokens.s16));
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
                return _buildContent(context, state, bp);
              },
            );
          },
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, LessonsState state, Breakpoints bp) {
    final S s = S.of(context);
    final Set<String> downloaded = state.downloadedLessonIds.toSet();
    final PaginationModel? pagination = state.pagination;
    final ChapterProgress progress = ChapterProgress.fromLessons(state.lessons, lessonCount: pagination?.total);
    final List<Lesson> visible = ChapterProgress.filter(state.lessons, _filter, downloaded);
    final Map<LessonFilter, int> counts = {
      for (final LessonFilter f in LessonFilter.values) f: ChapterProgress.filter(state.lessons, f, downloaded).length,
    };
    final int downloadedHere = counts[LessonFilter.downloaded] ?? 0;
    final double h = bp.horizontalPadding;
    final Lesson? resume = progress.resumeLesson;

    Widget tile(Lesson lesson) {
      final bool isDownloaded = downloaded.contains(lesson.id);
      return LessonTile(
        lesson: lesson,
        number: state.lessons.indexOf(lesson) + 1,
        isDownloaded: isDownloaded,
        isActive: resume?.id == lesson.id && progress.resumeKind != ResumeKind.rewatch,
        onPlayOnline: () => _play(state, lesson, offline: false),
        onPlayOffline: () => _play(state, lesson, offline: true),
      );
    }

    return CustomRefreshIndicator(
      onRefresh: () => context.read<LessonsCubit>().getLessons(widget.args.chapterId),
      child: NotificationListener<ScrollNotification>(
        onNotification: (notification) {
          final metrics = notification.metrics;
          if (metrics.pixels >= metrics.maxScrollExtent - 200) {
            context.read<LessonsCubit>().loadMoreLessons(widget.args.chapterId);
          }
          return false;
        },
        child: CustomScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          slivers: [
            SliverPadding(
              padding: EdgeInsets.fromLTRB(h, AppTokens.s16, h, 0),
              sliver: SliverList.list(
                children: [
                  FadeSlideIn(
                    child: ChapterProgressHero(
                      chapterTitle: widget.args.chapterTitle,
                      progress: progress,
                      totalDurationLabel: shortDuration(s, progress.totalDuration),
                      onResume: resume == null ? null : () => _play(state, resume, offline: downloaded.contains(resume.id)),
                    ),
                  ),
                  const SizedBox(height: AppTokens.s16),
                  LessonFilterBar(selected: _filter, counts: counts, onSelected: (f) => setState(() => _filter = f)),
                  if (downloadedHere > 0) ...[const SizedBox(height: AppTokens.s12), OfflineSummary(count: downloadedHere)],
                  const SizedBox(height: AppTokens.s16),
                  LessonsSectionHeader(
                    title: s.lessons,
                    trailing: pagination != null ? s.showingOfTotal(pagination.rangeEnd, pagination.total) : null,
                  ),
                  const SizedBox(height: AppTokens.s8),
                ],
              ),
            ),
            if (visible.isEmpty)
              SliverPadding(
                padding: EdgeInsets.symmetric(horizontal: h, vertical: AppTokens.s32),
                sliver: SliverToBoxAdapter(
                  child: Text(
                    s.noLessonsInFilter,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
                  ),
                ),
              )
            else if (bp.isMobile)
              SliverPadding(
                padding: EdgeInsets.fromLTRB(h, 0, h, AppTokens.s16),
                sliver: SliverList.separated(
                  itemCount: visible.length,
                  separatorBuilder: (_, _) => const SizedBox(height: AppTokens.s12),
                  itemBuilder: (context, i) => FadeSlideIn.staggered(index: i, child: tile(visible[i])),
                ),
              )
            else
              SliverPadding(
                padding: EdgeInsets.fromLTRB(h, 0, h, AppTokens.s16),
                sliver: SliverGrid.builder(
                  itemCount: visible.length,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: bp.gridColumns,
                    mainAxisExtent: 130,
                    crossAxisSpacing: AppTokens.s12,
                    mainAxisSpacing: AppTokens.s12,
                  ),
                  itemBuilder: (context, i) =>
                      Align(alignment: Alignment.topCenter, child: FadeSlideIn.staggered(index: i, child: tile(visible[i]))),
                ),
              ),
            if (state.isLoadingMore)
              const SliverPadding(
                padding: EdgeInsets.only(bottom: AppTokens.s24),
                sliver: SliverToBoxAdapter(
                  child: Center(child: SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2.5))),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
