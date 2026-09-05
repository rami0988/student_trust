import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';
import 'package:encrypt/encrypt.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:injectable/injectable.dart';
import 'package:path_provider/path_provider.dart';

import '../../../../core/network/endpoints.dart';
import '../../domain/entities/downloaded_lesson_info.dart';

/// Result of a (possibly interrupted) download attempt.
enum DownloadOutcome { completed, paused, canceled }

/// Raised when a transfer ended but fewer bytes are on disk than the server
/// said it would send. Its own type so the caller can say "the file is
/// incomplete, try again" instead of surfacing a raw network error — this is
/// the failure that used to silently produce a "downloaded" lesson that
/// wouldn't play.
class IncompleteDownloadException implements Exception {
  final int expected;
  final int actual;
  const IncompleteDownloadException(this.expected, this.actual);

  @override
  String toString() => 'IncompleteDownloadException(expected: $expected, actual: $actual)';
}

/// Raised when the lesson's video is still being encoded by BunnyCDN. Not a
/// failure the student can retry away — it resolves on its own, so it gets its
/// own type and its own "try again shortly" message instead of a generic
/// download error.
class VideoProcessingException implements Exception {
  const VideoProcessingException();

  @override
  String toString() => 'VideoProcessingException';
}

/// Handles downloading lesson videos, encrypting them at rest with a
/// per-(student, device, lesson) AES-256 key, and decrypting them on demand
/// into a short-lived temp file for playback.
///
/// Security model:
///  * The encryption key is *derived*, never stored. It is bound to the
///    student id, the device UUID and the lesson id, so encrypted chunks
///    copied to another device (or another account) cannot be decrypted.
///  * A 7-day online re-validation window is enforced via Hive metadata.
///
/// Integrity model — why "completed" can be trusted:
///  * The server-advertised total size (and ETag when offered) is recorded in
///    a sidecar next to the `.part` file. A resume only appends while that
///    fingerprint still matches, so a re-signed URL that resolves to a
///    different rendition can never be spliced onto the old bytes.
///  * After transferring, the byte count on disk must equal that total. A
///    connection dropping mid-stream ends the `await for` loop exactly like a
///    successful transfer does — without this check a truncated file would be
///    encrypted and marked complete.
///  * `isComplete: true` is written only after both the size check and the
///    encryption pass succeed, so metadata never advertises a file that isn't
///    fully on disk.
@lazySingleton
class EncryptedDownloadService {
  static const String boxName = 'edushield_downloads';
  static const int _chunkSize = 2 * 1024 * 1024; // 2 MB
  static const String _partFileName = 'video.part';

  /// Sidecar holding the server fingerprint (total size + ETag) of whatever
  /// the `.part` file is a prefix of. Without it, a resume is a guess.
  static const String _metaFileName = 'video.part.json';

  /// Transient network failures are retried in place (resuming by range)
  /// before the download is reported as failed — a weak connection that drops
  /// every few MB would otherwise never finish a large lesson.
  static const int _maxRetries = 4;
  static const Duration _connectTimeout = Duration(seconds: 30);

  /// Kills a stalled transfer: no bytes for this long and the request is
  /// aborted so the retry loop can resume it, instead of hanging forever on a
  /// half-open socket (which never errors on its own).
  static const Duration _receiveTimeout = Duration(seconds: 60);

  Box get _box => Hive.box(boxName);

  // Active downloads keyed by lessonId, plus the intent behind a cancellation
  // so the running loop can tell "pause" (keep the .part) from "cancel"
  // (delete everything).
  final Map<String, CancelToken> _tokens = {};
  final Set<String> _pausing = {};
  final Set<String> _canceling = {};

  // --- Key derivation -------------------------------------------------------

  Key _deriveKey(String studentId, String deviceUuid, String lessonId) {
    final String input = '$studentId:$deviceUuid:$lessonId';
    final List<int> bytes = sha256.convert(utf8.encode(input)).bytes;
    return Key(Uint8List.fromList(bytes)); // 32 bytes => AES-256
  }

  IV _deriveIV(String lessonId, String studentId) {
    final String input = '$lessonId:$studentId';
    final List<int> bytes = sha256.convert(utf8.encode(input)).bytes;
    return IV(Uint8List.fromList(bytes.sublist(0, 16)));
  }

  // --- Paths ----------------------------------------------------------------

  Future<Directory> _getLessonDir(String lessonId) async {
    final Directory appDir = await getApplicationDocumentsDirectory();
    final Directory dir = Directory('${appDir.path}/edushield_videos/$lessonId');
    if (!dir.existsSync()) dir.createSync(recursive: true);
    return dir;
  }

  // --- Download + encrypt ---------------------------------------------------

