import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/utils/app_enums.dart';
import '../../domain/repositories/worksheets_repository.dart';
import 'worksheets_state.dart';

@injectable
class WorksheetsCubit extends Cubit<WorksheetsState> {
  final WorksheetsRepository _worksheetsRepository;

  WorksheetsCubit(this._worksheetsRepository) : super(WorksheetsState.initial());

  Future<void> getWorksheets(String chapterId) async {
    emit(
      state.rebuild(
        (b) => b
          ..status = Status.loading
          ..failure = null,
      ),
    );
    final result = await _worksheetsRepository.getWorksheets(chapterId);
    result.fold(
      success: (worksheets) => emit(
        state.rebuild(
          (b) => b
            ..status = worksheets.isEmpty ? Status.empty : Status.success
            ..worksheets = worksheets
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
