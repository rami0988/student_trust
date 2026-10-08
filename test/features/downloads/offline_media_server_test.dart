import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_template/features/downloads/data/services/offline_crypto.dart';
import 'package:mobile_template/features/downloads/data/services/offline_media_server.dart';

import '../../helpers/legacy_v1_fixture.dart';

/// A real HTTP response, read fully.
class _Reply {
  final int status;
  final HttpHeaders headers;
  final Uint8List body;
  _Reply(this.status, this.headers, this.body);
}

void main() {
  const int mib = 1024 * 1024;
  const String lessonId = 'lesson-1';

  // Deliberately no TestWidgetsFlutterBinding: it installs an HttpOverrides
  // that answers every request with 400, and these tests need real sockets.
  setUpAll(() => HttpOverrides.global = null);

  Uint8List bytes(int length) => Uint8List.fromList(List<int>.generate(length, (i) => (i * 31 + 7) % 256));

  late Directory tempDir;
  late OfflineMediaServer server;
  late HttpClient client;

  setUp(() {
    tempDir = Directory.systemTemp.createTempSync('media_server_');
    server = OfflineMediaServer();
    client = HttpClient();
  });

  tearDown(() async {
    client.close(force: true);
    await server.release(lessonId);
    await server.release('lesson-2');
    try {
      tempDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  Future<OfflinePlaybackSource> v2Source(Uint8List plain, {String id = lessonId, String? dirPath}) async {
    final String dir = dirPath ?? '${tempDir.path}/$id';
    Directory(dir).createSync(recursive: true);
    final File part = File('$dir/video.part')..writeAsBytesSync(plain);
    final OfflineKeyMaterial keys = OfflineKeyMaterial.generate();
    final int count = chunkCountFor(plain.length, v2ChunkSize);
    await encryptBatchV2InBackground(
      EncryptBatchV2(
        partPath: part.path,
        lessonDirPath: dir,
        lessonId: id,
        keyBytes: keys.bytes,
        firstChunk: 0,
        endChunk: count,
        chunkCount: count,
      ),
    );
    part.deleteSync();
    return OfflinePlaybackSource(
      lessonId: id,
      format: OfflineFormat.v2CtrHmac,
      lessonDirPath: dir,
      chunkCount: count,
      totalBytes: plain.length,
      keyBytes: keys.bytes,
    );
  }

  Future<_Reply> fetch(Uri url, {String? range, String method = 'GET'}) async {
    final HttpClientRequest request = await client.openUrl(method, url);
    if (range != null) request.headers.set(HttpHeaders.rangeHeader, range);
    final HttpClientResponse response = await request.close();
    final BytesBuilder body = BytesBuilder(copy: false);
    await response.forEach(body.add);
    return _Reply(response.statusCode, response.headers, body.takeBytes());
  }

  group('ByteRange.parse', () {
    const int total = 1000;

    test('no header → the whole resource, 200', () {
      expect(ByteRange.parse(null, total), const ByteRange(0, 999, partial: false));
    });

    test('closed, open-ended and suffix ranges', () {
      expect(ByteRange.parse('bytes=0-99', total), const ByteRange(0, 99, partial: true));
      expect(ByteRange.parse('bytes=500-', total), const ByteRange(500, 999, partial: true));
      expect(ByteRange.parse('bytes=-100', total), const ByteRange(900, 999, partial: true));
    });

    test('an end past the resource is clipped; a suffix longer than it is the whole thing', () {
      expect(ByteRange.parse('bytes=900-5000', total), const ByteRange(900, 999, partial: true));
      expect(ByteRange.parse('bytes=-5000', total), const ByteRange(0, 999, partial: true));
    });

    test('unsatisfiable ranges are null (→ 416)', () {
      expect(ByteRange.parse('bytes=1000-', total), isNull);
      expect(ByteRange.parse('bytes=5000-6000', total), isNull);
      expect(ByteRange.parse('bytes=-0', total), isNull);
    });

    test('malformed, reversed or multi-range headers fall back to the whole resource', () {
      final ByteRange full = ByteRange.parse(null, total)!;
      for (final String h in ['bytes=abc', 'bytes=50-10', 'bytes=0-1,5-9', 'items=0-9', 'bytes=']) {
        expect(ByteRange.parse(h, total), full, reason: h);
      }
    });
  });

  group('serving', () {
    test('the URL is loopback-only and carries a session token', () async {
      final Uri url = await server.serve(await v2Source(bytes(1000)));

      expect(url.host, '127.0.0.1');
      expect(url.path, '/$lessonId.mp4');
      expect(url.queryParameters['token'], hasLength(greaterThanOrEqualTo(40)));
    });

    test('a full GET returns the whole decrypted video with streaming headers', () async {
      final Uint8List plain = bytes(2 * mib + 333);
      final Uri url = await server.serve(await v2Source(plain));

      final _Reply r = await fetch(url);

      expect(r.status, HttpStatus.ok);
      expect(r.body, equals(plain));
      expect(r.headers.contentLength, plain.length);
      expect(r.headers.value(HttpHeaders.acceptRangesHeader), 'bytes');
      expect(r.headers.contentType?.mimeType, 'video/mp4');
      expect(r.headers.value(HttpHeaders.cacheControlHeader), 'no-store');
    });

    test('a range inside one chunk returns 206 with exactly those bytes', () async {
      final Uint8List plain = bytes(3 * mib);
      final Uri url = await server.serve(await v2Source(plain));

      final _Reply r = await fetch(url, range: 'bytes=100-199');

      expect(r.status, HttpStatus.partialContent);
      expect(r.body, equals(Uint8List.sublistView(plain, 100, 200)));
      expect(r.headers.value(HttpHeaders.contentRangeHeader), 'bytes 100-199/${plain.length}');
      expect(r.headers.contentLength, 100);
    });

    test('a range spanning chunk boundaries is stitched together exactly', () async {
      final Uint8List plain = bytes(3 * mib + 10);
      final Uri url = await server.serve(await v2Source(plain));
      const int start = mib - 50;
      const int end = 2 * mib + 50; // crosses two boundaries

      final _Reply r = await fetch(url, range: 'bytes=$start-$end');

      expect(r.status, HttpStatus.partialContent);
      expect(r.body, equals(Uint8List.sublistView(plain, start, end + 1)));
    });

    test('open-ended and suffix ranges (what players send when seeking / probing)', () async {
      final Uint8List plain = bytes(2 * mib + 999);
      final Uri url = await server.serve(await v2Source(plain));

      final _Reply open = await fetch(url, range: 'bytes=${mib + 5}-');
      expect(open.body, equals(Uint8List.sublistView(plain, mib + 5)));

      final _Reply tail = await fetch(url, range: 'bytes=-500');
      expect(tail.body, equals(Uint8List.sublistView(plain, plain.length - 500)));

      // iOS AVPlayer opens with a two-byte probe.
      final _Reply probe = await fetch(url, range: 'bytes=0-1');
      expect(probe.status, HttpStatus.partialContent);
      expect(probe.body, equals(Uint8List.sublistView(plain, 0, 2)));
    });

    test('an unsatisfiable range is 416 with the real size', () async {
      final Uint8List plain = bytes(5000);
      final Uri url = await server.serve(await v2Source(plain));

      final _Reply r = await fetch(url, range: 'bytes=5000-');

      expect(r.status, HttpStatus.requestedRangeNotSatisfiable);
      expect(r.headers.value(HttpHeaders.contentRangeHeader), 'bytes */5000');
    });

    test('HEAD answers the headers without a body', () async {
      final Uint8List plain = bytes(mib + 1);
      final Uri url = await server.serve(await v2Source(plain));

      final _Reply r = await fetch(url, method: 'HEAD');

      expect(r.status, HttpStatus.ok);
      expect(r.headers.contentLength, plain.length);
      expect(r.body, isEmpty);
    });

    test('concurrent overlapping range requests are all answered correctly', () async {
      final Uint8List plain = bytes(4 * mib);
      final Uri url = await server.serve(await v2Source(plain));
      final List<List<int>> ranges = [
        [0, 99999],
        [50000, 1500000],
        [mib, 3 * mib],
        [3 * mib + 7, 4 * mib - 1],
        [0, 1],
      ];

      final List<_Reply> replies = await Future.wait(ranges.map((r) => fetch(url, range: 'bytes=${r[0]}-${r[1]}')));

      for (int i = 0; i < ranges.length; i++) {
        expect(replies[i].body, equals(Uint8List.sublistView(plain, ranges[i][0], ranges[i][1] + 1)), reason: '$i');
      }
    });
  });

  group('access control', () {
    test('a missing or wrong token is refused', () async {
      final Uri url = await server.serve(await v2Source(bytes(1000)));

      expect((await fetch(url.replace(queryParameters: {}))).status, HttpStatus.forbidden);
      expect((await fetch(url.replace(queryParameters: {'token': 'guess'}))).status, HttpStatus.forbidden);
    });

    test('a valid token does not unlock lessons that are not being played', () async {
      final Uri url = await server.serve(await v2Source(bytes(1000)));

      final _Reply r = await fetch(url.replace(path: '/some-other-lesson.mp4'));

      expect(r.status, HttpStatus.notFound);
    });

    test('only GET and HEAD are served', () async {
      final Uri url = await server.serve(await v2Source(bytes(1000)));

      expect((await fetch(url, method: 'POST')).status, HttpStatus.methodNotAllowed);
    });

    test('releasing the last lesson stops the server; a restart issues a new token', () async {
      final OfflinePlaybackSource source = await v2Source(bytes(1000));
      final Uri first = await server.serve(source);
      expect(server.isRunning, isTrue);

      await server.release(lessonId);

      expect(server.isRunning, isFalse);
      await expectLater(fetch(first), throwsA(isA<SocketException>()), reason: 'nothing is listening any more');

      final Uri second = await server.serve(source);
      expect(second.queryParameters['token'], isNot(first.queryParameters['token']));
    });

    test('releasing one lesson keeps serving the others', () async {
      final Uri a = await server.serve(await v2Source(bytes(1000)));
      final Uri b = await server.serve(await v2Source(bytes(2000), id: 'lesson-2'));

      await server.release(lessonId);

      expect((await fetch(a)).status, HttpStatus.notFound);
      expect((await fetch(b)).status, HttpStatus.ok);
    });
  });

  group('integrity', () {
    test('a tampered chunk is refused and reported, never served as garbage', () async {
      final Uint8List plain = bytes(2 * mib);
      final OfflinePlaybackSource source = await v2Source(plain);
      final File chunk = File(source.chunkPath(0));
      final Uint8List data = chunk.readAsBytesSync()..[100] ^= 0x01;
      chunk.writeAsBytesSync(data);
      final Uri url = await server.serve(source);
      final Future<String> reported = server.corruptedLessons.first.timeout(const Duration(seconds: 5));

      final _Reply r = await fetch(url, range: 'bytes=0-99');

      expect(r.status, HttpStatus.internalServerError);
      expect(r.body, isNot(equals(Uint8List.sublistView(plain, 0, 100))));
      expect(await reported, lessonId);
    });

    test('an intact chunk next to a damaged one still serves', () async {
      final Uint8List plain = bytes(2 * mib);
      final OfflinePlaybackSource source = await v2Source(plain);
      final File chunk = File(source.chunkPath(0));
      chunk.writeAsBytesSync(chunk.readAsBytesSync()..[100] ^= 0x01);
      final Uri url = await server.serve(source);

      final _Reply r = await fetch(url, range: 'bytes=$mib-${mib + 99}');

      expect(r.status, HttpStatus.partialContent);
      expect(r.body, equals(Uint8List.sublistView(plain, mib, mib + 100)));
    });
  });

  group('legacy v1 downloads (backward compatibility)', () {
    test('an old-format download streams byte-exact, with ranges, through the same server', () async {
      const String studentId = 'student-1';
      const String deviceUuid = 'device-1';
      final Uint8List plain = bytes(5 * mib + 1234);
      final String dir = '${tempDir.path}/$lessonId';
      final int count = writeLegacyV1Chunks(
        lessonDirPath: dir,
        plain: plain,
        studentId: studentId,
        deviceUuid: deviceUuid,
        lessonId: lessonId,
      );
      final OfflinePlaybackSource source = OfflinePlaybackSource(
        lessonId: lessonId,
        format: OfflineFormat.v1Cbc,
        lessonDirPath: dir,
        chunkCount: count,
        totalBytes: plain.length,
        keyBytes: Uint8List.fromList(sha256.convert(utf8.encode('$studentId:$deviceUuid:$lessonId')).bytes),
        v1Iv: Uint8List.fromList(sha256.convert(utf8.encode('$lessonId:$studentId')).bytes.sublist(0, 16)),
      );
      final Uri url = await server.serve(source);

      expect((await fetch(url)).body, equals(plain));
      const int start = 2 * mib - 10; // across the old 2 MiB chunk boundary
      final _Reply r = await fetch(url, range: 'bytes=$start-${start + 19}');
      expect(r.status, HttpStatus.partialContent);
      expect(r.body, equals(Uint8List.sublistView(plain, start, start + 20)));
    });
  });
}