  /// Downloads a lesson video (resuming from a partial `.part` file when
  /// possible) then encrypts it into AES chunks. Streams bytes straight to
  /// disk — the whole video is never held in RAM.
  ///
  /// [accessToken] is a *provider*, not a string: an access token lives 15
  /// minutes while a large lesson on mobile data takes longer than that, so a
  /// token captured once at the start is already expired by the time the
  /// transfer needs it. It is re-read before every attempt, and the callers'
  /// Dio refreshes it when it has lapsed.
  ///
  /// Returns how the attempt ended:
  ///  * [DownloadOutcome.completed] — fully downloaded, verified and encrypted.
  ///  * [DownloadOutcome.paused] — interrupted by [pause]; the `.part` file is
  ///    kept so a later call resumes from where it stopped.
  ///  * [DownloadOutcome.canceled] — interrupted by [cancel]; all files removed.
  ///
  /// Real errors (network/disk) are rethrown after [_maxRetries] attempts.
  Future<DownloadOutcome> downloadLesson({
    required String lessonId,
    required String videoUrl,
    required String studentId,
    required String deviceUuid,
    required Future<String> Function() accessToken,
    required void Function(double) onProgress,
    String title = '',
    int durationSeconds = 0,
    String? thumbnailUrl,
  }) async {
    final Directory lessonDir = await _getLessonDir(lessonId);
    final File partFile = File('${lessonDir.path}/$_partFileName');

    final CancelToken token = CancelToken();
    _tokens[lessonId] = token;
    _pausing.remove(lessonId);
    _canceling.remove(lessonId);

    // A previously-complete lesson being re-downloaded must not stay flagged
    // as playable while its chunks are mid-rewrite.
    await _markIncomplete(lessonId);

    final Dio dio = Dio(BaseOptions(connectTimeout: _connectTimeout, receiveTimeout: _receiveTimeout));

    try {
      // The lesson stream endpoint returns JSON `{ mode: 'bunnycdn',
      // directUrl, ... }` in production (the video itself lives on BunnyCDN).
      // Downloading that JSON as if it were the video produces an unplayable
      // file — resolve the real video URL first (same env-agnostic Range
      // probe the online player uses).
      // Transfer with in-place retries. Each attempt resumes from whatever is
      // already on disk, so a flaky connection makes forward progress instead
      // of restarting from zero. The URL is resolved through a callback rather
      // than once up front: a BunnyCDN signature expires, and when it does the
      // retry loop asks for a fresh one instead of hammering a dead link.
      final int total = await _transferWithRetries(
        dio: dio,
        resolveUrl: () => _resolveVideoUrl(dio, videoUrl, accessToken, deviceUuid),
        accessToken: accessToken,
        partFile: partFile,
        lessonDir: lessonDir,
        token: token,
        onProgress: onProgress,
      );

      // A pause that landed while the transfer was unwinding must not fall
      // through to the integrity checks below: they exist to judge a *finished*
      // transfer, and both react to a short file by deleting it. A paused
      // download is short on purpose, and its whole point is that the bytes
      // survive for the resume.
      if (token.isCancelled && !_canceling.contains(lessonId)) {
        _tokens.remove(lessonId);
        _pausing.remove(lessonId);
        return DownloadOutcome.paused;
      }

      // Guard: if the server replied with JSON (e.g. an error body or an
      // unresolved bunnycdn envelope), the .part is not a video — storing it
      // would produce an "unplayable" download. Fail loudly instead.
      if (await _looksLikeJson(partFile)) {
        await _discardPartial(lessonDir);
        throw Exception('Couldn\'t download the video — please try again');
      }

      // Integrity gate. A dropped stream ends the read loop exactly like a
      // completed one, so without comparing against the advertised size a
      // truncated file would be encrypted and marked complete.
      final int actual = await partFile.length();
      if (total > 0 && actual != total) {
        await _discardPartial(lessonDir);
        throw IncompleteDownloadException(total, actual);
      }

      // Download finished — encrypt the .part file into AES chunks on disk.
      final int chunkIndex = await _encryptPartFile(
        lessonId: lessonId,
        partFile: partFile,
        lessonDir: lessonDir,
        studentId: studentId,
        deviceUuid: deviceUuid,
        onProgress: onProgress,
      );

      // Cache the lesson thumbnail next to the chunks (best effort, tiny and
      // not sensitive) so the offline page can show it without any network.
      final String? thumbPath = await _cacheThumbnail(dio, lessonDir, thumbnailUrl, accessToken);

      // Save metadata to Hive (display fields included so the offline page can
      // render a proper list without any network call). `isComplete` is set
      // only here — after the size check AND the encryption pass — so the flag
      // can never advertise a file that isn't fully on disk.
      await _box.put(lessonId, {
        'lessonId': lessonId,
        'title': title,
        'durationSeconds': durationSeconds,
        'chunkCount': chunkIndex,
        'sizeBytes': actual,
        'isComplete': true,
        'downloadedAt': DateTime.now().toIso8601String(),
        'studentId': studentId,
        'deviceUuid': deviceUuid,
        'lastValidatedAt': DateTime.now().toIso8601String(),
        'thumbPath': ?thumbPath,
      });

      onProgress(1.0);
      _tokens.remove(lessonId);
      return DownloadOutcome.completed;
    } on DioException catch (e) {
      _tokens.remove(lessonId);
      if (CancelToken.isCancel(e)) {
        if (_canceling.remove(lessonId)) {
          _pausing.remove(lessonId);
          await deleteLesson(lessonId); // drop the partial download entirely
          return DownloadOutcome.canceled;
        }
        _pausing.remove(lessonId);
        return DownloadOutcome.paused; // keep the .part for a later resume
      }
      rethrow;
    } catch (_) {
      _tokens.remove(lessonId);
      _pausing.remove(lessonId);
      _canceling.remove(lessonId);
      rethrow;
    }
  }

