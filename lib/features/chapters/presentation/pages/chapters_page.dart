import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/routing/routes.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/breakpoints.dart';
import '../../../../core/widgets/app_motion.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../../core/widgets/custom_refresh_indicator.dart';
import '../../../../core/widgets/custom_scaffold.dart';
import '../../../../core/widgets/responsive_list.dart';
import '../../../../core/widgets/shimmer.dart';
import '../../../../generated/l10n.dart';
import '../../../lessons/presentation/pages/lessons_args.dart';
import '../../../worksheets/presentation/pages/worksheets_args.dart';
import '../cubit/chapters_cubit.dart';
import '../cubit/chapters_state.dart';
import '../widgets/chapter_card.dart';
import 'chapters_args.dart';

class ChaptersPage extends StatelessWidget {
  final ChaptersArgs args;
  const ChaptersPage({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: args.subjectName,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final Breakpoints bp = Breakpoints.of(constraints.maxWidth);
          return BlocBuilder<ChaptersCubit, ChaptersState>(
            builder: (context, state) {
              if (state.status.isInitial || state.status.isLoading) {
                return const SkeletonListLoader(itemHeight: 96);
              }
              if (state.status.isFailure) {
                return AppErrorWidget(
                  message: state.failure?.statusMessage ?? S.of(context).genericError,
                  onRetry: () => context.read<ChaptersCubit>().getChapters(args.subjectId),
                );
              }
              if (state.status.isEmpty) {
                return EmptyStateWidget(icon: Icons.menu_book_outlined, title: S.of(context).noChapters);
              }
              return CustomRefreshIndicator(
                onRefresh: () => context.read<ChaptersCubit>().getChapters(args.subjectId),
                child: ResponsiveList(
                  breakpoints: bp,
                  gridItemHeight: 150,
                  padding: EdgeInsets.fromLTRB(bp.horizontalPadding, AppTokens.s16, bp.horizontalPadding, AppTokens.s16),
                  itemCount: state.chapters.length,
                  itemBuilder: (context, index) {
                    final chapter = state.chapters[index];
                    return FadeSlideIn.staggered(
                      index: index,
                      child: ChapterCard(
                        chapter: chapter,
                        number: index + 1,
                        onTap: () =>
                            Navigator.of(context).pushNamed(Routes.lessons, arguments: LessonsArgs(chapterId: chapter.id, chapterTitle: chapter.title)),
                        onWorksheetsTap: () =>
                            Navigator.of(context).pushNamed(Routes.worksheets, arguments: WorksheetsArgs(chapterId: chapter.id, chapterTitle: chapter.title)),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
