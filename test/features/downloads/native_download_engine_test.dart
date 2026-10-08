import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:mobile_template/features/downloads/data/local/download_records_store.dart';
import 'package:mobile_template/features/downloads/data/local/offline_key_store.dart';
import 'package:mobile_template/features/downloads/data/models/download_record.dart';
import 'package:mobile_template/features/downloads/data/services/background_transfer_client.dart';
import 'package:mobile_template/features/downloads/data/services/download_engine.dart';
import 'package:mobile_template/features/downloads/data/services/encrypted_download_service.dart';
import 'package:mobile_template/features/downloads/data/services/native_download_engine.dart';
import 'package:mobile_template/features/downloads/data/services/offline_crypto.dart';
import 'package:mobile_template/features/downloads/data/services/storage_guard.dart';
import 'package:mobile_template/hive/hive_registrar.g.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../../helpers/fake_secure_storage.dart';
import '../../helpers/fake_transfer_client.dart';

class _FakePathProvider extends PathProviderPlatform with MockPlatformInterfaceMixin {
  final String root;
  _FakePathProvider(this.root);

  @override
  Future<String?> getApplicationDocumentsPath() async => root;

  @override
  Future<String?> getTemporaryPath() async => '$root/tmp';
}

class _FakeStorageGuard extends StorageGuard {
  int? free;
  _FakeStorageGuard();

  @override
  Future<int?> freeBytes() async => free;
}

/// Plays the backend stream endpoint: answers the engine's URL probe with a
/// freshly signed CDN URL (production shape), or — in `dev` mode — with video
/// bytes, so the endpoint itself is the download URL.
class _StreamEndpoint {
  late HttpServer _server;
  int signed = 0;
  bool dev = false;

  String get url => 'http://${_server.address.host}:${_server.port}/video/stream/lesson-1';

  Future<void> start() async {
    _server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    _server.listen((request) async {
      if (dev) {
        request.response
          ..statusCode = HttpStatus.partialContent
          ..add([0, 0]);
      } else {
        signed++;
        request.response
          ..headers.contentType = ContentType.json
          ..write(jsonEncode({'mode': 'bunnycdn', 'directUrl': 'https://cdn.test/sig-$signed/play_720p.mp4'}));
      }
      await request.response.close();
    });
  }

  Future<void> stop() => _server.close(force: true);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const String lessonId = 'lesson-1';
  const String studentId = 'student-1';
  const String deviceUuid = 'device-1';

  late Directory tempRoot;
  late FakeTransferClient client;
  late EncryptedDownloadService service;
  late DownloadRecordsStore records;
  late _FakeStorageGuard guard;
  late _StreamEndpoint endpoint;
  late NativeDownloadEngine engine;
  late List<TransferProgress> progress;

  Uint8List body(int length) => Uint8List.fromList(List<int>.generate(length, (i) => (i * 13 + 5) % 256));

  setUpAll(() => Hive.registerAdapters());

  setUp(() async {
    HttpOverrides.global = null; // the test binding would answer 400
    tempRoot = await Directory.systemTemp.createTemp('native_engine_');
    Directory('${tempRoot.path}/tmp').createSync(recursive: true);
    PathProviderPlatform.instance = _FakePathProvider(tempRoot.path);
    Hive.init('${tempRoot.path}/hive');
    await Hive.openBox(EncryptedDownloadService.boxName);
    await Hive.openBox<DownloadRecord>(DownloadRecordsStore.boxName);

    guard = _FakeStorageGuard();
    service = EncryptedDownloadService(keyStore: OfflineKeyStore.withStorage(FakeSecureStorage()), storageGuard: guard);
    records = DownloadRecordsStore();
    client = FakeTransferClient(tempRoot.path);
    endpoint = _StreamEndpoint();
    await endpoint.start();
    engine = NativeDownloadEngine(service, client, guard, records);
    progress = [];
  });

  tearDown(() async {
    await engine.dispose();
    await client.close();
    await endpoint.stop();
    await Hive.close();
    try {
      tempRoot.deleteSync(recursive: true);
    } catch (_) {}
  });

  DownloadRequest request({String title = 'Algebra 1'}) => DownloadRequest(
    lessonId: lessonId,
    videoUrl: endpoint.url,
    studentId: studentId,
    deviceUuid: deviceUuid,
    accessToken: () async => 'token-1',
    title: title,
  );

  Future<DownloadOutcome> start() => engine.start(request(), onProgress: progress.add);

  /// Lets the engine's async steps (URL probe, enqueue, file I/O) settle.
  Future<void> settle() async {
    for (int i = 0; i < 5; i++) {
      await pumpEventQueue();
      await Future<void>.delayed(const Duration(milliseconds: 20));
    }
  }