  /// Runs the byte transfer, retrying transient failures with backoff.
  ///
  /// Each attempt resumes from the current `.part` length, so a connection
  /// that dies every few MB still converges instead of restarting. A pause or
  /// cancel propagates immediately (never retried). Returns the server's
  /// advertised total size, or 0 when the server didn't advertise one.
  ///
  /// ## Expiry recovery
  ///
  /// A download outlives its own credentials. The BunnyCDN signature and the
  /// access token both expire on a clock that keeps running during a slow
  /// transfer — and during a pause, which can last days. Treating the
  /// resulting 401/403 as fatal is what made large downloads fail outright and
  /// left a paused download permanently unresumable.
  ///
  /// So an auth failure buys exactly one recovery: re-resolve the URL (which
  /// re-signs it and mints a fresh token) and try again from the same byte
  /// offset. Once, not per attempt — if a *freshly issued* credential is also
  /// rejected, the problem is access, not staleness, and retrying can't fix
  /// it. 404 stays fatal: the lesson is gone.
  Future<int> _transferWithRetries({
    required Dio dio,
    required Future<String> Function() resolveUrl,
    required Future<String> Function() accessToken,
    required File partFile,
    required Directory lessonDir,
    required CancelToken token,
    required void Function(double) onProgress,
  }) async {
    Object? lastError;
    String? url;
    bool renewedAuth = false;

    for (int attempt = 0; attempt <= _maxRetries; attempt++) {
      // A pause raised between attempts must stop the ladder here. Starting
      // another attempt would re-request without a usable Range and take the
      // "server ignored Range → start over" branch, which deletes the very
      // bytes the pause was meant to preserve.
      if (token.isCancelled) {
        throw DioException.requestCancelled(requestOptions: RequestOptions(path: url ?? ''), reason: null);
      }
      try {
        // Resolved lazily so the very first attempt and any post-expiry retry
        // go through the same path.
        final String activeUrl = url ??= await resolveUrl();
        return await _transferOnce(
          dio: dio,
          url: activeUrl,
          accessToken: await accessToken(),
          partFile: partFile,
          lessonDir: lessonDir,
          token: token,
          onProgress: onProgress,
        );
      } on VideoProcessingException {
        // Not a transfer failure at all — the video isn't encoded yet. Retrying
        // can't help, and the student needs the real reason.
        rethrow;
      } on DioException catch (e) {
        // A deliberate pause/cancel is not a failure — hand it straight up.
        if (CancelToken.isCancel(e)) rethrow;
        final int? code = e.response?.statusCode;
        if (code == 404) rethrow;
        if (code == 401 || code == 403) {
          // Credentials expired mid-transfer (or during a long pause). Re-resolve
          // to re-sign the URL and mint a fresh token, then retry from the same
          // byte offset — once. If freshly issued credentials are refused too,
          // this is a real access failure and no amount of retrying fixes it.
          if (renewedAuth) rethrow;
          renewedAuth = true;
          url = null; // force a re-resolve (and so a re-signed CDN URL)
          // Doesn't consume an attempt: this retry is instant and deterministic,
          // unlike the backoff ladder, which exists for congestion. Spending a
          // network retry here would shorten the budget for the real thing.
          attempt--;
          continue;
        }
        lastError = e;
      } on IncompleteDownloadException catch (e) {
        // Server closed early. The next attempt resumes from what we have.
        lastError = e;
      } on HttpException catch (e) {
        // A socket dying mid-body surfaces raw from the response stream (Dio
        // only wraps errors it raises itself), so it has to be caught by type
        // here or the whole retry ladder is bypassed.
        lastError = e;
      } on SocketException catch (e) {
        lastError = e;
      } on TlsException catch (e) {
        lastError = e;
      }

      // Checked FIRST, before both the backoff and the attempt ceiling.
      //
      // A pause cancels the token, but the failure that actually surfaces from
      // an aborted stream is usually a raw HttpException ("connection closed
      // before full header/body was received"), which the ladder above treats
      // as a retryable network blip. Two things then went wrong: the pause took
      // up to 16 seconds of backoff to be noticed, and — on the last attempt —
      // `break` skipped the cancel check entirely and threw `lastError`, an
      // IncompleteDownloadException. That is a *transfer* failure, so the size
      // gate in downloadLesson discarded the partial, and the student's paused
      // download silently restarted from zero on resume.
      //
      // Reporting the cancellation for what it is keeps the partial: the caller
      // maps it to DownloadOutcome.paused, which deliberately keeps the .part.
      if (token.isCancelled) {
        throw DioException.requestCancelled(requestOptions: RequestOptions(path: url ?? ''), reason: null);
      }
      if (attempt == _maxRetries) break;
      // Backoff: 2s, 4s, 8s, 16s — long enough for a phone switching between
      // Wi-Fi and mobile data to settle.
      await Future<void>.delayed(Duration(seconds: 2 << attempt));
      // And again after waiting, so a pause during the delay is honoured
      // immediately instead of starting another doomed attempt.
      if (token.isCancelled) {
        throw DioException.requestCancelled(requestOptions: RequestOptions(path: url ?? ''), reason: null);
      }
    }
    throw lastError!;
  }

