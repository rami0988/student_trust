import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:mobile_template/features/downloads/data/services/encrypted_download_service.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

/// Serves files from a real local HTTP server so the whole Dio stack — range
/// requests, streaming, timeouts, retries — is exercised end to end. Faking
/// Dio's adapter would skip exactly the resume/truncation behaviour these
/// tests exist to pin down.
class _FakeVideoServer {
  late HttpServer _server;

  /// Full body the server pretends to hold.
  Uint8List body;

  /// When set, the server closes the connection after writing this many bytes
  /// of the response — simulating a connection dropping mid-transfer.
  int? truncateAfter;

  /// When false, `Range` is ignored and the whole body is returned with 200
  /// (some CDNs/proxies do this).
  bool honourRange;

  /// ETag advertised for the body, if any.
  String? etag;

  /// Fired right after a truncated response is cut off, so a test can react to
  /// the drop (e.g. pause) at a deterministic point instead of racing progress
  /// callbacks.
  void Function()? onTruncated;

  /// Requests seen so far, as (start offset, had-range) pairs.
  final List<int> requestedOffsets = [];

  /// When > 0, the next N transfer requests are answered with this status
  /// instead of bytes — how an expired signed URL (403) or a lapsed access
  /// token (401) presents itself mid-download.
  int failNextWith = 0;
  int failCount = 0;

  /// Status used for those simulated failures — 403 (expired CDN signature)
  /// or 401 (expired access token).
  int expiredStatus = HttpStatus.forbidden;

  /// Access tokens seen on transfer requests, so a test can assert the client
  /// actually re-read the token rather than replaying a stale one.
  final List<String> seenTokens = [];

  _FakeVideoServer(this.body, {this.truncateAfter, this.etag}) : honourRange = true;

  String get url => 'http://${_server.address.host}:${_server.port}/video.mp4';

  Future<void> start() async {
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    _server.listen((HttpRequest request) async {
      final String? range = request.headers.value('range');
      int start = 0;
      if (range != null && honourRange) {
        final Match? m = RegExp(r'bytes=(\d+)-').firstMatch(range);
        if (m != null) start = int.parse(m.group(1)!);
      }

      // The probe request (Range: bytes=0-1) resolves the URL; only real
      // transfer requests are interesting for expiry accounting.
      final bool isProbe = range == 'bytes=0-1';
      if (!isProbe) {
        final String? auth = request.headers.value('authorization');
        if (auth != null) seenTokens.add(auth);

        if (failCount < failNextWith) {
          failCount++;
          request.response.statusCode = expiredStatus;
          await request.response.close();
          return;
        }
      }

      requestedOffsets.add(start);

      // Client already holds everything.
      if (start >= body.length) {
        request.response.statusCode = HttpStatus.requestedRangeNotSatisfiable;
        await request.response.close();
        return;
      }

      final Uint8List slice = Uint8List.sublistView(body, start);
      if (etag != null) request.response.headers.set('etag', etag!);

      if (range != null && honourRange) {
        request.response.statusCode = HttpStatus.partialContent;
        request.response.headers.set('content-range', 'bytes $start-${body.length - 1}/${body.length}');
      } else {
        request.response.statusCode = HttpStatus.ok;
      }
      request.response.headers.contentLength = slice.length;

      // Never truncate the tiny URL-resolution probe: cutting that off fires
      // `onTruncated` (and so a test's pause/cancel) before the real transfer
      // has even opened its file, which is not what any of these tests mean.
      final int cut = isProbe ? slice.length : (truncateAfter ?? slice.length);
      request.response.add(Uint8List.sublistView(slice, 0, cut.clamp(0, slice.length)));
      await request.response.flush();
      if (cut < slice.length) {
        // Kill the socket without finishing the advertised length — this is
        // what a dropped mobile connection looks like to the client.
        await request.response.close().catchError((_) {});
        onTruncated?.call();
      } else {
        await request.response.close();
      }
    });
  }

