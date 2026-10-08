import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:injectable/injectable.dart';

import '../models/download_record.dart';

/// Persistent queue of in-flight downloads — the source of truth for
/// everything requested but not yet finished.
///
/// Before this existed, the queue and every paused download lived only in
/// `DownloadCubit` memory, and the partial file had no metadata at all. An app
/// kill therefore lost the queue, and the next launch's startup cleanup found
/// a lesson folder with no record, took it for an orphan and deleted it — so
/// "pause, close the app, come back tomorrow" restarted from 0%. A record is
/// now written the moment a download is requested and removed only once the
/// lesson is fully downloaded (or cancelled).
///
/// Status changes go through [transition], which refuses illegal moves rather
/// than throwing: a late progress tick racing a pause must not resurrect a
/// paused download, and a stale callback must never crash the app.
@lazySingleton
class DownloadRecordsStore {
  DownloadRecordsStore();

  static const String boxName = 'edushield_download_records';

  Box<DownloadRecord> get _box => Hive.box<DownloadRecord>(boxName);

  /// Which statuses each status may move to. Anything else is ignored.
  static const Map<DownloadRecordStatus, Set<DownloadRecordStatus>> allowedTransitions = {
    DownloadRecordStatus.queued: {
      DownloadRecordStatus.downloading,
      DownloadRecordStatus.paused,
      DownloadRecordStatus.waitingForNetwork,
      DownloadRecordStatus.failed,
    },
    DownloadRecordStatus.downloading: {
      DownloadRecordStatus.queued, // restored after an app kill
      DownloadRecordStatus.paused,
      DownloadRecordStatus.waitingForNetwork,
      DownloadRecordStatus.failed,
    },
    DownloadRecordStatus.paused: {DownloadRecordStatus.queued},
    DownloadRecordStatus.waitingForNetwork: {DownloadRecordStatus.queued, DownloadRecordStatus.paused},
    DownloadRecordStatus.failed: {DownloadRecordStatus.queued},
  };

  /// True when moving from [from] to [to] is a legal transition. Staying in
  /// the same status is always allowed (it is how progress is checkpointed).
  static bool canTransition(DownloadRecordStatus from, DownloadRecordStatus to) {
    return from == to || (allowedTransitions[from]?.contains(to) ?? false);
  }

  /// Every record, oldest request first — the order downloads were asked for.
  List<DownloadRecord> all() {
    final List<DownloadRecord> records = _box.values.toList();
    records.sort((a, b) => a.createdAt.compareTo(b.createdAt));
    return records;
  }

  DownloadRecord? get(String lessonId) => _box.get(lessonId);

  bool contains(String lessonId) => _box.containsKey(lessonId);

  /// Creates or replaces the record for its lesson.
  Future<void> put(DownloadRecord record) => _box.put(record.lessonId, record);

  /// Moves [lessonId] to [status] (and updates the given fields) when that is
  /// a legal transition. Returns the stored record, or null when there is no
  /// record or the move was refused.
  Future<DownloadRecord?> transition(
    String lessonId,
    DownloadRecordStatus status, {
    int? bytesReceived,
    int? totalBytes,
    String? error,
  }) async {
    final DownloadRecord? current = _box.get(lessonId);
    if (current == null) return null;
    if (!canTransition(current.status, status)) return null;
    final DownloadRecord next = current.copyWith(
      status: status,
      bytesReceived: bytesReceived,
      totalBytes: totalBytes,
      error: error,
    );
    await _box.put(lessonId, next);
    return next;
  }

  /// Rewrites every record interrupted by an app kill so it can be picked up
  /// again: [DownloadRecordStatus.downloading] becomes
  /// [DownloadRecordStatus.queued] (no transfer is running in a fresh
  /// process). Everything else keeps its status. Returns all records.
  Future<List<DownloadRecord>> recoverAfterRestart() async {
    for (final DownloadRecord record in _box.values.toList()) {
      if (record.status == DownloadRecordStatus.downloading) {
        await _box.put(record.lessonId, record.copyWith(status: DownloadRecordStatus.queued, error: record.error));
      }
    }
    return all();
  }

  Future<void> remove(String lessonId) => _box.delete(lessonId);

  /// Drops every record (used when the account is deactivated).
  Future<void> clear() => _box.clear();
}
