import 'dart:async';

import 'package:background_downloader/background_downloader.dart' as bd;
import 'package:injectable/injectable.dart';

import '../../../../generated/l10n.dart';

/// Status of a native background transfer. Mirrors the plugin's TaskStatus so
/// the engine never depends on the plugin's types (and can be tested without
/// any native code).
enum TransferStatus { enqueued, running, complete, notFound, failed, canceled, waitingToRetry, paused }

/// Why a transfer failed, as far as the engine needs to know.
enum TransferErrorKind { connection, http, fileSystem, resume, other }

/// One file to fetch in the background into
/// `<app documents>/[directory]/[filename]`.
class TransferTask {
  final String taskId;
  final String url;
  final Map<String, String> headers;
  final String directory;
  final String filename;

  /// Shown in the system notification.
  final String displayName;

  const TransferTask({
    required this.taskId,
    required this.url,
    required this.headers,
    required this.directory,
    required this.filename,
    required this.displayName,
  });
}

sealed class TransferUpdate {
  final String taskId;
  const TransferUpdate(this.taskId);
}

class TransferStatusUpdate extends TransferUpdate {
  final TransferStatus status;
  final int? httpStatusCode;
  final TransferErrorKind? errorKind;
  final String? errorMessage;

  const TransferStatusUpdate(super.taskId, this.status, {this.httpStatusCode, this.errorKind, this.errorMessage});
}

class TransferProgressUpdate extends TransferUpdate {
  /// 0..1 while transferring. Negative values are the plugin's sentinels for
  /// final states and carry no progress.
  final double progress;

  /// Size the server advertised, or <= 0 when unknown.
  final int expectedBytes;

  const TransferProgressUpdate(super.taskId, this.progress, this.expectedBytes);
}

/// What the plugin's persistent task database remembers about a task — used
/// after an app restart to pick up a transfer that kept running (or finished)
/// while the app was not.
class TransferSnapshot {
  final TransferStatus status;
  final int expectedBytes;

  const TransferSnapshot(this.status, this.expectedBytes);
}

/// The operations [NativeDownloadEngine] needs from the OS background
/// transfer service.
abstract class BackgroundTransferClient {
  /// Every status and progress update, for all tasks.
  Stream<TransferUpdate> get updates;

  /// Configures the service and starts tracking (idempotent). Subscribe to
  /// [updates] BEFORE calling this: it replays what happened while the app was
  /// suspended or killed.
  Future<void> ensureReady();

  Future<bool> enqueue(TransferTask task);
  Future<bool> pause(String taskId);
  Future<bool> resume(String taskId);
  Future<bool> cancel(String taskId);

  /// The persisted state of [taskId], or null when the service never saw it.
  Future<TransferSnapshot?> snapshot(String taskId);

  /// Task ids currently paused (and therefore holding a partial file).
  Future<List<String>> pausedTaskIds();

  /// Drops [taskId] from the persistent task database.
  Future<void> forget(String taskId);
}

/// [BackgroundTransferClient] on top of the `background_downloader` plugin:
/// Android WorkManager (as a foreground service, with a progress
/// notification) and iOS background `URLSession`. Transfers keep running when
/// the app is backgrounded, the screen is locked, or the app process is killed
/// by the OS.
@LazySingleton(as: BackgroundTransferClient)
class FileDownloaderClient implements BackgroundTransferClient {
  FileDownloaderClient();

  final StreamController<TransferUpdate> _updates = StreamController<TransferUpdate>.broadcast();
  // App-lifetime singleton: the subscription intentionally lives as long as
  // the process (the OS service keeps reporting to it).
  // ignore: unused_field
  StreamSubscription<bd.TaskUpdate>? _source;
  Future<void>? _ready;

  bd.FileDownloader get _fd => bd.FileDownloader();

  @override
  Stream<TransferUpdate> get updates => _updates.stream;

  @override
  Future<void> ensureReady() => _ready ??= _initialize();