  /// One transfer attempt. Appends to [partFile] when the server honours the
  /// resume range AND the partial's recorded fingerprint still matches;
  /// otherwise starts the file over. Returns the advertised total size.
  Future<int> _transferOnce({
    required Dio dio,
    required String url,
    required String accessToken,
    required File partFile,
    required Directory lessonDir,
    required CancelToken token,
    required void Function(double) onProgress,
  }) async {
    int downloaded = partFile.existsSync() ? await partFile.length() : 0;

    // Only resume onto a partial we can prove belongs to this exact remote
    // file. Without this, a re-signed URL pointing at a different rendition
    // gets appended onto the old bytes, producing a corrupt video that still
    // passes every "is the file there?" check.
    final Map<String, dynamic>? partMeta = await _readPartMeta(lessonDir);
    if (downloaded > 0 && partMeta == null) downloaded = 0;

    final Map<String, dynamic> headers = <String, dynamic>{
      'Authorization': 'Bearer $accessToken',
      'ngrok-skip-browser-warning': 'true',
      // Required by the BunnyCDN pull zone (Referer allow-list); ignored by
      // the dev streaming endpoint.
      ...BunnyConstants.cdnHeaders,
    };
    // Resume: ask the server only for the bytes we don't have yet.
    //
    // Deliberately WITHOUT `If-Range`. It looks like the stricter choice, but
    // against a CDN it is actively harmful: BunnyCDN serves the same file from
    // different edge nodes with different ETags, so a validator that changed
    // for reasons having nothing to do with the content makes the server send
    // 200, and the branch below then throws away a perfectly good partial and
    // restarts from zero — the student watches progress fall from 70% to 0.
    //
    // The recorded total in the sidecar is the honest check and is already
    // enforced on both the 206 and 416 paths below: a genuinely different
    // remote file has a different length, and that is what we compare.
    if (downloaded > 0) {
      headers['Range'] = 'bytes=$downloaded-';
    }

    final Response<ResponseBody> response = await dio.get<ResponseBody>(
      url,
      options: Options(
        responseType: ResponseType.stream,
        headers: headers,
        // 416 = we already have the whole file; treat it as "done".
        validateStatus: (status) => status != null && (status < 400 || status == 416),
      ),
      cancelToken: token,
    );

    final int status = response.statusCode ?? 0;

    // 416 means the server has nothing at or past our offset. Usually that's
    // "you already hold the whole file" — but it is equally what a *shrunken*
    // remote file looks like (a re-signed URL resolving to a smaller
    // rendition), and then our partial is longer than the real thing and is
    // not a prefix of it. The recorded total is the only way to tell the two
    // apart: when it doesn't match what's on disk, the partial is unusable, so
    // throw it away and restart rather than reporting a size the file doesn't
    // have.
    if (status == 416) {
      final int? knownTotal = partMeta?['total'] as int?;
      if (knownTotal != null && knownTotal == downloaded) return knownTotal;
      await _discardPartial(lessonDir);
      throw const IncompleteDownloadException(0, 0);
    }

    final String? etag = response.headers.value('etag');
    int total;
    FileMode mode;
    if (status == 206) {
      total = _totalFromContentRange(response.headers) ?? (downloaded + _asInt(response.headers.value('content-length')));
      // The server may honour Range but serve a *different* file than the one
      // our partial came from. Trust the recorded size over the request.
      final int? knownTotal = partMeta?['total'] as int?;
      if (knownTotal != null && total > 0 && knownTotal != total) {
        await _discardPartial(lessonDir);
        downloaded = 0;
        mode = FileMode.write;
      } else {
        mode = FileMode.append;
      }
    } else {
      // 200: server ignored Range (or this is a fresh download) → start over.
      // Drop the old bytes explicitly rather than relying on truncation, so
      // the stale fingerprint goes with them.
      if (downloaded > 0) await _discardPartial(lessonDir);
      downloaded = 0;
      total = _asInt(response.headers.value('content-length'));
      mode = FileMode.write;
    }

    // Record what this partial is a prefix of BEFORE writing any bytes — a
    // crash mid-transfer must not leave bytes with no fingerprint.
    await _writePartMeta(lessonDir, total: total, etag: etag);

    IOSink? sink = partFile.openWrite(mode: mode);
    try {
      await for (final Uint8List chunk in response.data!.stream) {
        sink.add(chunk);
        downloaded += chunk.length;
        if (total > 0) {
          onProgress((downloaded / total * 0.85).clamp(0.0, 0.85));
        }
      }
      // flush() before close() so the on-disk length is truthful even when the
      // very next thing that happens is a pause — the resume reads that length.
      await sink.flush();
      await sink.close();
      sink = null;
    } finally {
      if (sink != null) {
        // Salvage whatever was buffered so a resume starts from the real
        // offset instead of re-fetching bytes we already hold.
        try {
          await sink.flush();
        } catch (_) {}
        try {
          await sink.close();
        } catch (_) {}
      }
    }

    // A pause landing while the stream was draining leaves a short file that is
    // short *on purpose*. Reporting it as an incomplete transfer would send the
    // retry ladder around again, and that next attempt discards the partial —
    // so surface the cancellation instead, which the caller turns into
    // DownloadOutcome.paused and keeps the bytes for the resume.
    if (token.isCancelled) {
      throw DioException.requestCancelled(requestOptions: response.requestOptions, reason: null);
    }

    // The stream ended. If it ended short, the connection dropped — say so, so
    // the retry loop resumes instead of encrypting a truncated file.
    if (total > 0) {
      final int onDisk = await partFile.length();
      if (onDisk < total) throw IncompleteDownloadException(total, onDisk);
    }

    return total;
  }

