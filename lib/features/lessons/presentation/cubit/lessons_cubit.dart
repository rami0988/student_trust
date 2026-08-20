import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/utils/app_enums.dart';
import '../../../downloads/data/services/encrypted_download_service.dart';
import '../../domain/entities/lesson.dart';
import '../../domain/repositories/lessons_repository.dart';
import 'lessons_state.dart';

@injectable
class LessonsCubit extends Cubit<LessonsState> {
  final LessonsRepository _lessonsRepository;
  final EncryptedDownloadService _downloadService;

  LessonsCubit(this._lessonsRepository, this._downloadService) : super(LessonsState.initial());

  /// (Re)loads page 1 — the normal, paginated entry point.
  Future<void> getLessons(String chapterId) async {
    emit(
      state.rebuild(
        (b) => b
          ..status = Status.loading
          ..pagination = null
          ..failure = null,
      ),
    );
    final result = await _lessonsRepository.getLessons(chapterId, page: 1);
    result.fold(
      success: (page) => emit(
        state.rebuild(
          (b) => b
            ..status = page.items.isEmpty ? Status.empty : Status.success
            ..lessons = page.items
            ..pagination = page.pagination
            ..downloadedLessonIds = _downloadedIds(page.items)
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
  Future<void> loadMoreLessons(String chapterId) async {
    final pagination = state.pagination;
    if (state.isLoadingMore) return;
    if (pagination == null || !pagination.hasNextPage) return;

    emit(state.rebuild((b) => b..isLoadingMore = true));
    final result = await _lessonsRepository.getLessons(chapterId, page: pagination.page + 1);
    result.fold(
      success: (page) {
        final List<Lesson> merged = [...state.lessons, ...page.items];
        emit(
          state.rebuild(
            (b) => b
              ..isLoadingMore = false
              ..lessons = merged
              ..pagination = page.pagination
              ..downloadedLessonIds = _downloadedIds(merged),
          ),
        );
      },
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

  /// Re-reads the local download state and refreshes the loaded list.
  void refreshDownloadState() {
    emit(state.rebuild((b) => b..downloadedLessonIds = _downloadedIds(state.lessons)));
  }

  List<String> _downloadedIds(List<Lesson> lessons) =>
      lessons.where((lesson) => _downloadService.isDownloaded(lesson.id)).map((lesson) => lesson.id).toList();
}
