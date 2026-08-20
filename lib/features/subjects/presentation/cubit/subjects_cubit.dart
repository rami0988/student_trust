import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/utils/app_enums.dart';
import '../../domain/repositories/subjects_repository.dart';
import 'subjects_state.dart';

@injectable
class SubjectsCubit extends Cubit<SubjectsState> {
  final SubjectsRepository _subjectsRepository;

  SubjectsCubit(this._subjectsRepository) : super(SubjectsState.initial());

  /// (Re)loads page 1 — the normal, paginated entry point. Also how a search
  /// gets cleared: it drops back out of [SubjectsState.isSearching].
  Future<void> getSubjects() async {
    emit(
      state.rebuild(
        (b) => b
          ..status = Status.loading
          ..isSearching = false
          ..pagination = null
          ..failure = null,
      ),
    );
    final result = await _subjectsRepository.getSubjects(page: 1);
    result.fold(
      success: (page) => emit(
        state.rebuild(
          (b) => b
            ..status = page.items.isEmpty ? Status.empty : Status.success
            ..subjects = page.items
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
  /// No-ops while already loading, mid-search, or already on the last page.
  Future<void> loadMoreSubjects() async {
    final pagination = state.pagination;
    if (state.isLoadingMore || state.isSearching) return;
    if (pagination == null || !pagination.hasNextPage) return;

    emit(state.rebuild((b) => b..isLoadingMore = true));
    final result = await _subjectsRepository.getSubjects(page: pagination.page + 1);
    result.fold(
      success: (page) => emit(
        state.rebuild(
          (b) => b
            ..isLoadingMore = false
            ..subjects = [...state.subjects, ...page.items]
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

  /// The backend has no `?search=` param for this endpoint, so a search that
  /// must see further than whatever page happens to be loaded has to hold
  /// the *complete* list instead of one page — entered once (idempotent
  /// while already active) and left via [getSubjects].
  Future<void> searchSubjects() async {
    if (state.isSearching) return;
    emit(
      state.rebuild(
        (b) => b
          ..status = Status.loading
          ..isSearching = true,
      ),
    );
    final result = await _subjectsRepository.getAllSubjects();
    result.fold(
      success: (subjects) => emit(
        state.rebuild(
          (b) => b
            ..status = subjects.isEmpty ? Status.empty : Status.success
            ..subjects = subjects
            ..pagination = null,
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
}