  // --- Partial-download fingerprint ----------------------------------------

  Future<Map<String, dynamic>?> _readPartMeta(Directory lessonDir) async {
    final File f = File('${lessonDir.path}/$_metaFileName');
    if (!f.existsSync()) return null;
    try {
      final dynamic decoded = jsonDecode(await f.readAsString());
      return decoded is Map ? Map<String, dynamic>.from(decoded) : null;
    } catch (_) {
      return null;
    }
  }

  Future<void> _writePartMeta(Directory lessonDir, {required int total, String? etag}) async {
    try {
      await File(
        '${lessonDir.path}/$_metaFileName',
      ).writeAsString(jsonEncode({'total': total, 'etag': ?etag}));
    } catch (_) {
      // Losing the sidecar only costs a restart-from-zero on the next resume —
      // never worth failing an in-flight download over.
    }
  }

  /// Throws away a partial transfer (bytes + fingerprint) so the next attempt
  /// starts from a known-clean slate.
  Future<void> _discardPartial(Directory lessonDir) async {
    for (final String name in [_partFileName, _metaFileName]) {
      final File f = File('${lessonDir.path}/$name');
      try {
        if (f.existsSync()) await f.delete();
      } catch (_) {}
    }
  }

  /// Clears `isComplete` while a lesson is being (re)downloaded, so an
  /// interrupted re-download can't leave the old flag pointing at chunks that
  /// are mid-rewrite.
  Future<void> _markIncomplete(String lessonId) async {
    final Map? meta = _box.get(lessonId) as Map?;
    if (meta == null || meta['isComplete'] != true) return;
    final Map<String, dynamic> updated = Map<String, dynamic>.from(meta);
    updated['isComplete'] = false;
    await _box.put(lessonId, updated);
  }

  /// Resolves the real video URL for a lesson stream endpoint.
  ///
  /// Same env-agnostic detection as the online player: request a tiny range.
  /// The production backend ignores it and returns JSON `{ mode: 'bunnycdn',
  /// directUrl, ... }` → download from [directUrl]. The development backend
  /// replies with a 206 video chunk → download from [videoUrl] itself.
  ///
  /// `forDownload=1` asks the backend to sign the CDN URL for hours instead of
  /// the 15 minutes playback uses — a download is one long transfer that can't
  /// silently re-resolve mid-stream the way the player can.
  ///
  /// A probe failure falls back to [videoUrl] so the main request surfaces the
  /// real error — except for 409 VIDEO_PROCESSING, which is a definite answer
  /// ("not encoded yet"), not a probe failure, and is rethrown so the student
  /// is told to wait rather than shown a generic download error.
  Future<String> _resolveVideoUrl(Dio dio, String videoUrl, Future<String> Function() accessToken, String deviceUuid) async {
    final String token = await accessToken();
    try {
      final Response<dynamic> res = await dio.get<dynamic>(
        _withDownloadFlag(videoUrl),
        options: Options(
          responseType: ResponseType.json,
          headers: {
            'Authorization': 'Bearer $token',
            'ngrok-skip-browser-warning': 'true',
            'Range': 'bytes=0-1',
            // This service runs on its own Dio (no app interceptors), so the
            // device header the backend now enforces has to be set by hand.
            'X-Device-ID': deviceUuid,
          },
          validateStatus: (status) => status != null && status < 400,
        ),
      );
      dynamic data = res.data;
      if (data is String && data.trim().startsWith('{')) {
        try {
          data = jsonDecode(data);
        } catch (_) {}
      }
      if (data is Map && data['mode'] == 'bunnycdn' && data['directUrl'] != null) {
        return data['directUrl'].toString();
      }
    } on DioException catch (e) {
      // 409 = Bunny is still encoding. Downloading anyway just fetches the
      // error envelope and reports "couldn't download the video", hiding the
      // one thing the student needs to know: wait and try again.
      if (e.response?.statusCode == 409) {
        throw const VideoProcessingException();
      }
      // Anything else: fall through and let the real transfer surface it.
    } catch (_) {
      // Fall through — treat the endpoint as a direct byte stream.
    }
    return videoUrl;
  }