  Future<Uint8List> playBytes() async {
    final OfflinePlaybackSource s = await service.prepareOfflinePlayback(
      lessonId: lessonId,
      studentId: studentId,
      deviceUuid: deviceUuid,
    );
    final BytesBuilder b = BytesBuilder(copy: false);
    for (int i = 0; i < s.chunkCount; i++) {
      b.add(decryptSourceChunk(s, i));
    }
    return b.takeBytes();
  }

  group('starting a transfer', () {
    test('hands the OS a task for the signed CDN URL, into the lesson directory', () async {
      unawaited(start());
      await settle();

      expect(client.readyCalls, 1);
      final TransferTask task = client.enqueued.single;
      expect(task.taskId, lessonId);
      expect(task.url, 'https://cdn.test/sig-1/play_720p.mp4');
      expect(task.directory, 'edushield_videos/$lessonId');
      expect(task.filename, EncryptedDownloadService.partFileName);
      expect(task.displayName, 'Algebra 1');
      expect(task.headers['Referer'], 'https://iframe.mediadelivery.net/');
      expect(task.headers.containsKey('Authorization'), isFalse, reason: 'a signed CDN URL needs no session');
      engine.cancel(lessonId);
    });

    test('a dev backend that streams bytes itself gets the session and device headers', () async {
      endpoint.dev = true;
      unawaited(start());
      await settle();

      final TransferTask task = client.enqueued.single;
      expect(task.url, endpoint.url);
      expect(task.headers['Authorization'], 'Bearer token-1');
      expect(task.headers['X-Device-ID'], deviceUuid);
      engine.cancel(lessonId);
    });
  });

  group('a completed transfer', () {
    test('is verified, encrypted and recorded — and plays back byte-exact', () async {
      final Uint8List video = body(1024 * 1024 + 4321);
      final Future<DownloadOutcome> outcome = start();
      await settle();

      client.succeed(lessonId, video);

      expect(await outcome, DownloadOutcome.completed);
      expect(service.isDownloaded(lessonId), isTrue);
      expect(Hive.box(EncryptedDownloadService.boxName).get(lessonId)['format'], 2);
      expect(await playBytes(), equals(video));
      expect(client.forgotten, contains(lessonId), reason: 'the native record is cleaned up');
      expect(engine.isActive(lessonId), isFalse);
    });

    test('progress maps the transfer to 0-85% and encryption to 85-100%', () async {
      final Uint8List video = body(300 * 1024);
      final Future<DownloadOutcome> outcome = start();
      await settle();

      client.progress(lessonId, 0.5, video.length);
      await settle();
      expect(progress.last.fraction, closeTo(0.425, 0.001));
      expect(progress.last.bytesReceived, video.length ~/ 2);
      expect(progress.last.totalBytes, video.length);

      client.writeDownloadedFile(lessonId, video);
      client.status(lessonId, TransferStatus.complete);
      await outcome;
      expect(progress.last.fraction, 1.0);
      expect(progress.where((p) => p.fraction > 0.85), isNotEmpty, reason: 'encryption reports its own progress');
    });

    test('a file shorter than the advertised size is rejected, not encrypted', () async {
      final Future<DownloadOutcome> outcome = start();
      await settle();

      client.progress(lessonId, 0.2, 5000);
      client.writeDownloadedFile(lessonId, body(3000));
      client.status(lessonId, TransferStatus.complete);

      await expectLater(outcome, throwsA(isA<IncompleteDownloadException>()));
      expect(service.isDownloaded(lessonId), isFalse);
    });
  });

  group('pause and cancel', () {
    test('a pause we asked for ends as paused', () async {
      final Future<DownloadOutcome> outcome = start();
      await settle();

      engine.pause(lessonId);

      expect(await outcome, DownloadOutcome.paused);
      expect(client.pauseCalls, [lessonId]);
    });

    test('when the OS cannot pause, the task is stopped and still reported as paused', () async {
      client.pauseSucceeds = false;
      final Future<DownloadOutcome> outcome = start();
      await settle();

      engine.pause(lessonId);

      expect(await outcome, DownloadOutcome.paused);
      expect(client.cancelCalls, [lessonId]);
    });

    test('a pause the OS made on its own is reported as a network problem', () async {
      // The cubit then waits for the network and restarts the lesson.
      final Future<DownloadOutcome> outcome = start();
      await settle();

      client.status(lessonId, TransferStatus.paused);

      await expectLater(outcome, throwsA(isA<SocketException>()));
    });

    test('cancel ends as canceled and removes the lesson files', () async {
      final Future<DownloadOutcome> outcome = start();
      await settle();
      client.writeDownloadedFile(lessonId, body(100)); // a partial on disk

      engine.cancel(lessonId);

      expect(await outcome, DownloadOutcome.canceled);
      expect(Directory('${tempRoot.path}/edushield_videos/$lessonId').existsSync(), isFalse);
    });
  });

