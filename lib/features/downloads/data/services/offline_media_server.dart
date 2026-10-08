import 'dart:async';
import 'dart:collection';
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:injectable/injectable.dart';

import 'offline_crypto.dart';
import 'offline_decrypt_worker.dart';

/// A loopback HTTP server that streams downloaded lessons to the video player,
/// decrypting on the fly.
///
/// Replaces "decrypt the whole lesson into a plaintext temp file, then play
/// it", which meant a long wait before playback started and a full unencrypted
/// copy of the video sitting in the cache directory for as long as it played.
/// Now only the chunks a request touches are decrypted, in a background
/// isolate, and plaintext exists only in memory.
///
/// ## Security
///  * Bound to `127.0.0.1` only — unreachable from the network.
///  * Every request must carry this session's random token; other apps on the
///    device can reach a loopback port but can't guess 256 random bits.
///  * Only lessons currently registered for playback are served; a valid token
///    is not a key to the whole library.
///  * The server (and its token) stops as soon as nothing is playing.
///
/// ## HTTP
/// `GET`/`HEAD` `/<lessonId>.mp4?token=…` with single-range support
/// (`bytes=a-b`, `bytes=a-`, `bytes=-n`): 206 with `Content-Range`, 200 for a
/// full read, 416 for an unsatisfiable range. The `.mp4` suffix helps iOS's
/// AVPlayer pick the container; ExoPlayer sniffs content regardless.
@lazySingleton
class OfflineMediaServer {
  OfflineMediaServer();

  HttpServer? _server;
  OfflineDecryptWorker? _worker;
  Future<void>? _starting;
  String _token = '';

  final Map<String, OfflinePlaybackSource> _sources = {};
  final _ChunkCache _cache = _ChunkCache(maxEntries: 6);
  final Map<String, Future<Uint8List>> _inFlight = {};
  final StreamController<String> _corrupted = StreamController<String>.broadcast();

  /// Lesson ids whose data failed an integrity check while being served. The
  /// player listens so it can tell the student and drop the damaged download.
  Stream<String> get corruptedLessons => _corrupted.stream;

  bool get isRunning => _server != null;

  @visibleForTesting
  int? get port => _server?.port;

  /// Registers [source] for playback (starting the server if needed) and
  /// returns the URL the player should open.
  Future<Uri> serve(OfflinePlaybackSource source) async {
    _sources[source.lessonId] = source;
    // A re-download produces new keys and new chunks under the same id.
    _cache.evictLesson(source.lessonId);
    await _ensureStarted();
    return Uri(
      scheme: 'http',
      host: InternetAddress.loopbackIPv4.address,
      port: _server!.port,
      path: '/${source.lessonId}.mp4',
      queryParameters: {'token': _token},
    );
  }

  /// Stops serving [lessonId]; shuts the server down once nothing is left.
  Future<void> release(String lessonId) async {
    _sources.remove(lessonId);
    _cache.evictLesson(lessonId);
    if (_sources.isEmpty) await _stop();
  }

  Future<void> _ensureStarted() {
    if (_server != null) return Future<void>.value();
    return _starting ??= _start().whenComplete(() => _starting = null);
  }

  Future<void> _start() async {
    _token = _newToken();
    _worker = await OfflineDecryptWorker.spawn();
    final HttpServer server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    server.listen((request) => unawaited(_handle(request)));
    _server = server;
  }

  Future<void> _stop() async {
    final HttpServer? server = _server;
    _server = null;
    _token = '';
    await server?.close(force: true);
    _worker?.dispose();
    _worker = null;
    _cache.clear();
    _inFlight.clear();
  }

  static String _newToken() {
    final Random rng = Random.secure();
    return base64UrlEncode(List<int>.generate(32, (_) => rng.nextInt(256))).replaceAll('=', '');
  }

  bool _tokenMatches(String provided) {
    if (_token.isEmpty || provided.length != _token.length) return false;
    int diff = 0;
    for (int i = 0; i < provided.length; i++) {
      diff |= provided.codeUnitAt(i) ^ _token.codeUnitAt(i);
    }
    return diff == 0;
  }