  /// Adds `forDownload=1` so the backend signs a long-lived CDN URL. Appended
  /// with the right separator — the stream endpoint may already carry a query
  /// string (worksheet solution videos do).
  String _withDownloadFlag(String url) {
    if (url.contains('forDownload=')) return url;
    return url.contains('?') ? '$url&forDownload=1' : '$url?forDownload=1';
  }

  /// Downloads the lesson thumbnail into the lesson dir (plain jpg — small
  /// and not sensitive). Best effort: any failure just means the offline page
  /// falls back to a placeholder. Returns the local path, or null.
  Future<String?> _cacheThumbnail(Dio dio, Directory lessonDir, String? thumbnailUrl, Future<String> Function() accessToken) async {
    if (thumbnailUrl == null || thumbnailUrl.isEmpty) return null;
    try {
      final String path = '${lessonDir.path}/thumb.jpg';
      await dio.download(
        thumbnailUrl,
        path,
        options: Options(
          headers: {'Authorization': 'Bearer ${await accessToken()}', 'ngrok-skip-browser-warning': 'true', ...BunnyConstants.cdnHeaders},
        ),
      );
      return path;
    } catch (_) {
      return null;
    }
  }

  /// True when [file] starts with a JSON opener (`{` or `[`) — used to detect
  /// a non-video body saved as `.part`.
  Future<bool> _looksLikeJson(File file) async {
    if (!file.existsSync() || await file.length() == 0) return true;
    final RandomAccessFile raf = await file.open();
    try {
      final Uint8List head = await raf.read(1);
      final int b = head.isEmpty ? 0 : head[0];
      return b == 0x7B || b == 0x5B; // '{' or '['
    } finally {
      await raf.close();
    }
  }

  /// Encrypts the fully-downloaded `.part` file into fixed-size AES chunks,
  /// reading it back in [_chunkSize] pieces so it's never fully buffered.
  /// Returns the number of chunks written.
  Future<int> _encryptPartFile({
    required String lessonId,
    required File partFile,
    required Directory lessonDir,
    required String studentId,
    required String deviceUuid,
    required void Function(double) onProgress,
  }) async {
    final Key key = _deriveKey(studentId, deviceUuid, lessonId);
    final IV iv = _deriveIV(lessonId, studentId);
    final Encrypter encrypter = Encrypter(AES(key, mode: AESMode.cbc));

    // Clear any stale chunks from a previous (interrupted) attempt.
    for (final FileSystemEntity f in lessonDir.listSync()) {
      if (f is File && f.path.endsWith('.enc')) f.deleteSync();
    }

    final int length = await partFile.length();
    final RandomAccessFile raf = await partFile.open();
    int index = 0;
    int pos = 0;
    try {
      while (pos < length) {
        final int size = (pos + _chunkSize < length) ? _chunkSize : length - pos;
        final Uint8List bytes = await raf.read(size);
        final Encrypted encrypted = encrypter.encryptBytes(bytes, iv: iv);
        await File('${lessonDir.path}/chunk_$index.enc').writeAsBytes(encrypted.bytes);
        index++;
        pos += size;
        onProgress((0.85 + (pos / length) * 0.15).clamp(0.85, 1.0));
      }
    } finally {
      await raf.close();
    }
    // The partial is fully consumed — drop it and its now-meaningless sidecar.
    await _discardPartial(lessonDir);
    return index;
  }

  int? _totalFromContentRange(Headers headers) {
    // Content-Range: "bytes start-end/total"
    final String? cr = headers.value('content-range');
    if (cr == null) return null;
    final int slash = cr.lastIndexOf('/');
    if (slash < 0) return null;
    return int.tryParse(cr.substring(slash + 1).trim());
  }

  int _asInt(String? v) => int.tryParse(v ?? '') ?? 0;

  // --- Download controls ----------------------------------------------------

