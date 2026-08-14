import 'package:bloc/bloc.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/utils/app_enums.dart';
import '../../../../core/utils/request_result.dart';
import '../../../../generated/l10n.dart';
import '../../domain/entities/worksheet_file.dart';
import '../../domain/entities/worksheet_video.dart';
import '../../domain/repositories/worksheets_repository.dart';
import 'worksheet_view_state.dart';

@injectable
class WorksheetViewCubit extends Cubit<WorksheetViewState> {
  final WorksheetsRepository _worksheetsRepository;

  WorksheetViewCubit(this._worksheetsRepository) : super(WorksheetViewState.initial());

  String _worksheetId = '';

  Future<void> load(String worksheetId) async {
    _worksheetId = worksheetId;
    emit(
      state.rebuild(
        (b) => b
          ..status = Status.loading
          ..failure = null,
      ),
    );

    final List<dynamic> results = await Future.wait([
      _worksheetsRepository.getFiles(worksheetId),
      _worksheetsRepository.getVideos(worksheetId),
    ]);
    final RequestResult<List<WorksheetFile>> filesResult = results[0] as RequestResult<List<WorksheetFile>>;
    final RequestResult<List<WorksheetVideo>> videosResult = results[1] as RequestResult<List<WorksheetVideo>>;

    if (filesResult.isFailure && videosResult.isFailure) {
      emit(
        state.rebuild(
          (b) => b
            ..status = Status.failure
            ..failure = (filesResult as FailureResult<List<WorksheetFile>>).failure,
        ),
      );
      return;
    }

    final List<WorksheetFile> files = filesResult.fold(success: (data) => data, failure: (_) => const []);
    final List<WorksheetVideo> videos = videosResult.fold(success: (data) => data, failure: (_) => const []);
    emit(
      state.rebuild(
        (b) => b
          ..status = (files.isEmpty && videos.isEmpty) ? Status.empty : Status.success
          ..files = files
          ..videos = videos,
      ),
    );
  }

  Future<void> refresh() => load(_worksheetId);

  /// Saves a PDF to the device Downloads folder with progress.
  Future<void> downloadToDevice(WorksheetFile file) async {
    if (state.downloading.containsKey(file.id)) return;
    emit(
      state.rebuild(
        (b) => b
          ..downloading = {...state.downloading, file.id: 0.0}
          ..downloadError = null,
      ),
    );

    final RequestResult<String> result = await _worksheetsRepository.downloadPdfToDevice(
      file.url,
      file.fileName,
      onProgress: (received, total) {
        if (isClosed || total <= 0) return;
        emit(state.rebuild((b) => b..downloading = {...state.downloading, file.id: received / total}));
      },
    );

    if (isClosed) return;
    final Map<String, double> downloading = {...state.downloading}..remove(file.id);
    result.fold(
      success: (path) => emit(
        state.rebuild(
          (b) => b
            ..downloading = downloading
            ..savedPaths = {...state.savedPaths, file.id: path}
            ..notice = S.current.downloaded,
        ),
      ),
      failure: (failure) => emit(
        state.rebuild(
          (b) => b
            ..downloading = downloading
            ..downloadError = failure.statusMessage,
        ),
      ),
    );
  }

  /// Clears one-shot notice/error after the UI has shown them.
  void clearMessages() {
    if (state.notice != null || state.downloadError != null) {
      emit(
        state.rebuild(
          (b) => b
            ..notice = null
            ..downloadError = null,
        ),
      );
    }
  }
}
