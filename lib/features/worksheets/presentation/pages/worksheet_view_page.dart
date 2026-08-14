import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/di/di.dart';
import '../../../../core/network/endpoints.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/breakpoints.dart';
import '../../../../core/utils/utils.dart';
import '../../../../core/widgets/app_motion.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../../core/widgets/custom_refresh_indicator.dart';
import '../../../../core/widgets/custom_scaffold.dart';
import '../../../../core/widgets/shimmer.dart';
import '../../../../generated/l10n.dart';
import '../../../auth/domain/entities/user.dart';
import '../../../auth/domain/repositories/auth_repository.dart';
import '../../../video/presentation/pages/video_player_args.dart';
import '../../domain/entities/worksheet_file.dart';
import '../../domain/entities/worksheet_video.dart';
import '../cubit/worksheet_view_cubit.dart';
import '../cubit/worksheet_view_state.dart';
import '../widgets/worksheet_file_tile.dart';
import '../widgets/worksheet_video_tile.dart';
import 'pdf_viewer_args.dart';
import 'worksheet_view_args.dart';

/// One worksheet: its PDF files (view/download) + solution videos (secure).
class WorksheetViewPage extends StatefulWidget {
  final WorksheetViewArgs args;
  const WorksheetViewPage({super.key, required this.args});

  @override
  State<WorksheetViewPage> createState() => _WorksheetViewPageState();
}

class _WorksheetViewPageState extends State<WorksheetViewPage> {
  User? _user;

  @override
  void initState() {
    super.initState();
    // Page-level cross-feature repository read (not a bloc-to-bloc
    // dependency) — mirrors lessons feature, needed to stamp the student's
    // name/phone on the video anti-piracy watermark.
    getIt<AuthRepository>().currentUser().then((u) {
      if (mounted) setState(() => _user = u);
    });
  }

  void _playVideo(WorksheetVideo video) {
    Navigator.of(context).pushNamed(
      Routes.videoPlayer,
      arguments: VideoPlayerArgs(
        lessonId: video.id,
        lessonTitle: video.title,
        studentName: _user?.fullName ?? '',
        studentPhone: _user?.phone ?? '',
        streamEndpoint: Endpoints.worksheetVideoStream(video.id),
        trackProgress: false,
      ),
    );
  }

  void _openPdf(WorksheetFile file) {
    Navigator.of(context).pushNamed(Routes.pdfViewer, arguments: PdfViewerArgs(url: file.url, fileName: file.fileName));
  }

  @override
  Widget build(BuildContext context) {
    return CustomScaffold(
      title: widget.args.worksheetTitle,
      body: BlocConsumer<WorksheetViewCubit, WorksheetViewState>(
        listener: (context, state) {
          if (state.notice != null) {
            final String? savedPath = state.savedPaths.values.isNotEmpty ? state.savedPaths.values.last : null;
            showToastMessage(
              state.notice!,
              action: savedPath != null
                  ? SnackBarAction(
                      label: S.of(context).open,
                      onPressed: () => Navigator.of(
                        context,
                      ).pushNamed(Routes.pdfViewer, arguments: PdfViewerArgs(url: '', fileName: savedPath.split('/').last, localPath: savedPath)),
                    )
                  : null,
            );
            context.read<WorksheetViewCubit>().clearMessages();
          } else if (state.downloadError != null) {
            showToastMessage(state.downloadError!, isError: true);
            context.read<WorksheetViewCubit>().clearMessages();
          }
        },
        builder: (context, state) {
          if (state.status.isInitial || state.status.isLoading) {
            return const SkeletonListLoader(itemCount: 4, itemHeight: 76);
          }
          if (state.status.isFailure) {
            return AppErrorWidget(message: state.failure?.statusMessage ?? S.of(context).genericError, onRetry: () => context.read<WorksheetViewCubit>().refresh());
          }
          return CustomRefreshIndicator(
            onRefresh: () => context.read<WorksheetViewCubit>().refresh(),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final Breakpoints bp = Breakpoints.of(constraints.maxWidth);
                return Center(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxWidth: bp.maxContentWidth ?? double.infinity),
                    child: ListView(
                      physics: const AlwaysScrollableScrollPhysics(),
                      padding: EdgeInsets.fromLTRB(bp.horizontalPadding, AppTokens.s16, bp.horizontalPadding, AppTokens.s16),
                      children: [
                        _SectionTitle(icon: Icons.picture_as_pdf_rounded, title: S.of(context).filesSectionTitle),
                        const SizedBox(height: AppTokens.s12),
                        if (state.files.isEmpty)
                          _EmptyHint(text: S.of(context).noFiles)
                        else
                          ...state.files.asMap().entries.map(
                            (e) => FadeSlideIn.staggered(
                              index: e.key,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: AppTokens.s12),
                                child: WorksheetFileTile(
                                  file: e.value,
                                  progress: state.downloading[e.value.id],
                                  isSaved: state.savedPaths.containsKey(e.value.id),
                                  onOpen: () => _openPdf(e.value),
                                  onDownload: () => context.read<WorksheetViewCubit>().downloadToDevice(e.value),
                                ),
                              ),
                            ),
                          ),
                        const SizedBox(height: AppTokens.s16),
                        _SectionTitle(icon: Icons.play_circle_outline_rounded, title: S.of(context).solutionsSectionTitle),
                        const SizedBox(height: AppTokens.s12),
                        if (state.videos.isEmpty)
                          _EmptyHint(text: S.of(context).noSolutionVideos)
                        else
                          ...state.videos.asMap().entries.map(
                            (e) => FadeSlideIn.staggered(
                              index: e.key,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: AppTokens.s12),
                                child: WorksheetVideoTile(video: e.value, onPlay: () => _playVideo(e.value)),
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final IconData icon;
  final String title;
  const _SectionTitle({required this.icon, required this.title});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(width: 4, height: 18, decoration: BoxDecoration(gradient: AppTokens.brandGradient, borderRadius: BorderRadius.circular(AppTokens.rFull))),
        const SizedBox(width: AppTokens.s8),
        Icon(icon, color: AppColors.primary, size: 20),
        const SizedBox(width: AppTokens.s4),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
      ],
    );
  }
}

class _EmptyHint extends StatelessWidget {
  final String text;
  const _EmptyHint({required this.text});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTokens.s16),
      child: Center(child: Text(text, style: const TextStyle(color: AppColors.textSecondary))),
    );
  }
}