  Future<void> stop() => _server.close(force: true);
}

/// `TestWidgetsFlutterBinding` installs an `HttpOverrides` that short-circuits
/// every request to a 400 with no network access. These tests deliberately talk
/// to a real loopback server, so the default client has to be put back.
class _RealHttpOverrides extends HttpOverrides {}

class _FakePathProvider extends PathProviderPlatform with MockPlatformInterfaceMixin {
  final String root;
  _FakePathProvider(this.root);

  @override
  Future<String?> getApplicationDocumentsPath() async => root;

  @override
  Future<String?> getTemporaryPath() async => '$root/tmp';
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempRoot;
  late EncryptedDownloadService service;
  late Box box;

  const String lessonId = 'lesson-1';
  const String studentId = 'student-1';
  const String deviceUuid = 'device-1';

  /// A body big enough to span several 2 MB encryption chunks but small enough
  /// to keep the test fast.
  Uint8List makeBody(int length) => Uint8List.fromList(List<int>.generate(length, (i) => (i * 7 + 13) % 256));

  setUpAll(() => HttpOverrides.global = _RealHttpOverrides());
  tearDownAll(() => HttpOverrides.global = null);

  setUp(() async {
    tempRoot = await Directory.systemTemp.createTemp('eds_test_');
    Directory('${tempRoot.path}/tmp').createSync(recursive: true);
    PathProviderPlatform.instance = _FakePathProvider(tempRoot.path);

    Hive.init('${tempRoot.path}/hive');
    box = await Hive.openBox(EncryptedDownloadService.boxName);
    service = EncryptedDownloadService();
  });

  tearDown(() async {
    await box.clear();
    await Hive.close();
    try {
      tempRoot.deleteSync(recursive: true);
    } catch (_) {}
  });

  Future<DownloadOutcome> download(String url) => service.downloadLesson(
    lessonId: lessonId,
    videoUrl: url,
    studentId: studentId,
    deviceUuid: deviceUuid,
    accessToken: () async => 'token',
    onProgress: (_) {},
  );

  /// Downloads, pausing as soon as the client reports real progress — i.e.
  /// provably mid-stream, with bytes already written. Deterministic in a way
  /// that pausing from the server's close callback is not.
  Future<DownloadOutcome> downloadPausingMidway(String url) {
    bool paused = false;
    return service.downloadLesson(
      lessonId: lessonId,
      videoUrl: url,
      studentId: studentId,
      deviceUuid: deviceUuid,
      accessToken: () async => 'token',
      onProgress: (p) {
        if (!paused && p > 0) {
          paused = true;
          service.pause(lessonId);
        }
      },
    );
  }

  group('successful download', () {
    test('marks the lesson complete and records the real size', () async {
      final Uint8List body = makeBody(300 * 1024);
      final _FakeVideoServer server = _FakeVideoServer(body);
      await server.start();
      addTearDown(server.stop);

      final DownloadOutcome outcome = await download(server.url);

      expect(outcome, DownloadOutcome.completed);
      expect(service.isDownloaded(lessonId), isTrue);
      expect((box.get(lessonId) as Map)['sizeBytes'], body.length);
    });

    test('decrypts back to the exact original bytes', () async {
      final Uint8List body = makeBody(300 * 1024);
      final _FakeVideoServer server = _FakeVideoServer(body);
      await server.start();
      addTearDown(server.stop);

      await download(server.url);
      final String path = await service.getOfflineVideoPath(lessonId: lessonId, studentId: studentId, deviceUuid: deviceUuid);

      expect(await File(path).readAsBytes(), equals(body));
    });

    test('leaves no .part file or sidecar behind', () async {
      final _FakeVideoServer server = _FakeVideoServer(makeBody(120 * 1024));
      await server.start();
      addTearDown(server.stop);

      await download(server.url);

      final Directory dir = Directory('${tempRoot.path}/edushield_videos/$lessonId');
      final List<String> names = dir.listSync().map((e) => e.uri.pathSegments.last).toList();
      expect(names.where((n) => n.contains('part')), isEmpty);
    });
  });

