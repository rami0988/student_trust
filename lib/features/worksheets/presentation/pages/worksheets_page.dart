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
import '../cubit/worksheets_cubit.dart';
import '../cubit/worksheets_state.dart';
import '../widgets/worksheet_card.dart';
import 'worksheet_view_args.dart';
import 'worksheets_args.dart';

class WorksheetsPage extends StatelessWidget {
  final WorksheetsArgs args;
  const WorksheetsPage({super.key, required this.args});

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: args.chapterTitle,
      body: LayoutBuilder(
        builder: (context, constraints) {
          final Breakpoints bp = Breakpoints.of(constraints.maxWidth);
          return BlocBuilder<WorksheetsCubit, WorksheetsState>(
            builder: (context, state) {
              if (state.status.isInitial || state.status.isLoading) {
                return const SkeletonListLoader(itemHeight: 108);
              }
              if (state.status.isFailure) {
                return AppErrorWidget(
                  message: state.failure?.statusMessage ?? S.of(context).genericError,
                  onRetry: () => context.read<WorksheetsCubit>().getWorksheets(args.chapterId),
                );
              }
              if (state.status.isEmpty) {
                return EmptyStateWidget(icon: Icons.assignment_outlined, title: S.of(context).noWorksheets);
              }
              return CustomRefreshIndicator(
                onRefresh: () => context.read<WorksheetsCubit>().getWorksheets(args.chapterId),
                child: ResponsiveList(
                  breakpoints: bp,
                  gridItemHeight: 160,
                  padding: EdgeInsets.fromLTRB(bp.horizontalPadding, AppTokens.s16, bp.horizontalPadding, AppTokens.s16),
                  itemCount: state.worksheets.length,
                  itemBuilder: (context, index) {
                    final worksheet = state.worksheets[index];
                    return FadeSlideIn.staggered(
                      index: index,
                      child: WorksheetCard(
                        worksheet: worksheet,
                        onTap: () => Navigator.of(
                          context,
                        ).pushNamed(Routes.worksheetView, arguments: WorksheetViewArgs(worksheetId: worksheet.id, worksheetTitle: worksheet.title)),
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
