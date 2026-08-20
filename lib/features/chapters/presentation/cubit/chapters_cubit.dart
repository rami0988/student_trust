import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/utils/app_enums.dart';
import '../../domain/repositories/chapters_repository.dart';
import 'chapters_state.dart';

@injectable
class ChaptersCubit extends Cubit<ChaptersState> {
  final ChaptersRepository _chaptersRepository;

  ChaptersCubit(this._chaptersRepository) : super(ChaptersState.initial());

  /// (Re)loads page 1 — the normal, paginated entry point.
  Future<void> getChapters(String subjectId) async {
    emit(
      state.rebuild(
        (b) => b
          ..status = Status.loading
          ..pagination = null
          ..failure = null,
      ),
    );
    final result = await _chaptersRepository.getChapters(subjectId, page: 1);
    result.fold(
      success: (page) => emit(
        state.rebuild(
          (b) => b
            ..status = page.items.isEmpty ? Status.empty : Status.success
            ..chapters = page.items
            ..pagination = page.pagination
            ..failure = null,
        ),
      ),
      failure: (failure) => emit(
        state.rebuild(
          (b) => b
            ..status = Status.failure
            ..failure = failure,
        ),
      ),
    );
  }

  /// Infinite-scroll "load more": fetches the next page and appends it.
  /// No-ops while already loading or already on the last page.
  Future<void> loadMoreChapters(String subjectId) async {
    final pagination = state.pagination;
    if (state.isLoadingMore) return;
    if (pagination == null || !pagination.hasNextPage) return;

    emit(state.rebuild((b) => b..isLoadingMore = true));
    final result = await _chaptersRepository.getChapters(subjectId, page: pagination.page + 1);
    result.fold(
      success: (page) => emit(
        state.rebuild(
          (b) => b
            ..isLoadingMore = false
            ..chapters = [...state.chapters, ...page.items]
            ..pagination = page.pagination,
        ),
      ),
      failure: (failure) => emit(
        // Keep the loaded list on screen — a failed *next* page shouldn't
        // blank out the page the student is already looking at.
        state.rebuild(
          (b) => b
            ..isLoadingMore = false
            ..failure = failure,
        ),
      ),
    );
  }
}