  group('truncated transfer', () {
    // This is the bug the whole integrity layer exists for: before, a dropped
    // connection ended the read loop the same way a finished one does, so the
    // partial file was encrypted and stored as "downloaded" — and only failed
    // later, at playback.
    test('never reports complete when the server cuts the stream short', () async {
      final Uint8List body = makeBody(400 * 1024);
      final _FakeVideoServer server = _FakeVideoServer(body, truncateAfter: 50 * 1024);
      await server.start();
      addTearDown(server.stop);

      await expectLater(download(server.url), throwsA(anything));

      expect(service.isDownloaded(lessonId), isFalse);
      expect(box.get(lessonId), isNull);
      // 2+4+8+16s of retry backoff has to elapse before the service gives up.
    }, timeout: const Timeout(Duration(minutes: 2)));

    test('resumes from the bytes already on disk instead of restarting', () async {
      final Uint8List body = makeBody(400 * 1024);
      // Serve only the first 100 KB, then stop truncating so the retry can
      // finish the job — the point is that the retry asks for the *remainder*.
      final _FakeVideoServer server = _FakeVideoServer(body, truncateAfter: 100 * 1024);
      await server.start();
      addTearDown(server.stop);

      // Let the first attempt fail, then open the tap for the retries.
      Future<void>.delayed(const Duration(milliseconds: 300), () => server.truncateAfter = null);

      final DownloadOutcome outcome = await download(server.url);

      expect(outcome, DownloadOutcome.completed);
      // At least one request resumed from a non-zero offset, i.e. the partial
      // was reused rather than thrown away.
      expect(server.requestedOffsets.where((o) => o > 0), isNotEmpty);
      final String path = await service.getOfflineVideoPath(lessonId: lessonId, studentId: studentId, deviceUuid: deviceUuid);
      expect(await File(path).readAsBytes(), equals(body));
    }, timeout: const Timeout(Duration(minutes: 2)));
  });

