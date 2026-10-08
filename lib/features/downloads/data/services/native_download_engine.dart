import 'dart:async';
import 'dart:io';

import 'package:injectable/injectable.dart';

import '../../../../core/network/endpoints.dart';
import '../local/download_records_store.dart';
import 'background_transfer_client.dart';
import 'download_engine.dart';
import 'encrypted_download_service.dart';
import 'storage_guard.dart';

/// A native transfer failed for a reason other than connectivity.
class NativeTransferException implements Exception {
  final String message;
  const NativeTransferException(this.message);

  @override
  String toString() => 'NativeTransferException($message)';
}

/// [DownloadEngine] backed by the OS background transfer service (Android
/// WorkManager as a foreground service / iOS background `URLSession`), via
/// [BackgroundTransferClient].
///
/// The byte transfer runs OUTSIDE the app process, so it keeps going when the
/// app is backgrounded, the screen locks, or the OS kills the app. Everything
/// around it stays in Dart and is shared with [DartDownloadEngine]: resolving
/// the signed URL, the storage check, and the finishing step
/// ([EncryptedDownloadService.finalizeTransferredFile]: JSON guard, size gate,
/// encryption, metadata).
///
/// ## Surviving app restarts
///
/// The lesson id is the native task id. When the queue restarts a lesson after
/// an app kill (`DownloadCubit.restore` → [start]), the engine first asks the
/// plugin's task database what became of that task:
///  * finished while the app was dead → finalize it now, no new transfer;
///  * still running / queued / waiting to retry → attach to it;
///  * paused → resume it from the partial the OS kept;
///  * unknown / failed / cancelled → start a fresh transfer.
///
/// ## Mapping to the cubit's outcomes
///  * a pause WE asked for → [DownloadOutcome.paused];
///  * a pause the OS made (e.g. it lost the network) → a network error, which
///    the cubit turns into "waiting for network" and resumes automatically;
///  * 401/403 → one retry with a freshly signed URL;
///  * connection failure → [SocketException] (network-class);
///  * disk full → [InsufficientStorageException].
@lazySingleton
class NativeDownloadEngine implements DownloadEngine {
  NativeDownloadEngine(this._service, this._client, this._storageGuard, this._records);

  final EncryptedDownloadService _service;
  final BackgroundTransferClient _client;
  final StorageGuard _storageGuard;
  final DownloadRecordsStore _records;

  final Map<String, _ActiveTransfer> _active = {};
  StreamSubscription<TransferUpdate>? _subscription;
  Future<void>? _ready;

  /// Directory (relative to app documents) the OS writes a lesson into — the
  /// same one [EncryptedDownloadService] reads from.
  static String directoryFor(String lessonId) => 'edushield_videos/$lessonId';

  Future<void> _ensureReady() => _ready ??= _initialize();

  Future<void> _initialize() async {
    // Listen BEFORE the client starts: starting replays what happened while
    // the app was suspended or dead.
    _subscription = _client.updates.listen(_onUpdate);
    await _client.ensureReady();
    await _dropOrphanedPausedTasks();
  }

  /// A paused native task keeps a partial file. If its lesson no longer has a
  /// pending download record (cancelled while paused, or the account was
  /// purged), nothing will ever resume it — reclaim the space.
  Future<void> _dropOrphanedPausedTasks() async {
    try {
      for (final String taskId in await _client.pausedTaskIds()) {
        if (_records.contains(taskId)) continue;
        await _client.cancel(taskId);
        await _client.forget(taskId);
      }
    } catch (_) {
      // Housekeeping only — never block a download on it.
    }
  }

  @override
  Future<DownloadOutcome> start(DownloadRequest request, {required void Function(TransferProgress) onProgress}) async {
    await _ensureReady();
    final String id = request.lessonId;
    final _ActiveTransfer active = _ActiveTransfer(request, onProgress);
    _active[id] = active;
    try {
      final TransferSnapshot? snapshot = await _client.snapshot(id);
      if (snapshot != null && snapshot.expectedBytes > 0) active.expectedBytes = snapshot.expectedBytes;
      switch (snapshot?.status) {
        case TransferStatus.complete:
          // Finished while the app wasn't running.
          if (await _partExists(id)) {
            _beginFinalize(active);
          } else {
            await _enqueueFresh(active);
          }
        case TransferStatus.enqueued || TransferStatus.running || TransferStatus.waitingToRetry:
          break; // still in flight natively: attach, updates will arrive
        case TransferStatus.paused:
          if (!await _client.resume(id)) await _enqueueFresh(active);
        default:
          await _enqueueFresh(active);
      }
      return await active.result.future;
    } finally {
      if (identical(_active[id], active)) _active.remove(id);
    }
  }

