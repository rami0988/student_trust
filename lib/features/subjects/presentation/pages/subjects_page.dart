import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/models/pagination_model.dart';
import '../../../../core/routing/routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../core/utils/breakpoints.dart';
import '../../../../core/widgets/app_motion.dart';
import '../../../../core/widgets/app_state_views.dart';
import '../../../../core/widgets/custom_refresh_indicator.dart';
import '../../../../core/widgets/custom_scaffold.dart';
import '../../../../core/widgets/shimmer.dart';
import '../../../../generated/l10n.dart';
import '../../../chapters/presentation/pages/chapters_args.dart';
import '../cubit/subjects_cubit.dart';
import '../cubit/subjects_state.dart';
import '../widgets/subject_card.dart';

class SubjectsPage extends StatefulWidget {
  const SubjectsPage({super.key});

  @override
  State<SubjectsPage> createState() => _SubjectsPageState();
}

class _SubjectsPageState extends State<SubjectsPage> {
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocusNode = FocusNode();
  String _query = '';
  bool _isSearching = false;

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  void _startSearching() {
    setState(() => _isSearching = true);
    _searchFocusNode.requestFocus();
  }

  void _stopSearching() {
    setState(() {
      _isSearching = false;
      _query = '';
    });
    _searchController.clear();
    _searchFocusNode.unfocus();
    _syncSearchMode();
  }

  /// The backend has no `?search=` param for this endpoint, so a non-empty
  /// query switches [SubjectsCubit] into holding the *complete* list (looped
  /// across every backend page) instead of just the loaded one — otherwise a
  /// search would silently miss subjects on pages that haven't been scrolled
  /// to yet. Only fires on the on/off transition; `searchSubjects`/
  /// `getSubjects` are each idempotent no-ops otherwise.
  void _syncSearchMode() {
    final cubit = context.read<SubjectsCubit>();
    final bool shouldSearch = _query.isNotEmpty;
    if (shouldSearch && !cubit.state.isSearching) {
      cubit.searchSubjects();
    } else if (!shouldSearch && cubit.state.isSearching) {
      cubit.getSubjects();
    }
  }