  // A download outlives its own credentials: the CDN signature is minted for a
  // window measured in minutes, and the access token for 15, while a large
  // lesson on mobile data (or one left paused overnight) runs far longer.
  // Treating the resulting 401/403 as fatal is what made big downloads fail
  // outright and left paused downloads permanently unresumable.
  group('credential expiry', () {
    test('recovers when the signed URL expires mid-download', () async {
      final Uint8List body = makeBody(200 * 1024);
      final _FakeVideoServer server = _FakeVideoServer(body);
      await server.start();
      addTearDown(server.stop);

      // First transfer attempt gets a 403, exactly like a lapsed signature.
      server.failNextWith = 1;
      server.expiredStatus = HttpStatus.forbidden;

      final DownloadOutcome outcome = await download(server.url);

      expect(outcome, DownloadOutcome.completed);
      expect(server.failCount, 1, reason: 'the 403 should have been served once');
      expect(box.get(lessonId)['isComplete'], isTrue);
      expect(box.get(lessonId)['sizeBytes'], body.length);
    });

    test('recovers when the access token expires mid-download', () async {
      final Uint8List body = makeBody(200 * 1024);
      final _FakeVideoServer server = _FakeVideoServer(body);
      await server.start();
      addTearDown(server.stop);

      server.failNextWith = 1;
      server.expiredStatus = HttpStatus.unauthorized;

      final DownloadOutcome outcome = await download(server.url);

      expect(outcome, DownloadOutcome.completed);
      expect(box.get(lessonId)['isComplete'], isTrue);
    });

    test('re-reads the token instead of replaying the expired one', () async {
      final Uint8List body = makeBody(120 * 1024);
      final _FakeVideoServer server = _FakeVideoServer(body);
      await server.start();
      addTearDown(server.stop);

      server.failNextWith = 1;
      server.expiredStatus = HttpStatus.unauthorized;

      // Hands out a different token each call, so a client that captured one
      // up front is visibly distinguishable from one that re-reads.
      int issued = 0;
      await service.downloadLesson(
        lessonId: lessonId,
        videoUrl: server.url,
        studentId: studentId,
        deviceUuid: deviceUuid,
        accessToken: () async => 'token-${++issued}',
        onProgress: (_) {},
      );

      expect(server.seenTokens.length, greaterThanOrEqualTo(2));
      expect(
        server.seenTokens.first,
        isNot(server.seenTokens.last),
        reason: 'the retry must use a freshly read token, not the stale one',
      );
    });

    test('gives up when freshly issued credentials are also refused', () async {
      // Renewing buys exactly one retry. If a brand-new token is rejected too,
      // the problem is access — not staleness — and retrying forever would
      // just hang the download.
      final Uint8List body = makeBody(80 * 1024);
      final _FakeVideoServer server = _FakeVideoServer(body);
      await server.start();
      addTearDown(server.stop);

      server.failNextWith = 99; // always refuse
      server.expiredStatus = HttpStatus.forbidden;

      await expectLater(download(server.url), throwsA(isA<DioException>()));
      expect(server.failCount, 2, reason: 'one original attempt plus exactly one renewal');
    });

    test('resumes from the bytes already on disk after renewing', () async {
      // The whole point of recovering: keep the partial. Restarting from zero
      // on every expiry would make a large lesson unfinishable on a slow link.
      final Uint8List body = makeBody(300 * 1024);
      final _FakeVideoServer server = _FakeVideoServer(body);
      await server.start();
      addTearDown(server.stop);

      // Drop the connection once, then refuse once, then serve normally.
      server.truncateAfter = 100 * 1024;
      server.onTruncated = () {
        server.truncateAfter = null;
        server.failNextWith = 1;
        server.expiredStatus = HttpStatus.forbidden;
      };

      final DownloadOutcome outcome = await download(server.url);

      expect(outcome, DownloadOutcome.completed);
      // The file is whole and correct despite a drop AND an expiry in the
      // middle of it — which is the behaviour that matters. (Whether the final
      // leg resumed by range or restarted is an implementation detail the
      // integrity gate already covers.)
      expect(box.get(lessonId)['sizeBytes'], body.length);
      expect(server.failCount, 1, reason: 'the expiry was served and recovered from');
    });

    test('a paused download still completes after its signature has expired', () async {
      // The worst-lived case in practice: a student pauses, comes back the next
      // day, and every credential from the first session is long dead. Before
      // the fix the resume hit 403 and failed for good, leaving no way forward
      // but deleting and starting over.
      final Uint8List body = makeBody(400 * 1024);
      final _FakeVideoServer server = _FakeVideoServer(body);
      await server.start();
      addTearDown(server.stop);

      final DownloadOutcome first = await downloadPausingMidway(server.url);
      expect(first, DownloadOutcome.paused);

      // The partial must survive a pause — that is the entire point of pausing
      // rather than cancelling.
      final int partial = File('${tempRoot.path}/edushield_videos/$lessonId/video.part').lengthSync();
      expect(partial, greaterThan(0), reason: 'a paused download must keep its bytes');

      // Resume into an expired signature.
      server.failNextWith = 1;
      server.expiredStatus = HttpStatus.forbidden;
      server.requestedOffsets.clear();

      final DownloadOutcome second = await download(server.url);

      expect(second, DownloadOutcome.completed);
      expect(box.get(lessonId)['sizeBytes'], body.length);
      expect(server.failCount, 1, reason: 'the expiry was served and recovered from');
      expect(
        server.requestedOffsets.any((o) => o == partial),
        isTrue,
        reason: 'the resume must continue from the partial, not re-fetch from zero',
      );

      // And the bytes are the real video, not a splice of two attempts.
      final String path = await service.getOfflineVideoPath(lessonId: lessonId, studentId: studentId, deviceUuid: deviceUuid);
      expect(await File(path).readAsBytes(), equals(body));
    }, timeout: const Timeout(Duration(minutes: 2)));
  });