  @override
  void pause(String lessonId) {
    final _ActiveTransfer? active = _active[lessonId];
    if (active == null || active.finalizing || active.result.isCompleted) return;
    active.pauseRequested = true;
    if (!active.enqueued) return; // _enqueueFresh honours the flag
    unawaited(
      _client.pause(lessonId).then((paused) async {
        // The OS can't pause a task that hasn't started, or a server without
        // range support. Fall back to stopping it: the record stays paused and
        // the next start transfers again.
        if (!paused && !active.result.isCompleted) {
          active.fallbackPause = true;
          await _client.cancel(lessonId);
        }
      }),
    );
  }

  @override
  void cancel(String lessonId) {
    final _ActiveTransfer? active = _active[lessonId];
    if (active == null || active.result.isCompleted) return;
    active.cancelRequested = true;
    if (active.finalizing || !active.enqueued) return; // handled where it lands
    unawaited(_client.cancel(lessonId));
  }

  @override
  bool isActive(String lessonId) => _active.containsKey(lessonId);

  // --- Starting a transfer ------------------------------------------------------

  Future<void> _enqueueFresh(_ActiveTransfer active) async {
    final DownloadRequest r = active.request;
    await _service.beginDownload(r.lessonId);
    // A partial left by the in-process engine (or an older attempt) is not
    // something the OS service can resume — start clean.
    await _service.discardPartial(r.lessonId);

    final String url = await _service.resolveDownloadUrl(
      videoUrl: r.videoUrl,
      accessToken: r.accessToken,
      deviceUuid: r.deviceUuid,
    );

    // The student may have paused or cancelled while the URL was resolving.
    if (active.cancelRequested) return _finishCancelled(active);
    if (active.pauseRequested) return _finish(active, DownloadOutcome.paused);

    // BunnyCDN needs the embed Referer; the dev backend serves bytes itself
    // and needs the session (a signed CDN URL needs neither).
    final Map<String, String> headers = {...BunnyConstants.cdnHeaders};
    if (url == r.videoUrl) {
      headers['Authorization'] = 'Bearer ${await r.accessToken()}';
      headers['X-Device-ID'] = r.deviceUuid;
    }

    final bool queued = await _client.enqueue(
      TransferTask(
        taskId: r.lessonId,
        url: url,
        headers: headers,
        directory: directoryFor(r.lessonId),
        filename: EncryptedDownloadService.partFileName,
        displayName: r.title,
      ),
    );
    if (!queued) throw const NativeTransferException('the system refused the download');
    active.enqueued = true;
  }

  // --- Updates ------------------------------------------------------------------

  void _onUpdate(TransferUpdate update) {
    final _ActiveTransfer? active = _active[update.taskId];
    if (active == null || active.result.isCompleted) return;
    switch (update) {
      case TransferProgressUpdate():
        _onProgress(active, update);
      case TransferStatusUpdate():
        _onStatus(active, update);
    }
  }

  void _onProgress(_ActiveTransfer active, TransferProgressUpdate update) {
    if (update.progress < 0 || active.finalizing) return; // plugin sentinels
    active.enqueued = true;
    if (update.expectedBytes > 0) active.expectedBytes = update.expectedBytes;
    final int total = active.expectedBytes;
    final int received = total > 0 ? (update.progress * total).round() : 0;

    // The first moment the real size is known: refuse a download that can't
    // fit instead of filling the disk.
    if (!active.storageChecked && total > 0) {
      active.storageChecked = true;
      unawaited(_checkStorage(active, total, received));
    }
    active.onProgress(
      TransferProgress(fraction: (update.progress * 0.85).clamp(0.0, 0.85), bytesReceived: received, totalBytes: total),
    );
  }

  Future<void> _checkStorage(_ActiveTransfer active, int total, int received) async {
    try {
      await _storageGuard.ensureCanFit(totalBytes: total, alreadyOnDisk: received);
    } on InsufficientStorageException catch (e) {
      active.pendingError = e;
      await _client.cancel(active.request.lessonId);
    }
  }

