import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import '../../../../core/services/connectivity_service.dart';
import '../../../../core/utils/local_storage_keys.dart';
import '../../../../core/utils/shared_preferences_helper.dart';
import '../../domain/entities/download_verdict.dart';
import '../../domain/repositories/downloads_repository.dart';
import 'encrypted_download_service.dart';

/// What one revalidation pass did.
class RevalidationReport {
  /// Purged locally for passing the 30-day offline lifetime.
  final List<String> expired;

  /// Confirmed still valid — their 7-day lock (if any) is lifted.
  final List<String> validated;

  /// Deleted because the server said the student may no longer keep them.
  final List<String> removed;

  /// False when the server pass was skipped (throttled, no session, empty
  /// library) or stopped early because a request failed.
  final bool reachedServer;

  const RevalidationReport({
    this.expired = const [],
    this.validated = const [],
    this.removed = const [],
    this.reachedServer = false,
  });
}

/// Keeps the offline library honest without the student having to open each
/// lesson: on launch and whenever connectivity returns, every downloaded lesson
/// is re-checked with the server in one batch request.
///
///  * Past the 30-day hard cap → purged locally (no network needed).
///  * Server says valid → `lastValidatedAt` refreshed, so a lesson locked by
///    the 7-day window unlocks by itself.
///  * Server says the student may no longer keep it (subscription ended,
///    moved grade, lesson deleted) → deleted, per policy.
///
/// Safety: only a definite verdict ever deletes. A failed request (offline,
/// server error, unreadable response) changes nothing — a network blip must
/// not wipe a paying student's library. An inactive account never gets this
/// far: the 401 ACCOUNT_INACTIVE it receives triggers the full purge through
/// `AccountDeactivatedEvent`.
@lazySingleton
class DownloadRevalidator {
  DownloadRevalidator(this._service, this._repository, this._connectivity);

  final EncryptedDownloadService _service;
  final DownloadsRepository _repository;
  final ConnectivityService _connectivity;

  /// Connectivity flaps (and app resumes) are frequent; the library doesn't
  /// change that fast. Launch always checks.
  static const Duration minInterval = Duration(minutes: 15);

  /// Lessons per request — well under the server's limit of 200.
  static const int batchSize = 100;

  @visibleForTesting
  static DateTime Function() clock = DateTime.now;

  /// Whether a signed-in session exists. Without one there is nobody to
  /// validate for, and the request would only bounce off the auth layer.
  @visibleForTesting
  static Future<bool> Function() hasSession = _hasStoredSession;

  static Future<bool> _hasStoredSession() async =>
      (await SharedPreferencesHelper.getSecuredString(LocalStorageKeys.accessToken)).isNotEmpty;

  DateTime? _lastServerPass;
  Future<RevalidationReport>? _running;
  StreamSubscription<bool>? _onlineSub;

  /// Runs a pass now and again each time the device comes back online.
  /// Safe to call more than once.
  void start() {
    _onlineSub ??= _connectivity.isOnline.where((online) => online).listen((_) => unawaited(revalidate()));
    unawaited(revalidate(force: true));
  }

  Future<void> stop() async {
    await _onlineSub?.cancel();
    _onlineSub = null;
  }

  /// One pass. Concurrent calls share the pass already running. [force]
  /// bypasses [minInterval].
  Future<RevalidationReport> revalidate({bool force = false}) {
    return _running ??= _pass(force: force).whenComplete(() {
      _running = null;
    });
  }

  Future<RevalidationReport> _pass({required bool force}) async {
    // Local and unconditional: the 30-day cap needs no server.
    final List<String> expired = await _service.purgeExpired();

    final DateTime? last = _lastServerPass;
    final bool throttled = !force && last != null && clock().difference(last) < minInterval;
    if (throttled || !await hasSession()) return RevalidationReport(expired: expired);

    final List<String> ids = _service.getDownloadedLessons().map((l) => l.lessonId).toList();
    if (ids.isEmpty) {
      _lastServerPass = clock();
      return RevalidationReport(expired: expired, reachedServer: true);
    }

    final List<String> validated = [];
    final List<String> removed = [];
    for (int start = 0; start < ids.length; start += batchSize) {
      final List<String> batch = ids.sublist(start, (start + batchSize).clamp(0, ids.length));
      final Map<String, DownloadVerdict>? verdicts = (await _repository.validateDownloads(
        batch,
      )).fold(success: (v) => v, failure: (_) => null);
      if (verdicts == null) {
        // No answer is not "invalid": stop and keep everything as it is.
        return RevalidationReport(expired: expired, validated: validated, removed: removed);
      }
      for (final String id in batch) {
        final DownloadVerdict? verdict = verdicts[id];
        if (verdict == null) continue; // not answered → leave it alone
        try {
          if (verdict.isValid) {
            await _service.markValidated(id);
            validated.add(id);
          } else if (verdict.isRevoked) {
            await _service.deleteLesson(id);
            removed.add(id);
          }
        } catch (_) {
          // One lesson's local failure must not abort the rest.
        }
      }
    }
    _lastServerPass = clock();
    return RevalidationReport(expired: expired, validated: validated, removed: removed, reachedServer: true);
  }
}