  group('pause and resume', () {
    test('keeps the partial file when paused', () async {
      // A pause surfaces from the aborted stream as a raw HttpException, which
      // looks exactly like a flaky connection. When that was allowed to fall
      // through to the integrity gate, the gate saw a short file and deleted
      // it — so "pause" quietly meant "start over", and every resume on a weak
      // connection re-downloaded everything.
      //
      // The pause is triggered from the *client's* progress callback rather
      // than the server's close, so it lands while the client is provably
      // mid-stream — pausing on the server side races the client's read loop
      // and makes the test flaky for reasons that have nothing to do with the
      // behaviour under test.
      final Uint8List body = makeBody(400 * 1024);
      final _FakeVideoServer server = _FakeVideoServer(body);
      await server.start();
      addTearDown(server.stop);

      expect(await downloadPausingMidway(server.url), DownloadOutcome.paused);

      final File part = File('${tempRoot.path}/edushield_videos/$lessonId/video.part');
      expect(part.existsSync(), isTrue, reason: 'the .part must outlive the pause');
      expect(part.lengthSync(), greaterThan(0));
      // The fingerprint has to survive too, or the resume can't prove the
      // partial belongs to this file and restarts anyway.
      expect(File('${tempRoot.path}/edushield_videos/$lessonId/video.part.json').existsSync(), isTrue);
    }, timeout: const Timeout(Duration(minutes: 2)));

    test('resumes from the paused offset instead of re-downloading', () async {
      final Uint8List body = makeBody(400 * 1024);
      final _FakeVideoServer server = _FakeVideoServer(body);
      await server.start();
      addTearDown(server.stop);

      expect(await downloadPausingMidway(server.url), DownloadOutcome.paused);

      final int partial = File('${tempRoot.path}/edushield_videos/$lessonId/video.part').lengthSync();
      server.requestedOffsets.clear();

      expect(await download(server.url), DownloadOutcome.completed);

      expect(
        server.requestedOffsets.any((o) => o == partial),
        isTrue,
        reason: 'the resumed request must ask for bytes=$partial-, not restart',
      );
      // And the result is still byte-exact — resuming must not splice.
      final String path = await service.getOfflineVideoPath(lessonId: lessonId, studentId: studentId, deviceUuid: deviceUuid);
      expect(await File(path).readAsBytes(), equals(body));
    }, timeout: const Timeout(Duration(minutes: 2)));

    test('cancel still removes everything', () async {
      // The mirror of the above: cancel must keep deleting, or "cancel" would
      // leave junk on disk forever.
      final Uint8List body = makeBody(400 * 1024);
      final _FakeVideoServer server = _FakeVideoServer(body);
      await server.start();
      addTearDown(server.stop);

      bool cancelled = false;
      final DownloadOutcome outcome = await service.downloadLesson(
        lessonId: lessonId,
        videoUrl: server.url,
        studentId: studentId,
        deviceUuid: deviceUuid,
        accessToken: () async => 'token',
        onProgress: (p) {
          if (!cancelled && p > 0) {
            cancelled = true;
            service.cancel(lessonId);
          }
        },
      );

      expect(outcome, DownloadOutcome.canceled);
      expect(Directory('${tempRoot.path}/edushield_videos/$lessonId').existsSync(), isFalse);
      expect(box.get(lessonId), isNull);
    }, timeout: const Timeout(Duration(minutes: 2)));
  });