  void _onStatus(_ActiveTransfer active, TransferStatusUpdate update) {
    switch (update.status) {
      case TransferStatus.enqueued || TransferStatus.running || TransferStatus.waitingToRetry:
        active.enqueued = true; // the OS retries transient failures itself
      case TransferStatus.complete:
        _beginFinalize(active);
      case TransferStatus.paused:
        if (active.pauseRequested) {
          _finish(active, DownloadOutcome.paused);
        } else {
          // The OS paused it (e.g. the network went away). Report it as a
          // connectivity failure: the cubit then waits for the network and
          // restarts it, which resumes this paused task.
          _fail(active, const SocketException('Transfer paused by the system'));
        }
      case TransferStatus.canceled:
        final Object? pending = active.pendingError;
        if (pending != null) {
          _fail(active, pending);
        } else if (active.fallbackPause) {
          _finish(active, DownloadOutcome.paused);
        } else {
          unawaited(_finishCancelled(active));
        }
      case TransferStatus.failed:
        final int? code = update.httpStatusCode;
        if ((code == 401 || code == 403) && !active.renewed) {
          // The signed URL (or session) expired during a long transfer: one
          // attempt with a freshly resolved URL.
          active.renewed = true;
          unawaited(_enqueueFresh(active).catchError((Object e) => _fail(active, e)));
          return;
        }
        _fail(active, _errorFor(update));
      case TransferStatus.notFound:
        _fail(active, const NativeTransferException('download not found'));
    }
  }

  static Object _errorFor(TransferStatusUpdate update) {
    final String message = update.errorMessage ?? 'transfer failed';
    switch (update.errorKind) {
      case TransferErrorKind.connection:
        return SocketException(message);
      case TransferErrorKind.fileSystem:
        final String lower = message.toLowerCase();
        if (lower.contains('space') || lower.contains('enospc')) return const InsufficientStorageException(0, -1);
        return NativeTransferException(message);
      case TransferErrorKind.http:
        return NativeTransferException('HTTP ${update.httpStatusCode ?? '?'}: $message');
      case TransferErrorKind.resume:
      case TransferErrorKind.other:
      case null:
        return NativeTransferException(message);
    }
  }

  // --- Finishing ----------------------------------------------------------------

  void _beginFinalize(_ActiveTransfer active) {
    if (active.finalizing || active.result.isCompleted) return;
    active.finalizing = true;
    unawaited(_finalize(active));
  }

  Future<void> _finalize(_ActiveTransfer active) async {
    final DownloadRequest r = active.request;
    final int total = active.expectedBytes;
    try {
      await _service.finalizeTransferredFile(
        lessonId: r.lessonId,
        expectedTotal: total > 0 ? total : 0,
        studentId: r.studentId,
        deviceUuid: r.deviceUuid,
        accessToken: r.accessToken,
        onProgress: (fraction) =>
            active.onProgress(TransferProgress(fraction: fraction, bytesReceived: total, totalBytes: total)),
        title: r.title,
        durationSeconds: r.durationSeconds,
        thumbnailUrl: r.thumbnailUrl,
      );
      await _forget(r.lessonId);
      if (active.cancelRequested) return _finishCancelled(active);
      _finish(active, DownloadOutcome.completed);
    } catch (e) {
      await _forget(r.lessonId);
      _fail(active, e);
    }
  }

  Future<void> _finishCancelled(_ActiveTransfer active) async {
    final String id = active.request.lessonId;
    try {
      await _service.deleteLesson(id);
    } catch (_) {}
    await _forget(id);
    _finish(active, DownloadOutcome.canceled);
  }

  Future<void> _forget(String taskId) async {
    try {
      await _client.forget(taskId);
    } catch (_) {}
  }

  Future<bool> _partExists(String lessonId) async {
    final Directory dir = await _service.lessonDirectory(lessonId);
    return File('${dir.path}/${EncryptedDownloadService.partFileName}').existsSync();
  }

  void _finish(_ActiveTransfer active, DownloadOutcome outcome) {
    if (!active.result.isCompleted) active.result.complete(outcome);
  }

  void _fail(_ActiveTransfer active, Object error) {
    if (!active.result.isCompleted) active.result.completeError(error);
  }

  @disposeMethod
  Future<void> dispose() async => _subscription?.cancel();
}

/// Bookkeeping for one lesson while [NativeDownloadEngine.start] is running.
class _ActiveTransfer {
  _ActiveTransfer(this.request, this.onProgress);

  final DownloadRequest request;
  final void Function(TransferProgress) onProgress;
  final Completer<DownloadOutcome> result = Completer<DownloadOutcome>();

  int expectedBytes = 0;

  /// The native task exists (enqueued, attached to, or reporting).
  bool enqueued = false;
  bool pauseRequested = false;
  bool cancelRequested = false;

  /// The OS couldn't pause, so the task was cancelled to stand in for a pause.
  bool fallbackPause = false;

  /// One fresh-URL retry after a 401/403 has been used.
  bool renewed = false;
  bool storageChecked = false;
  bool finalizing = false;

  /// An error decided by the engine (e.g. no space) that a following
  /// `canceled` status must surface instead of a plain cancellation.
  Object? pendingError;
}
