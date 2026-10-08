import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:mobile_template/core/error/failures.dart';
import 'package:mobile_template/features/downloads/data/local/offline_key_store.dart';
import 'package:mobile_template/features/downloads/data/services/encrypted_download_service.dart';
import 'package:mobile_template/features/downloads/data/services/offline_crypto.dart';
import 'package:mobile_template/features/downloads/data/services/offline_media_server.dart';
import 'package:mobile_template/features/downloads/domain/repositories/downloads_repository.dart';
import 'package:mobile_template/features/video/domain/repositories/video_repository.dart';
import 'package:mobile_template/features/video/presentation/cubit/video_cubit.dart';
import 'package:mobile_template/generated/l10n.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../../../../helpers/fake_secure_storage.dart';
import '../../../../helpers/legacy_v1_fixture.dart';

class _FakeVideoRepository extends Fake implements VideoRepository {}

class _FakeDownloadsRepository extends Fake implements DownloadsRepository {}

class _FakePathProvider extends PathProviderPlatform with MockPlatformInterfaceMixin {
  final String root;
  _FakePathProvider(this.root);

  @override
  Future<String?> getApplicationDocumentsPath() async => root;

  @override
  Future<String?> getTemporaryPath() async => '$root/tmp';
}

/// Offline playback, end to end: VideoCubit → prepareOfflinePlayback →
/// OfflineMediaServer → a real HTTP fetch of the URL the player would open.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const String lessonId = 'lesson-1';
  const String studentId = 'student-1';
  const String deviceUuid = 'device-1';
  const int mib = 1024 * 1024;

  late Directory tempRoot;
  late OfflineKeyStore keyStore;
  late EncryptedDownloadService service;
  late OfflineMediaServer server;
  late Box box;

  Uint8List bytes(int length) => Uint8List.fromList(List<int>.generate(length, (i) => (i * 17 + 3) % 256));

  setUpAll(() async {
    await S.load(const Locale('en'));
  });

  setUp(() async {
    // The test binding answers every HTTP request with 400; these tests fetch
    // from the real loopback server.
    HttpOverrides.global = null;
    tempRoot = await Directory.systemTemp.createTemp('video_cubit_offline_');
    Directory('${tempRoot.path}/tmp').createSync(recursive: true);
    PathProviderPlatform.instance = _FakePathProvider(tempRoot.path);
    Hive.init('${tempRoot.path}/hive');
    box = await Hive.openBox(EncryptedDownloadService.boxName);
    keyStore = OfflineKeyStore.withStorage(FakeSecureStorage());
    service = EncryptedDownloadService(keyStore: keyStore);
    server = OfflineMediaServer();
  });

  tearDown(() async {
    await server.release(lessonId);
    await Hive.close();
    try {
      tempRoot.deleteSync(recursive: true);
    } catch (_) {}
  });

  VideoCubit build() => VideoCubit(_FakeVideoRepository(), service, _FakeDownloadsRepository(), server);

  /// Installs a completed v2 download exactly as the service lays one out.
  Future<void> installV2(Uint8List plain) async {
    final String dir = '${tempRoot.path}/edushield_videos/$lessonId';
    Directory(dir).createSync(recursive: true);
    final File part = File('$dir/video.part')..writeAsBytesSync(plain);
    final OfflineKeyMaterial keys = OfflineKeyMaterial.generate();
    await keyStore.write(lessonId, keys);
    final int count = chunkCountFor(plain.length, v2ChunkSize);
    await encryptBatchV2InBackground(
      EncryptBatchV2(
        partPath: part.path,
        lessonDirPath: dir,
        lessonId: lessonId,
        keyBytes: keys.bytes,
        firstChunk: 0,
        endChunk: count,
        chunkCount: count,
      ),
    );
    part.deleteSync();
    final String now = DateTime.now().toIso8601String();
    await box.put(lessonId, {
      'lessonId': lessonId,
      'chunkCount': count,
      'format': 2,
      'sizeBytes': plain.length,
      'isComplete': true,
      'downloadedAt': now,
      'lastValidatedAt': now,
    });
  }

  Future<(int, Uint8List)> fetch(String url, {String? range}) async {
    final HttpClient client = HttpClient();
    try {
      final HttpClientRequest request = await client.getUrl(Uri.parse(url));
      if (range != null) request.headers.set(HttpHeaders.rangeHeader, range);
      final HttpClientResponse response = await request.close();
      final BytesBuilder body = BytesBuilder(copy: false);
      await response.forEach(body.add);
      return (response.statusCode, body.takeBytes());
    } finally {
      client.close(force: true);
    }
  }

  Future<void> loadOffline(VideoCubit cubit) =>
      cubit.loadVideo(lessonId: lessonId, isOffline: true, studentId: studentId, deviceUuid: deviceUuid);

  test('a downloaded lesson is played from a loopback URL that streams the real video', () async {
    final Uint8List plain = bytes(2 * mib + 500);
    await installV2(plain);
    final VideoCubit cubit = build();
    addTearDown(cubit.close);

    await loadOffline(cubit);

    expect(cubit.state.status.isSuccess, isTrue);
    expect(cubit.state.isLocal, isTrue);
    final String url = cubit.state.videoUrl!;
    expect(url, startsWith('http://127.0.0.1:'));
    expect(url, isNot(contains('file://')));

    final (int status, Uint8List body) = await fetch(url);
    expect(status, HttpStatus.ok);
    expect(body, equals(plain));

    final (int partialStatus, Uint8List slice) = await fetch(url, range: 'bytes=${mib - 4}-${mib + 3}');
    expect(partialStatus, HttpStatus.partialContent);
    expect(slice, equals(Uint8List.sublistView(plain, mib - 4, mib + 4)));
  });

  test('no plaintext copy is written to the cache directory', () async {
    await installV2(bytes(mib + 1));
    final VideoCubit cubit = build();
    addTearDown(cubit.close);

    await loadOffline(cubit);
    await fetch(cubit.state.videoUrl!);

    expect(Directory('${tempRoot.path}/tmp').listSync(), isEmpty);
  });

  test('closing the player stops serving the lesson and shuts the server down', () async {
    await installV2(bytes(1000));
    final VideoCubit cubit = build();
    await loadOffline(cubit);
    final String url = cubit.state.videoUrl!;
    expect(server.isRunning, isTrue);

    await cubit.close();

    expect(server.isRunning, isFalse);
    await expectLater(fetch(url), throwsA(isA<SocketException>()));
  });

  test('corruption found mid-playback removes the download and reports it', () async {
    await installV2(bytes(3 * mib));
    // Damage a middle chunk: preparation (which checks the last chunk) passes,
    // the damage only surfaces once the player reaches it.
    final File chunk = File('${tempRoot.path}/edushield_videos/$lessonId/chunk_1.v2');
    chunk.writeAsBytesSync(chunk.readAsBytesSync()..[200] ^= 0x01);
    final VideoCubit cubit = build();
    addTearDown(cubit.close);
    await loadOffline(cubit);
    expect(cubit.state.status.isSuccess, isTrue);

    final (int status, _) = await fetch(cubit.state.videoUrl!, range: 'bytes=$mib-${mib + 10}');
    await Future<void>.delayed(const Duration(milliseconds: 100));

    expect(status, HttpStatus.internalServerError);
    expect(cubit.state.status.isFailure, isTrue);
    expect(cubit.state.failure, isA<MediaCorruptedFailure>());
    expect(service.isDownloaded(lessonId), isFalse, reason: 'the damaged download is dropped so it can be re-fetched');
  });

  test('a legacy v1 download plays through the same pipeline', () async {
    final Uint8List plain = bytes(2 * mib + 77);
    final String dir = '${tempRoot.path}/edushield_videos/$lessonId';
    final int count = writeLegacyV1Chunks(
      lessonDirPath: dir,
      plain: plain,
      studentId: studentId,
      deviceUuid: deviceUuid,
      lessonId: lessonId,
    );
    await box.put(
      lessonId,
      legacyV1Meta(
        lessonId: lessonId,
        chunkCount: count,
        studentId: studentId,
        deviceUuid: deviceUuid,
        sizeBytes: plain.length,
      ),
    );
    final VideoCubit cubit = build();
    addTearDown(cubit.close);

    await loadOffline(cubit);

    expect(cubit.state.status.isSuccess, isTrue);
    final (int status, Uint8List body) = await fetch(cubit.state.videoUrl!);
    expect(status, HttpStatus.ok);
    expect(body, equals(plain));
  });

  test('past the 30-day cap the cubit reports an expired download', () async {
    await installV2(bytes(1000));
    final Map<String, dynamic> meta = Map<String, dynamic>.from(box.get(lessonId) as Map);
    meta['downloadedAt'] = DateTime.now().subtract(const Duration(days: 31)).toIso8601String();
    await box.put(lessonId, meta);
    final VideoCubit cubit = build();
    addTearDown(cubit.close);

    await loadOffline(cubit);

    expect(cubit.state.failure, isA<LicenseExpiredFailure>());
    expect(server.isRunning, isFalse, reason: 'nothing was served');
  });
}