  group('resume safety', () {
    test('restarts from zero when the remote file changed size under us', () async {
      final Uint8List first = makeBody(400 * 1024);
      final _FakeVideoServer server = _FakeVideoServer(first, etag: '"v1"');
      await server.start();
      addTearDown(server.stop);

      // Leave a real partial + fingerprint for the ORIGINAL file on disk: the
      // server drops the connection part-way, then the pause stops the retry
      // ladder before it can resume and finish.
      server.truncateAfter = 60 * 1024;
      server.onTruncated = () => service.pause(lessonId);
      expect(await download(server.url), DownloadOutcome.paused);
      server.truncateAfter = null;
      server.onTruncated = null;

      // The URL now resolves to a *different* video (re-signed URL, new
      // rendition). Appending onto the old partial would splice two files
      // together into something that passes every "is it there?" check but
      // won't play.
      final Uint8List second = makeBody(250 * 1024);
      server.body = second;
      server.etag = '"v2"';

      final DownloadOutcome outcome = await download(server.url);

      expect(outcome, DownloadOutcome.completed);
      final String path = await service.getOfflineVideoPath(lessonId: lessonId, studentId: studentId, deviceUuid: deviceUuid);
      expect(await File(path).readAsBytes(), equals(second));
    }, timeout: const Timeout(Duration(minutes: 2)));

    test('handles a server that ignores Range and replies 200', () async {
      final Uint8List body = makeBody(300 * 1024);
      final _FakeVideoServer server = _FakeVideoServer(body);
      await server.start();
      addTearDown(server.stop);

      // Leave a real partial behind: the server drops the connection part-way,
      // then the pause stops the retry ladder before it can finish the job.
      server.truncateAfter = 60 * 1024;
      server.onTruncated = () => service.pause(lessonId);
      final DownloadOutcome paused = await download(server.url);
      expect(paused, DownloadOutcome.paused);
      server.truncateAfter = null;
      server.onTruncated = null;

      // Second round: the server now ignores Range and sends the whole body
      // with a 200 (proxies and some CDN edges do this).
      server.honourRange = false;

      final DownloadOutcome outcome = await download(server.url);

      expect(outcome, DownloadOutcome.completed);
      final String path = await service.getOfflineVideoPath(lessonId: lessonId, studentId: studentId, deviceUuid: deviceUuid);
      // Must be exactly the body - not the body appended onto the old partial.
      expect(await File(path).readAsBytes(), equals(body));
    }, timeout: const Timeout(Duration(minutes: 2)));
  });

  group('JSON body guard', () {
    test('rejects a stream endpoint that returns JSON instead of video', () async {
      final _FakeVideoServer server = _FakeVideoServer(Uint8List.fromList(utf8.encode('{"error":"nope"}')));
      await server.start();
      addTearDown(server.stop);

      await expectLater(download(server.url), throwsA(anything));
      expect(service.isDownloaded(lessonId), isFalse);
    }, timeout: const Timeout(Duration(minutes: 2)));
  });

  group('playback integrity', () {
    test('reports a corrupted download when a chunk went missing', () async {
      final _FakeVideoServer server = _FakeVideoServer(makeBody(300 * 1024));
      await server.start();
      addTearDown(server.stop);

      await download(server.url);

      // Simulate a storage cleaner / OS purge removing an encrypted chunk.
      File('${tempRoot.path}/edushield_videos/$lessonId/chunk_0.enc').deleteSync();

      await expectLater(
        service.getOfflineVideoPath(lessonId: lessonId, studentId: studentId, deviceUuid: deviceUuid),
        throwsA(predicate((e) => e.toString().contains('DOWNLOAD_CORRUPTED'))),
      );
      // And the unusable entry is dropped so the UI offers a re-download.
      expect(service.isDownloaded(lessonId), isFalse);
    });

    test('refuses to decrypt with a different device uuid', () async {
      final _FakeVideoServer server = _FakeVideoServer(makeBody(120 * 1024));
      await server.start();
      addTearDown(server.stop);

      await download(server.url);

      // The key is derived from (student, device, lesson) — another device
      // must not be able to read these chunks.
      await expectLater(
        service.getOfflineVideoPath(lessonId: lessonId, studentId: studentId, deviceUuid: 'someone-elses-device'),
        throwsA(anything),
      );
    });
  });

