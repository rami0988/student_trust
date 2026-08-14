import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/utils/app_enums.dart';
import '../../domain/repositories/subjects_repository.dart';
import 'subjects_state.dart';

@injectable
class SubjectsCubit extends Cubit<SubjectsState> {
  final SubjectsRepository _subjectsRepository;

  SubjectsCubit(this._subjectsRepository) : super(SubjectsState.initial());

  Future<void> getSubjects() async {
    emit(
      state.rebuild(
        (b) => b
          ..status = Status.loading
          ..failure = null,
      ),
    );
    final result = await _subjectsRepository.getSubjects();
    result.fold(
      success: (subjects) => emit(
        state.rebuild(
          (b) => b
            ..status = subjects.isEmpty ? Status.empty : Status.success
            ..subjects = subjects
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