  group('failures', () {
    test('an expired signature (403) is retried once with a freshly signed URL', () async {
      final Uint8List video = body(50 * 1024);
      final Future<DownloadOutcome> outcome = start();
      await settle();

      client.status(lessonId, TransferStatus.failed, http: 403, kind: TransferErrorKind.http);
      await settle();

      expect(client.enqueued.map((t) => t.url), [
        'https://cdn.test/sig-1/play_720p.mp4',
        'https://cdn.test/sig-2/play_720p.mp4',
      ]);
      client.succeed(lessonId, video);
      expect(await outcome, DownloadOutcome.completed);
    });

    test('a second 403 with a fresh URL is a real failure', () async {
      final Future<DownloadOutcome> outcome = start();
      await settle();

      client.status(lessonId, TransferStatus.failed, http: 403, kind: TransferErrorKind.http);
      await settle();
      client.status(lessonId, TransferStatus.failed, http: 403, kind: TransferErrorKind.http);

      await expectLater(outcome, throwsA(isA<NativeTransferException>()));
      expect(client.enqueued, hasLength(2));
    });

    test('a connection failure surfaces as a network error', () async {
      final Future<DownloadOutcome> outcome = start();
      await settle();

      client.status(lessonId, TransferStatus.failed, kind: TransferErrorKind.connection, message: 'unreachable');

      await expectLater(outcome, throwsA(isA<SocketException>()));
    });

    test('a download that cannot fit is cancelled as soon as its size is known', () async {
      guard.free = 1000;
      final Future<DownloadOutcome> outcome = start();
      await settle();

      client.progress(lessonId, 0.01, 10 * 1024 * 1024);

      await expectLater(outcome, throwsA(isA<InsufficientStorageException>()));
      expect(client.cancelCalls, [lessonId]);
    });

    test('a full disk reported by the OS is an insufficient-storage failure', () async {
      final Future<DownloadOutcome> outcome = start();
      await settle();

      client.status(
        lessonId,
        TransferStatus.failed,
        kind: TransferErrorKind.fileSystem,
        message: 'No space left on device',
      );

      await expectLater(outcome, throwsA(isA<InsufficientStorageException>()));
    });
  });

  group('after an app restart', () {
    test('a transfer that FINISHED while the app was dead is finalized, not re-downloaded', () async {
      final Uint8List video = body(200 * 1024);
      client.snapshots[lessonId] = TransferSnapshot(TransferStatus.complete, video.length);
      client.writeDownloadedFile(lessonId, video, directory: 'edushield_videos/$lessonId');

      expect(await start(), DownloadOutcome.completed);

      expect(client.enqueued, isEmpty);
      expect(await playBytes(), equals(video));
    });

    test('a transfer still RUNNING natively is attached to, not restarted', () async {
      final Uint8List video = body(80 * 1024);
      client.snapshots[lessonId] = const TransferSnapshot(TransferStatus.running, 0);
      final Future<DownloadOutcome> outcome = start();
      await settle();

      expect(client.enqueued, isEmpty);
      client.progress(lessonId, 0.9, video.length);
      client.writeDownloadedFile(lessonId, video, directory: 'edushield_videos/$lessonId');
      client.status(lessonId, TransferStatus.complete);

      expect(await outcome, DownloadOutcome.completed);
    });

    test('a PAUSED native transfer is resumed from its partial', () async {
      client.snapshots[lessonId] = const TransferSnapshot(TransferStatus.paused, 0);
      unawaited(start());
      await settle();

      expect(client.resumeCalls, [lessonId]);
      expect(client.enqueued, isEmpty);
      engine.cancel(lessonId);
    });

    test('a paused transfer that can no longer resume starts over', () async {
      client.snapshots[lessonId] = const TransferSnapshot(TransferStatus.paused, 0);
      client.resumeSucceeds = false;
      unawaited(start());
      await settle();

      expect(client.enqueued, hasLength(1));
      engine.cancel(lessonId);
    });

    test('paused native tasks with no pending download are cleaned up; others are kept', () async {
      client.paused.addAll(['orphan', lessonId]);
      await records.put(DownloadRecord.queued(lessonId: lessonId, videoUrl: endpoint.url));
      unawaited(start());
      await settle();

      expect(client.cancelCalls, contains('orphan'));
      expect(client.forgotten, contains('orphan'));
      expect(client.cancelCalls, isNot(contains(lessonId)));
      engine.cancel(lessonId);
    });
  });
}