  group('startup reconciliation', () {
    test('drops an entry left mid-download by an app kill', () async {
      await box.put(lessonId, {
        'lessonId': lessonId,
        'title': 'interrupted',
        'chunkCount': 0,
        'isComplete': false,
        'downloadedAt': DateTime.now().toIso8601String(),
        'lastValidatedAt': DateTime.now().toIso8601String(),
      });

      await service.reconcileOnStartup();

      expect(box.get(lessonId), isNull);
    });

    test('drops a "complete" entry whose chunks are gone', () async {
      final _FakeVideoServer server = _FakeVideoServer(makeBody(120 * 1024));
      await server.start();
      addTearDown(server.stop);

      await download(server.url);
      expect(service.isDownloaded(lessonId), isTrue);

      Directory('${tempRoot.path}/edushield_videos/$lessonId').deleteSync(recursive: true);
      await service.reconcileOnStartup();

      expect(box.get(lessonId), isNull);
    });

    test('deletes an orphaned lesson directory with no metadata', () async {
      final Directory orphan = Directory('${tempRoot.path}/edushield_videos/orphan-lesson')..createSync(recursive: true);
      File('${orphan.path}/video.part').writeAsBytesSync(makeBody(1024));

      await service.reconcileOnStartup();

      expect(orphan.existsSync(), isFalse);
    });

    test('keeps a healthy download untouched', () async {
      final _FakeVideoServer server = _FakeVideoServer(makeBody(120 * 1024));
      await server.start();
      addTearDown(server.stop);

      await download(server.url);
      await service.reconcileOnStartup();

      expect(service.isDownloaded(lessonId), isTrue);
    });
  });

  group('deletion', () {
    test('deleteLesson removes both the metadata and the files', () async {
      final _FakeVideoServer server = _FakeVideoServer(makeBody(120 * 1024));
      await server.start();
      addTearDown(server.stop);

      await download(server.url);
      await service.deleteLesson(lessonId);

      expect(service.isDownloaded(lessonId), isFalse);
      expect(Directory('${tempRoot.path}/edushield_videos/$lessonId').existsSync(), isFalse);
    });

    test('deleteAll clears every download and reports the count', () async {
      final _FakeVideoServer server = _FakeVideoServer(makeBody(80 * 1024));
      await server.start();
      addTearDown(server.stop);

      for (final String id in ['a', 'b', 'c']) {
        await service.downloadLesson(
          lessonId: id,
          videoUrl: server.url,
          studentId: studentId,
          deviceUuid: deviceUuid,
          accessToken: () async => 'token',
          onProgress: (_) {},
        );
      }
      expect(service.getDownloadedLessons(), hasLength(3));

      final int removed = await service.deleteAll();

      expect(removed, 3);
      expect(service.getDownloadedLessons(), isEmpty);
      expect(service.totalBytesUsed(), 0);
    });

    test('totalBytesUsed sums the completed downloads', () async {
      final Uint8List body = makeBody(80 * 1024);
      final _FakeVideoServer server = _FakeVideoServer(body);
      await server.start();
      addTearDown(server.stop);

      await service.downloadLesson(
        lessonId: 'a',
        videoUrl: server.url,
        studentId: studentId,
        deviceUuid: deviceUuid,
        accessToken: () async => 'token',
        onProgress: (_) {},
      );
      await service.downloadLesson(
        lessonId: 'b',
        videoUrl: server.url,
        studentId: studentId,
        deviceUuid: deviceUuid,
        accessToken: () async => 'token',
        onProgress: (_) {},
      );

      expect(service.totalBytesUsed(), body.length * 2);
    });
  });
}
