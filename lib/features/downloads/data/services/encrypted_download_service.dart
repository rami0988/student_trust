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

/// Handles downloading lesson videos, encrypting them at rest with a
/// per-(student, device, lesson) AES-256 key, and decrypting them on demand
/// into a short-lived temp file for playback.
///
/// Security model:
///  * The encryption key is *derived*, never stored. It is bound to the
///    student id, the device UUID and the lesson id, so encrypted chunks
///    copied to another device (or another account) cannot be decrypted.
///  * A 7-day online re-validation window is enforced via Hive metadata.
@lazySingleton
class EncryptedDownloadService {
  static const String boxName = 'edushield_downloads';
  static const int _chunkSize = 2 * 1024 * 1024; // 2 MB
  static const String _partFileName = 'video.part';

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
  /// Returns how the attempt ended:
  ///  * [DownloadOutcome.completed] — fully downloaded and encrypted.
  ///  * [DownloadOutcome.paused] — interrupted by [pause]; the `.part` file is
  ///    kept so a later call resumes from where it stopped.
  ///  * [DownloadOutcome.canceled] — interrupted by [cancel]; all files removed.
  ///
  /// Real errors (network/disk) are rethrown.
  Future<DownloadOutcome> downloadLesson({
    required String lessonId,
    required String videoUrl,
    required String studentId,
    required String deviceUuid,
    required String accessToken,
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

    final Dio dio = Dio();
    IOSink? sink;
    try {
      // The lesson stream endpoint returns JSON `{ mode: 'bunnycdn',
      // directUrl, ... }` in production (the video itself lives on BunnyCDN).
      // Downloading that JSON as if it were the video produces an unplayable
      // file — resolve the real video URL first (same env-agnostic Range
      // probe the online player uses).
      final String resolvedUrl = await _resolveVideoUrl(dio, videoUrl, accessToken);

      int downloaded = partFile.existsSync() ? await partFile.length() : 0;

      final Map<String, dynamic> headers = <String, dynamic>{
        'Authorization': 'Bearer $accessToken',
        'ngrok-skip-browser-warning': 'true',
        // Required by the BunnyCDN pull zone (Referer allow-list); ignored by
        // the dev streaming endpoint.
        ...BunnyConstants.cdnHeaders,
      };
      // Resume: ask the server only for the bytes we don't have yet.
      if (downloaded > 0) headers['Range'] = 'bytes=$downloaded-';

      final Response<ResponseBody> response = await dio.get<ResponseBody>(
        resolvedUrl,
        options: Options(
          responseType: ResponseType.stream,
          headers: headers,
          // 416 = we already have the whole file; treat it as "done".
          validateStatus: (status) => status != null && (status < 400 || status == 416),
        ),
        cancelToken: token,
      );

      final int status = response.statusCode ?? 0;

      if (status != 416) {
        // Figure out the total size and whether the server honoured Range.
        int total;
        FileMode mode;
        if (status == 206) {
          total = _totalFromContentRange(response.headers) ?? (downloaded + _asInt(response.headers.value('content-length')));
          mode = FileMode.append;
        } else {
          // 200: server ignored Range (or a fresh download) → start over.
          downloaded = 0;
          total = _asInt(response.headers.value('content-length'));
          mode = FileMode.write;
        }

        sink = partFile.openWrite(mode: mode);
        await for (final Uint8List chunk in response.data!.stream) {
          sink.add(chunk);
          downloaded += chunk.length;
          if (total > 0) {
            onProgress((downloaded / total * 0.85).clamp(0.0, 0.85));
          }
        }
        await sink.close();
        sink = null;
      }

      // Guard: if the server replied with JSON (e.g. an error body or an
      // unresolved bunnycdn envelope), the .part is not a video — storing it
      // would produce an "unplayable" download. Fail loudly instead.
      if (await _looksLikeJson(partFile)) {
        try {
          await partFile.delete();
        } catch (_) {}
        throw Exception('Couldn\'t download the video — please try again');
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
      // render a proper list without any network call).
      await _box.put(lessonId, {
        'lessonId': lessonId,
        'title': title,
        'durationSeconds': durationSeconds,
        'chunkCount': chunkIndex,
        'isComplete': true,
        'downloadedAt': DateTime.now().toIso8601String(),
        'studentId': studentId,
        'deviceUuid': deviceUuid,
        'lastValidatedAt': DateTime.now().toIso8601String(),
        if (thumbPath != null) 'thumbPath': thumbPath,
      });

      onProgress(1.0);
      _tokens.remove(lessonId);
      return DownloadOutcome.completed;
    } on DioException catch (e) {
      try {
        await sink?.close();
      } catch (_) {}
      _tokens.remove(lessonId);
      if (CancelToken.isCancel(e)) {
        if (_canceling.remove(lessonId)) {
          await deleteLesson(lessonId); // drop the partial download entirely
          return DownloadOutcome.canceled;
        }
        _pausing.remove(lessonId);
        return DownloadOutcome.paused; // keep the .part for a later resume
      }
      rethrow;
    } catch (_) {
      try {
        await sink?.close();
      } catch (_) {}
      _tokens.remove(lessonId);
      rethrow;
    }
  }

  /// Resolves the real video URL for a lesson stream endpoint.
  ///
  /// Same env-agnostic detection as the online player: request a tiny range.
  /// The production backend ignores it and returns JSON `{ mode: 'bunnycdn',
  /// directUrl, ... }` → download from [directUrl]. The development backend
  /// replies with a 206 video chunk → download from [videoUrl] itself.
  /// Any probe failure falls back to [videoUrl] (the main request will then
  /// surface the real error).
  Future<String> _resolveVideoUrl(Dio dio, String videoUrl, String accessToken) async {
    try {
      final Response<dynamic> res = await dio.get<dynamic>(
        videoUrl,
        options: Options(
          responseType: ResponseType.json,
          headers: {'Authorization': 'Bearer $accessToken', 'ngrok-skip-browser-warning': 'true', 'Range': 'bytes=0-1'},
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
    } catch (_) {
      // Fall through — treat the endpoint as a direct byte stream.
    }
    return videoUrl;
  }

  /// Downloads the lesson thumbnail into the lesson dir (plain jpg — small
  /// and not sensitive). Best effort: any failure just means the offline page
  /// falls back to a placeholder. Returns the local path, or null.
  Future<String?> _cacheThumbnail(Dio dio, Directory lessonDir, String? thumbnailUrl, String accessToken) async {
    if (thumbnailUrl == null || thumbnailUrl.isEmpty) return null;
    try {
      final String path = '${lessonDir.path}/thumb.jpg';
      await dio.download(
        thumbnailUrl,
        path,
        options: Options(
          headers: {'Authorization': 'Bearer $accessToken', 'ngrok-skip-browser-warning': 'true', ...BunnyConstants.cdnHeaders},
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
    await partFile.delete();
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
    final Directory lessonDir = await _getLessonDir(lessonId);
    final int chunkCount = meta['chunkCount'] as int;

    final IOSink sink = tempFile.openWrite();
    for (int i = 0; i < chunkCount; i++) {
      final Uint8List encryptedBytes = await File('${lessonDir.path}/chunk_$i.enc').readAsBytes();
      final List<int> decrypted = encrypter.decryptBytes(Encrypted(encryptedBytes), iv: iv);
      sink.add(decrypted);
    }
    await sink.close();

    return tempFile.path;
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

  Future<void> deleteLesson(String lessonId) async {
    final Directory lessonDir = await _getLessonDir(lessonId);
    if (lessonDir.existsSync()) lessonDir.deleteSync(recursive: true);
    await _box.delete(lessonId);

    // Also drop any leftover decrypted temp file.
    final Directory cacheDir = await getTemporaryDirectory();
    final File tempFile = File('${cacheDir.path}/play_$lessonId.mp4');
    if (tempFile.existsSync()) tempFile.deleteSync();
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
    );
  }
}
