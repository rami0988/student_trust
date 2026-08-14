import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/utils/app_enums.dart';
import '../../domain/repositories/chapters_repository.dart';
import 'chapters_state.dart';

@injectable
class ChaptersCubit extends Cubit<ChaptersState> {
  final ChaptersRepository _chaptersRepository;

  ChaptersCubit(this._chaptersRepository) : super(ChaptersState.initial());

  Future<void> getChapters(String subjectId) async {
    emit(
      state.rebuild(
        (b) => b
          ..status = Status.loading
          ..failure = null,
      ),
    );
    final result = await _chaptersRepository.getChapters(subjectId);
    result.fold(
      success: (chapters) => emit(
        state.rebuild(
          (b) => b
            ..status = chapters.isEmpty ? Status.empty : Status.success
            ..chapters = chapters
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
}
