import 'package:built_value/built_value.dart';

import '../../../../core/error/failures.dart';
import '../../../../core/utils/app_enums.dart';
import '../../domain/entities/worksheet_file.dart';
import '../../domain/entities/worksheet_video.dart';

part 'worksheet_view_state.g.dart';

/// Single state object for the worksheet view: files + videos + per-file
/// device-download progress.
abstract class WorksheetViewState implements Built<WorksheetViewState, WorksheetViewStateBuilder> {
  /// Load status for [files]/[videos] — drives the full-page shimmer/error.
  Status get status;
  Failure? get failure;
  List<WorksheetFile> get files;
  List<WorksheetVideo> get videos;

  /// fileId → download progress (0..1) for in-flight device downloads.
  Map<String, double> get downloading;

  /// fileId → saved path of completed device downloads (for the snackbar).
  Map<String, String> get savedPaths;

  /// One-shot success message (e.g. "saved to Downloads") consumed by the
  /// listener.
  String? get notice;

  /// One-shot device-download error message, distinct from [failure] (which
  /// drives the full-page ErrorView for the initial files/videos load).
  String? get downloadError;

  WorksheetViewState._();
  factory WorksheetViewState([void Function(WorksheetViewStateBuilder) updates]) = _$WorksheetViewState;

  factory WorksheetViewState.initial() => WorksheetViewState(
    (b) => b
      ..status = Status.loading
      ..failure = null
      ..files = []
      ..videos = []
      ..downloading = {}
      ..savedPaths = {}
      ..notice = null
      ..downloadError = null,
  );
}