  /// Whether a download loop is currently running for [lessonId].
  bool isActive(String lessonId) => _tokens.containsKey(lessonId);

  /// Pauses an active download. The running [downloadLesson] future resolves
  /// to [DownloadOutcome.paused] and the `.part` file is kept for resuming.
  void pause(String lessonId) {
    if (!_tokens.containsKey(lessonId)) return;
    _pausing.add(lessonId);
    _tokens[lessonId]?.cancel('pause');
  }

  /// Cancels a download. If one is running the loop cleans up; otherwise the
  /// caller should remove any leftover partial via [deleteLesson].
  void cancel(String lessonId) {
    if (!_tokens.containsKey(lessonId)) return;
    _canceling.add(lessonId);
    _tokens[lessonId]?.cancel('cancel');
  }

  // --- Decrypt for playback -------------------------------------------------

  Future<String> getOfflineVideoPath({required String lessonId, required String studentId, required String deviceUuid}) async {
    // Check metadata.
    final Map? meta = _box.get(lessonId) as Map?;
    if (meta == null || meta['isComplete'] != true) {
      throw Exception('Lesson not downloaded');
    }

    // Check 7-day validation window.
    final DateTime lastValidated = DateTime.parse(meta['lastValidatedAt'] as String);
    if (DateTime.now().difference(lastValidated).inDays > 7) {
      throw Exception('VALIDATION_REQUIRED'); // caller tries online validation
    }

    final Directory lessonDir = await _getLessonDir(lessonId);
    final int chunkCount = meta['chunkCount'] as int;

    // Verify every chunk is still on disk before decrypting. A storage
    // cleaner, an OS purge, or a failed re-download can remove files behind
    // our back; catching it here turns an opaque mid-playback crash into a
    // clear "this download is damaged, get it again".
    if (!await _chunksIntact(lessonDir, chunkCount)) {
      await markDamaged(lessonId);
      throw Exception('DOWNLOAD_CORRUPTED');
    }

    // Reuse a recently decrypted temp file if present (< 2 hours old).
    final Directory cacheDir = await getTemporaryDirectory();
    final File tempFile = File('${cacheDir.path}/play_$lessonId.mp4');
    if (tempFile.existsSync()) {
      final Duration age = DateTime.now().difference(tempFile.lastModifiedSync());
      if (age.inHours < 2) return tempFile.path;
    }

    // Decrypt chunks into the temp file.
    final Key key = _deriveKey(studentId, deviceUuid, lessonId);
    final IV iv = _deriveIV(lessonId, studentId);
    final Encrypter encrypter = Encrypter(AES(key, mode: AESMode.cbc));

    final IOSink sink = tempFile.openWrite();
    try {
      for (int i = 0; i < chunkCount; i++) {
        final Uint8List encryptedBytes = await File('${lessonDir.path}/chunk_$i.enc').readAsBytes();
        final List<int> decrypted = encrypter.decryptBytes(Encrypted(encryptedBytes), iv: iv);
        sink.add(decrypted);
      }
      await sink.flush();
      await sink.close();
    } catch (_) {
      try {
        await sink.close();
      } catch (_) {}
      // A half-written temp file would be picked up by the 2-hour reuse check
      // above on the next attempt and played as a truncated video.
      try {
        if (tempFile.existsSync()) await tempFile.delete();
      } catch (_) {}
      // Decryption failing on files that are all present means the bytes
      // themselves are bad.
      await markDamaged(lessonId);
      throw Exception('DOWNLOAD_CORRUPTED');
    }

    return tempFile.path;
  }

  /// True when chunk_0..chunk_[count-1] all exist and are non-empty.
  Future<bool> _chunksIntact(Directory lessonDir, int count) async {
    if (count <= 0) return false;
    for (int i = 0; i < count; i++) {
      final File f = File('${lessonDir.path}/chunk_$i.enc');
      if (!f.existsSync()) return false;
      if (await f.length() == 0) return false;
    }
    return true;
  }

  // --- Maintenance ----------------------------------------------------------

  /// Marks the lesson as re-validated (called after a successful online check).
  Future<void> markValidated(String lessonId) async {
    final Map? meta = _box.get(lessonId) as Map?;
    if (meta == null) return;
    final Map<String, dynamic> updated = Map<String, dynamic>.from(meta);
    updated['lastValidatedAt'] = DateTime.now().toIso8601String();
    await _box.put(lessonId, updated);
  }

  /// Drops a download that turned out to be unusable, so the UI stops
  /// offering it as playable and shows the download action again.
  Future<void> markDamaged(String lessonId) => deleteLesson(lessonId);