  Future<void> _initialize() async {
    _source = _fd.updates.listen(_forward);

    // Android: run as a foreground service so long lessons aren't cut off by
    // WorkManager's ~9-minute limit for background work (needs the `running`
    // notification below and FOREGROUND_SERVICE_DATA_SYNC on API 34+).
    await _fd.configure(androidConfig: [(bd.Config.runInForeground, bd.Config.always)]);
    final S s = S.current;
    _fd.configureNotification(
      running: bd.TaskNotification('{displayName}', '${s.notificationDownloading} {progress}'),
      paused: bd.TaskNotification('{displayName}', s.notificationPaused),
      error: bd.TaskNotification('{displayName}', s.notificationFailed),
      progressBar: true,
    );

    // Android 13+ needs the notification permission for the progress
    // notification; downloads still work if the student declines.
    try {
      final bd.PermissionStatus status = await _fd.permissions.status(bd.PermissionType.notifications);
      if (status != bd.PermissionStatus.granted) {
        await _fd.permissions.request(bd.PermissionType.notifications);
      }
    } catch (_) {}

    // Track tasks in the plugin's database, replay updates that happened while
    // the app was suspended/killed, and reschedule tasks the OS killed.
    await _fd.start();
  }

  void _forward(bd.TaskUpdate update) {
    switch (update) {
      case bd.TaskStatusUpdate():
        final bd.TaskException? e = update.exception;
        _updates.add(
          TransferStatusUpdate(
            update.task.taskId,
            _status(update.status),
            httpStatusCode: update.responseStatusCode ?? (e is bd.TaskHttpException ? e.httpResponseCode : null),
            errorKind: e == null ? null : _errorKind(e),
            errorMessage: e?.description,
          ),
        );
      case bd.TaskProgressUpdate():
        _updates.add(TransferProgressUpdate(update.task.taskId, update.progress, update.expectedFileSize));
    }
  }

  static TransferStatus _status(bd.TaskStatus s) => switch (s) {
    bd.TaskStatus.enqueued => TransferStatus.enqueued,
    bd.TaskStatus.running => TransferStatus.running,
    bd.TaskStatus.complete => TransferStatus.complete,
    bd.TaskStatus.notFound => TransferStatus.notFound,
    bd.TaskStatus.failed => TransferStatus.failed,
    bd.TaskStatus.canceled => TransferStatus.canceled,
    bd.TaskStatus.waitingToRetry => TransferStatus.waitingToRetry,
    bd.TaskStatus.paused => TransferStatus.paused,
  };

  static TransferErrorKind _errorKind(bd.TaskException e) => switch (e) {
    bd.TaskConnectionException() => TransferErrorKind.connection,
    bd.TaskHttpException() => TransferErrorKind.http,
    bd.TaskFileSystemException() => TransferErrorKind.fileSystem,
    bd.TaskResumeException() => TransferErrorKind.resume,
    _ => TransferErrorKind.other,
  };

  @override
  Future<bool> enqueue(TransferTask task) => _fd.enqueue(
    bd.DownloadTask(
      taskId: task.taskId,
      url: task.url,
      headers: task.headers,
      baseDirectory: bd.BaseDirectory.applicationDocuments,
      directory: task.directory,
      filename: task.filename,
      displayName: task.displayName,
      updates: bd.Updates.statusAndProgress,
      allowPause: true,
      retries: 3,
      // Policy: cellular data is allowed by default.
      requiresWiFi: false,
    ),
  );

  Future<bd.DownloadTask?> _taskFor(String taskId) async {
    final bd.Task? live = await _fd.taskForId(taskId);
    if (live is bd.DownloadTask) return live;
    final bd.TaskRecord? record = await _fd.database.recordForId(taskId);
    final bd.Task? stored = record?.task;
    return stored is bd.DownloadTask ? stored : null;
  }

  @override
  Future<bool> pause(String taskId) async {
    final bd.DownloadTask? task = await _taskFor(taskId);
    return task != null && await _fd.pause(task);
  }

  @override
  Future<bool> resume(String taskId) async {
    final bd.DownloadTask? task = await _taskFor(taskId);
    return task != null && await _fd.resume(task);
  }

  @override
  Future<bool> cancel(String taskId) => _fd.cancelTaskWithId(taskId);

  @override
  Future<TransferSnapshot?> snapshot(String taskId) async {
    final bd.TaskRecord? record = await _fd.database.recordForId(taskId);
    if (record == null) return null;
    return TransferSnapshot(_status(record.status), record.expectedFileSize);
  }

  @override
  Future<List<String>> pausedTaskIds() async {
    final List<bd.TaskRecord> records = await _fd.database.allRecordsWithStatus(bd.TaskStatus.paused);
    return records.map((r) => r.taskId).toList();
  }

  @override
  Future<void> forget(String taskId) => _fd.database.deleteRecordWithId(taskId);
}