  // --- Request handling -------------------------------------------------------

  Future<void> _handle(HttpRequest request) async {
    final HttpResponse response = request.response;
    String? lessonId;
    try {
      if (request.method != 'GET' && request.method != 'HEAD') {
        return await _reply(response, HttpStatus.methodNotAllowed);
      }
      if (!_tokenMatches(request.uri.queryParameters['token'] ?? '')) {
        return await _reply(response, HttpStatus.forbidden);
      }
      final List<String> segments = request.uri.pathSegments;
      if (segments.length != 1) return await _reply(response, HttpStatus.notFound);
      lessonId = segments.single.endsWith('.mp4')
          ? segments.single.substring(0, segments.single.length - 4)
          : segments.single;
      final OfflinePlaybackSource? source = _sources[lessonId];
      if (source == null) return await _reply(response, HttpStatus.notFound);

      response.headers
        ..contentType = ContentType('video', 'mp4')
        ..set(HttpHeaders.acceptRangesHeader, 'bytes')
        ..set(HttpHeaders.cacheControlHeader, 'no-store');

      final ByteRange? range = ByteRange.parse(request.headers.value(HttpHeaders.rangeHeader), source.totalBytes);
      if (range == null) {
        response.headers.set(HttpHeaders.contentRangeHeader, 'bytes */${source.totalBytes}');
        return await _reply(response, HttpStatus.requestedRangeNotSatisfiable);
      }
      if (range.isEmpty) {
        response.contentLength = 0;
        return await _reply(response, HttpStatus.ok);
      }

      final int size = source.plainChunkSize;
      final int firstIndex = range.start ~/ size;
      final int lastIndex = range.end ~/ size;

      // Decrypt the first chunk BEFORE committing headers: a corrupted chunk
      // then gets a clean error status instead of a half-sent 206.
      final Uint8List first = await _chunk(source, firstIndex);

      response.statusCode = range.partial ? HttpStatus.partialContent : HttpStatus.ok;
      response.contentLength = range.length;
      if (range.partial) {
        response.headers.set(HttpHeaders.contentRangeHeader, 'bytes ${range.start}-${range.end}/${source.totalBytes}');
      }
      if (request.method == 'HEAD') return await response.close();

      for (int index = firstIndex; index <= lastIndex; index++) {
        final Uint8List plain = index == firstIndex ? first : await _chunk(source, index);
        final int chunkStart = index * size;
        final int from = max(range.start, chunkStart) - chunkStart;
        final int to = min(range.end + 1, chunkStart + plain.length) - chunkStart;
        response.add(Uint8List.sublistView(plain, from, to));
        // Backpressure: wait for the socket to drain before decrypting more,
        // and surface a client that went away (the player cancels requests
        // constantly while seeking).
        await response.flush();
        // Warm the next chunk while the player consumes this one.
        if (index == lastIndex && index + 1 < source.chunkCount) _prefetch(source, index + 1);
      }
      await response.close();
    } on ChunkAuthenticationException {
      _reportCorrupted(lessonId);
      await _abort(response);
    } on OfflineDecryptException {
      _reportCorrupted(lessonId);
      await _abort(response);
    } catch (_) {
      // Client disconnected mid-response (normal while seeking) or the server
      // is shutting down — nothing to report.
      await _abort(response);
    }
  }

  void _reportCorrupted(String? lessonId) {
    if (lessonId != null && !_corrupted.isClosed) _corrupted.add(lessonId);
  }

  Future<void> _reply(HttpResponse response, int status) async {
    response.statusCode = status;
    await response.close();
  }

  /// Ends a response that can't be completed. Before headers are sent this is
  /// a 500; after, closing short of Content-Length makes the player see a
  /// truncated body and raise its own error.
  Future<void> _abort(HttpResponse response) async {
    try {
      response.statusCode = HttpStatus.internalServerError;
    } catch (_) {
      // Headers already sent.
    }
    try {
      await response.close();
    } catch (_) {}
  }

  // --- Chunk access -----------------------------------------------------------