  /// Reclaims disk from an interrupted session and repairs inconsistent
  /// metadata. Called once at startup, before any screen reads the store.
  ///
  /// Covers the three states an app kill can leave behind:
  ///  * metadata says complete but the chunks are gone/empty → drop it, so it
  ///    isn't offered for playback and then fails;
  ///  * metadata says incomplete (killed mid-download) → drop the entry and
  ///    its partial, so the lesson simply shows as not-downloaded;
  ///  * a lesson directory on disk with no metadata at all (killed before the
  ///    first Hive write) → delete the orphaned bytes.
  ///
  /// Returns how many entries were repaired.
  Future<int> reconcileOnStartup() async {
    // 1. Metadata-driven pass.
    final List<String> damaged = [];
    for (final dynamic value in _box.values.toList()) {
      if (value is! Map) continue;
      final String lessonId = (value['lessonId'] ?? '').toString();
      if (lessonId.isEmpty) continue;

      if (value['isComplete'] != true) {
        damaged.add(lessonId); // interrupted mid-download
        continue;
      }
      final Directory dir = await _getLessonDir(lessonId);
      final int chunkCount = value['chunkCount'] is int ? value['chunkCount'] as int : 0;
      if (!await _chunksIntact(dir, chunkCount)) damaged.add(lessonId);
    }
    for (final String lessonId in damaged) {
      try {
        await deleteLesson(lessonId);
      } catch (_) {}
    }

    // 2. Orphaned directories with no Hive entry at all.
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final Directory root = Directory('${appDir.path}/edushield_videos');
      if (!root.existsSync()) return damaged.length;
      for (final FileSystemEntity entity in root.listSync()) {
        if (entity is! Directory) continue;
        final String lessonId = entity.uri.pathSegments.where((s) => s.isNotEmpty).last;
        if (_box.get(lessonId) != null) continue;
        try {
          entity.deleteSync(recursive: true);
        } catch (_) {}
      }
    } catch (_) {
      // Storage enumeration is best effort — never block app start on it.
    }
    return damaged.length;
  }

  Future<void> deleteLesson(String lessonId) async {
    final Directory lessonDir = await _getLessonDir(lessonId);
    if (lessonDir.existsSync()) lessonDir.deleteSync(recursive: true);
    await _box.delete(lessonId);

    // Also drop any leftover decrypted temp file.
    final Directory cacheDir = await getTemporaryDirectory();
    final File tempFile = File('${cacheDir.path}/play_$lessonId.mp4');
    if (tempFile.existsSync()) tempFile.deleteSync();
  }

  /// Deletes every downloaded lesson. Returns how many were removed.
  Future<int> deleteAll() async {
    final List<String> ids = getDownloadedLessons().map((l) => l.lessonId).toList();
    for (final String id in ids) {
      try {
        await deleteLesson(id);
      } catch (_) {}
    }
    return ids.length;
  }

  /// Deletes the decrypted temp file for a lesson (called when leaving the
  /// player) so the plaintext video never lingers on disk.
  Future<void> clearTempFile(String lessonId) async {
    final Directory cacheDir = await getTemporaryDirectory();
    final File tempFile = File('${cacheDir.path}/play_$lessonId.mp4');
    if (tempFile.existsSync()) tempFile.deleteSync();
  }

  bool isDownloaded(String lessonId) {
    final Map? meta = _box.get(lessonId) as Map?;
    return meta != null && meta['isComplete'] == true;
  }

  int? chunkCount(String lessonId) {
    final Map? meta = _box.get(lessonId) as Map?;
    return meta == null ? null : meta['chunkCount'] as int?;
  }

  /// Total bytes held by all completed downloads — the "storage used" figure
  /// on the downloads screen.
  int totalBytesUsed() {
    int sum = 0;
    for (final dynamic value in _box.values) {
      if (value is! Map || value['isComplete'] != true) continue;
      final dynamic size = value['sizeBytes'];
      if (size is int) sum += size;
    }
    return sum;
  }

  /// All completed downloads, newest first — drives the offline page entirely
  /// from local Hive metadata (no network needed).
  List<DownloadedLessonInfo> getDownloadedLessons() {
    final List<DownloadedLessonInfo> items = _box.values.whereType<Map>().where((m) => m['isComplete'] == true).map(_infoFromMeta).toList();
    items.sort((a, b) {
      final DateTime ad = a.downloadedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      final DateTime bd = b.downloadedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
      return bd.compareTo(ad);
    });
    return items;
  }

  DownloadedLessonInfo _infoFromMeta(Map meta) {
    final String? thumb = meta['thumbPath']?.toString();
    return DownloadedLessonInfo(
      lessonId: (meta['lessonId'] ?? '').toString(),
      title: (meta['title'] ?? '').toString(),
      durationSeconds: meta['durationSeconds'] is int ? meta['durationSeconds'] as int : int.tryParse('${meta['durationSeconds']}') ?? 0,
      downloadedAt: DateTime.tryParse('${meta['downloadedAt']}'),
      thumbPath: (thumb == null || thumb.isEmpty) ? null : thumb,
      sizeBytes: meta['sizeBytes'] is int ? meta['sizeBytes'] as int : 0,
    );
  }
}
