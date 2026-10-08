import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:mobile_template/features/downloads/data/services/background_transfer_client.dart';

/// Scriptable stand-in for the OS background transfer service.
///
/// Records what the engine asked for; the test then plays the part of the OS
/// by emitting status/progress updates — and, for a successful transfer,
/// writing the downloaded file exactly where the real service would put it
/// (`<documents>/<task.directory>/<task.filename>`).
class FakeTransferClient implements BackgroundTransferClient {
  FakeTransferClient(this.documentsPath);

  /// Root the real plugin resolves `BaseDirectory.applicationDocuments` to.
  final String documentsPath;

  final StreamController<TransferUpdate> _updates = StreamController<TransferUpdate>.broadcast();

  final List<TransferTask> enqueued = [];
  final List<String> pauseCalls = [];
  final List<String> resumeCalls = [];
  final List<String> cancelCalls = [];
  final List<String> forgotten = [];
  int readyCalls = 0;

  /// What [snapshot] reports per task id (the plugin's persistent database).
  final Map<String, TransferSnapshot> snapshots = {};

  /// Ids [pausedTaskIds] reports.
  final List<String> paused = [];

  bool pauseSucceeds = true;
  bool resumeSucceeds = true;

  /// When true, [cancel] answers with a `canceled` status like the real OS.
  bool emitOnCancel = true;

  @override
  Stream<TransferUpdate> get updates => _updates.stream;

  @override
  Future<void> ensureReady() async => readyCalls++;

  @override
  Future<bool> enqueue(TransferTask task) async {
    enqueued.add(task);
    return true;
  }

  @override
  Future<bool> pause(String taskId) async {
    pauseCalls.add(taskId);
    if (pauseSucceeds) status(taskId, TransferStatus.paused);
    return pauseSucceeds;
  }

  @override
  Future<bool> resume(String taskId) async {
    resumeCalls.add(taskId);
    return resumeSucceeds;
  }

  @override
  Future<bool> cancel(String taskId) async {
    cancelCalls.add(taskId);
    if (emitOnCancel) status(taskId, TransferStatus.canceled);
    return true;
  }

  @override
  Future<TransferSnapshot?> snapshot(String taskId) async => snapshots[taskId];

  @override
  Future<List<String>> pausedTaskIds() async => List<String>.of(paused);

  @override
  Future<void> forget(String taskId) async => forgotten.add(taskId);

  // --- Playing the OS ---------------------------------------------------------

  void status(String taskId, TransferStatus s, {int? http, TransferErrorKind? kind, String? message}) =>
      _updates.add(TransferStatusUpdate(taskId, s, httpStatusCode: http, errorKind: kind, errorMessage: message));

  void progress(String taskId, double fraction, int expectedBytes) =>
      _updates.add(TransferProgressUpdate(taskId, fraction, expectedBytes));

  /// Writes [body] where the last enqueued task for [taskId] targets.
  File writeDownloadedFile(String taskId, Uint8List body, {String? directory, String filename = 'video.part'}) {
    final TransferTask? task = enqueued.where((t) => t.taskId == taskId).lastOrNull;
    final String dir = '$documentsPath/${directory ?? task!.directory}';
    Directory(dir).createSync(recursive: true);
    return File('$dir/${task?.filename ?? filename}')..writeAsBytesSync(body);
  }

  /// A whole successful transfer: progress, the file on disk, `complete`.
  void succeed(String taskId, Uint8List body) {
    progress(taskId, 0.5, body.length);
    writeDownloadedFile(taskId, body);
    status(taskId, TransferStatus.complete);
  }

  Future<void> close() => _updates.close();
}