  /// Search field styled as a solid pill sitting on the brand-colored
  /// AppBar. Deliberately white-on-blue rather than a translucent overlay:
  /// dark text on white is far more legible than white text on a
  /// semi-transparent wash of the bar color, and it reads unmistakably as an
  /// input rather than as a label. Every border is nulled out because the
  /// app-wide `inputDecorationTheme` fills and outlines fields by default.
  Widget _buildSearchField() {
    return Container(
      height: 42,
      decoration: BoxDecoration(color: AppColors.surface, borderRadius: BorderRadius.circular(AppTokens.rFull)),
      alignment: Alignment.center,
      child: TextField(
        controller: _searchController,
        focusNode: _searchFocusNode,
        onChanged: (value) {
          setState(() => _query = value.trim().toLowerCase());
          _syncSearchMode();
        },
        textInputAction: TextInputAction.search,
        style: const TextStyle(color: AppColors.textPrimary, fontSize: 15, fontWeight: FontWeight.w500),
        cursorColor: AppColors.primary,
        decoration: InputDecoration(
          isDense: true,
          filled: false,
          hintText: S.of(context).searchSubjectHint,
          hintStyle: const TextStyle(color: AppColors.textTertiary, fontSize: 14, fontWeight: FontWeight.normal),
          prefixIcon: const Icon(Icons.search_rounded, color: AppColors.primary, size: 20),
          prefixIconConstraints: const BoxConstraints(minWidth: 38, minHeight: 38),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: _searchController,
            builder: (context, value, _) {
              if (value.text.isEmpty) return const SizedBox.shrink();
              return Semantics(
                button: true,
                label: S.of(context).search,
                child: InkWell(
                  borderRadius: BorderRadius.circular(AppTokens.rFull),
                  onTap: () {
                    _searchController.clear();
                    setState(() => _query = '');
                    _searchFocusNode.requestFocus();
                    _syncSearchMode();
                  },
                  child: const Icon(Icons.cancel_rounded, color: AppColors.textTertiary, size: 18),
                ),
              );
            },
          ),
          suffixIconConstraints: const BoxConstraints(minWidth: 38, minHeight: 38),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: AppTokens.s4, vertical: 11),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Device back should close search first rather than leaving the app.
    return PopScope(
      canPop: !_isSearching,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && _isSearching) _stopSearching();
      },
      child: CustomScaffold(
        title: _isSearching ? null : S.of(context).appName,
        titleWidget: _isSearching ? _buildSearchField() : null,
        // A pill that fills the bar must not be centre-constrained.
        centerTitle: _isSearching ? false : null,
        leading: _isSearching
            ? Semantics(
                button: true,
                label: S.of(context).back,
                child: IconButton(icon: const Icon(Icons.arrow_back_rounded), onPressed: _stopSearching),
              )
            : null,
        showBackButton: false,
        appBarActions: _isSearching
            ? const [SizedBox(width: AppTokens.s8)]
            : [
                Semantics(
                  button: true,
                  label: S.of(context).search,
                  child: IconButton(tooltip: S.of(context).search, icon: const Icon(Icons.search_rounded), onPressed: _startSearching),
                ),
                Semantics(
                  button: true,
                  label: S.of(context).settings,
                  child: IconButton(
                    tooltip: S.of(context).settings,
                    icon: const Icon(Icons.settings_outlined),
                    onPressed: () => Navigator.of(context).pushNamed(Routes.settings),
                  ),
                ),
              ],
        body: LayoutBuilder(
        builder: (context, constraints) {
          final Breakpoints bp = Breakpoints.of(constraints.maxWidth);
          return Center(
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: bp.maxContentWidth ?? double.infinity),
              child: BlocBuilder<SubjectsCubit, SubjectsState>(
                builder: (context, state) {
                  if (state.status.isInitial || state.status.isLoading) {
                    return SkeletonGridLoader(crossAxisCount: bp.gridColumns, childAspectRatio: 0.78);
                  }
                  if (state.status.isFailure) {
                    return AppErrorWidget(
                      message: state.failure?.statusMessage ?? S.of(context).genericError,
                      onRetry: () => context.read<SubjectsCubit>().getSubjects(),
                    );
                  }
                  if (state.status.isEmpty) {
                    return EmptyStateWidget(icon: Icons.menu_book_rounded, title: S.of(context).noSubjects);
                  }

                  final filtered = _query.isEmpty ? state.subjects : state.subjects.where((s) => s.name.toLowerCase().contains(_query)).toList();

                  if (filtered.isEmpty) {
                    return EmptyStateWidget(icon: Icons.search_off_rounded, title: S.of(context).noSearchResults);
                  }

                  final pagination = state.pagination;
                  final showFooter = !state.isSearching && pagination != null;

                  return Column(
                    children: [
                      Expanded(
                        child: CustomRefreshIndicator(
                          onRefresh: () => context.read<SubjectsCubit>().getSubjects(),
                          child: NotificationListener<ScrollNotification>(
                            onNotification: (notification) {
                              final metrics = notification.metrics;
                              if (metrics.pixels >= metrics.maxScrollExtent - 200) {
                                context.read<SubjectsCubit>().loadMoreSubjects();
                              }
                              return false;
                            },
                            child: GridView.builder(
                              physics: const AlwaysScrollableScrollPhysics(),
                              padding: EdgeInsets.fromLTRB(bp.horizontalPadding, AppTokens.s16, bp.horizontalPadding, AppTokens.s16),
                              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: bp.gridColumns,
                                childAspectRatio: 0.78,
                                crossAxisSpacing: AppTokens.s12,
                                mainAxisSpacing: AppTokens.s12,
                              ),
                              itemCount: filtered.length,
                              itemBuilder: (context, index) {
                                final subject = filtered[index];
                                return FadeSlideIn.staggered(
                                  index: index,
                                  child: SubjectCard(
                                    subject: subject,
                                    onTap: () => Navigator.of(context).pushNamed(
                                      Routes.chapters,
                                      arguments: ChaptersArgs(
                                        subjectId: subject.id,
                                        subjectName: subject.name,
                                        subjectThumbnailUrl: subject.thumbnailUrl,
                                      ),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ),
                      ),
                      if (showFooter) _PaginationFooter(pagination: pagination, isLoadingMore: state.isLoadingMore),
                    ],
                  );
                },
              ),
            ),
          );
        },
        ),
      ),
    );
  }
}

class _PaginationFooter extends StatelessWidget {
  final PaginationModel pagination;
  final bool isLoadingMore;

  const _PaginationFooter({required this.pagination, required this.isLoadingMore});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: isLoadingMore
            ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2.5))
            : Text(
                S.of(context).showingOfTotal(pagination.rangeEnd, pagination.total),
                style: const TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
              ),
      ),
    );
  }
}