  Future<Uint8List> _chunk(OfflinePlaybackSource source, int index) {
    final String key = _ChunkCache.keyFor(source.lessonId, index);
    final Uint8List? cached = _cache.get(key);
    if (cached != null) return Future<Uint8List>.value(cached);
    // The player issues overlapping range requests; decrypt each chunk once.
    final Future<Uint8List>? running = _inFlight[key];
    if (running != null) return running;
    final OfflineDecryptWorker? worker = _worker;
    if (worker == null) return Future<Uint8List>.error(StateError('server stopped'));
    final Future<Uint8List> future = worker
        .decrypt(source, index)
        .then((bytes) {
          if (_sources[source.lessonId] == source) _cache.put(key, bytes);
          return bytes;
        })
        // Block body on purpose: an arrow would return `_inFlight.remove(key)`
        // — which is THIS future — and `whenComplete` waits on a future its
        // callback returns, so the future would wait on itself forever.
        .whenComplete(() {
          _inFlight.remove(key);
        });
    _inFlight[key] = future;
    return future;
  }

  void _prefetch(OfflinePlaybackSource source, int index) {
    unawaited(_chunk(source, index).then((_) {}, onError: (_) {}));
  }
}

/// A resolved single byte range (inclusive [start]..[end]).
@immutable
class ByteRange {
  final int start;
  final int end;

  /// True when this answers a Range request (206); false for a full read (200).
  final bool partial;

  const ByteRange(this.start, this.end, {required this.partial});

  int get length => end - start + 1;
  bool get isEmpty => end < start;

  /// Resolves a `Range` header against a resource of [total] bytes.
  ///
  /// Returns null when the range is unsatisfiable (→ 416). A missing,
  /// malformed, or multi-range header resolves to the full resource, which
  /// RFC 9110 permits (the server may ignore Range).
  static ByteRange? parse(String? header, int total) {
    final ByteRange full = ByteRange(0, total - 1, partial: false);
    if (header == null) return full;
    final String value = header.trim();
    if (!value.startsWith('bytes=')) return full;
    final String spec = value.substring(6).trim();
    if (spec.contains(',')) return full;
    final int dash = spec.indexOf('-');
    if (dash < 0) return full;
    final String a = spec.substring(0, dash).trim();
    final String b = spec.substring(dash + 1).trim();

    if (a.isEmpty) {
      // Suffix range: the last n bytes.
      final int? n = int.tryParse(b);
      if (n == null) return full;
      if (n <= 0 || total == 0) return null;
      return ByteRange(max(0, total - n), total - 1, partial: true);
    }
    final int? start = int.tryParse(a);
    if (start == null || start < 0) return full;
    if (start >= total) return null;
    if (b.isEmpty) return ByteRange(start, total - 1, partial: true);
    final int? end = int.tryParse(b);
    if (end == null || end < start) return full;
    return ByteRange(start, min(end, total - 1), partial: true);
  }

  @override
  bool operator ==(Object other) =>
      other is ByteRange && other.start == start && other.end == end && other.partial == partial;

  @override
  int get hashCode => Object.hash(start, end, partial);

  @override
  String toString() => 'ByteRange($start-$end, partial: $partial)';
}

/// Small LRU of decrypted chunks: the player re-reads around the same offset
/// (iOS in particular issues many small ranges), so a few MiB of plaintext in
/// memory saves re-decrypting. Never written to disk.
class _ChunkCache {
  _ChunkCache({required this.maxEntries});

  final int maxEntries;
  final LinkedHashMap<String, Uint8List> _entries = LinkedHashMap<String, Uint8List>();

  static String keyFor(String lessonId, int index) => '$lessonId#$index';

  Uint8List? get(String key) {
    final Uint8List? value = _entries.remove(key);
    if (value != null) _entries[key] = value; // most recently used
    return value;
  }

  void put(String key, Uint8List value) {
    _entries.remove(key);
    _entries[key] = value;
    while (_entries.length > maxEntries) {
      _entries.remove(_entries.keys.first);
    }
  }

  void evictLesson(String lessonId) => _entries.removeWhere((k, _) => k.startsWith('$lessonId#'));

  void clear() => _entries.clear();
}
