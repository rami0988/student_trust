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

  Future<void> getLessons(String chapterId) async {
    emit(
      state.rebuild(
        (b) => b
          ..status = Status.loading
          ..failure = null,
      ),
    );
    final result = await _lessonsRepository.getLessons(chapterId);
    result.fold(
      success: (lessons) => emit(
        state.rebuild(
          (b) => b
            ..status = lessons.isEmpty ? Status.empty : Status.success
            ..lessons = lessons
            ..downloadedLessonIds = _downloadedIds(lessons)
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

  /// Re-reads the local download state and refreshes the loaded list.
  void refreshDownloadState() {
    emit(state.rebuild((b) => b..downloadedLessonIds = _downloadedIds(state.lessons)));
  }

  List<String> _downloadedIds(List<Lesson> lessons) =>
      lessons.where((lesson) => _downloadService.isDownloaded(lesson.id)).map((lesson) => lesson.id).toList();
}
