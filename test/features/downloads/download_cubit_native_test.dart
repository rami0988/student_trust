import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:event_bus/event_bus.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:mobile_template/core/di/di.dart';
import 'package:mobile_template/core/services/connectivity_service.dart';
import 'package:mobile_template/core/services/device_service.dart';
import 'package:mobile_template/core/utils/local_storage_keys.dart';
import 'package:mobile_template/core/utils/request_result.dart';
import 'package:mobile_template/features/downloads/data/local/download_records_store.dart';
import 'package:mobile_template/features/downloads/data/local/offline_key_store.dart';
import 'package:mobile_template/features/downloads/data/models/download_record.dart';
import 'package:mobile_template/features/downloads/data/services/background_transfer_client.dart';
import 'package:mobile_template/features/downloads/data/services/encrypted_download_service.dart';
import 'package:mobile_template/features/downloads/data/services/native_download_engine.dart';
import 'package:mobile_template/features/downloads/data/services/storage_guard.dart';
import 'package:mobile_template/features/downloads/domain/entities/download_item.dart';
import 'package:mobile_template/features/downloads/domain/repositories/downloads_repository.dart';
import 'package:mobile_template/features/downloads/presentation/cubit/download_cubit.dart';
import 'package:mobile_template/generated/l10n.dart';
import 'package:mobile_template/hive/hive_registrar.g.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/fake_secure_storage.dart';
import '../../helpers/fake_transfer_client.dart';

class _FakeDownloadsRepository extends Fake implements DownloadsRepository {
  @override
  Future<RequestResult<void>> registerDownload({
    required String lessonId,
    required String deviceUuid,
    required int chunkCount,
  }) async => const SuccessResult<void>(null);
}

class _FakeDeviceService extends Fake implements DeviceService {
  @override
  Future<String> getDeviceUuid() async => 'device-1';
}

class _FakeConnectivity extends Fake implements ConnectivityService {
  final StreamController<bool> controller = StreamController<bool>.broadcast();
  bool internet = true;

  @override
  Future<bool> hasInternet() async => internet;

  @override
  Stream<bool> get isOnline => controller.stream;
}

class _NoLimitGuard extends StorageGuard {
  @override
  Future<int?> freeBytes() async => null;
}

class _FakePathProvider extends PathProviderPlatform with MockPlatformInterfaceMixin {
  final String root;
  _FakePathProvider(this.root);

  @override
  Future<String?> getApplicationDocumentsPath() async => root;

  @override
  Future<String?> getTemporaryPath() async => '$root/tmp';
}

/// The UNCHANGED DownloadCubit running on the native engine: native transfer
/// events must turn into the right DownloadRecord transitions, and a download
/// must survive the app being killed and relaunched.
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const String lessonId = 'lesson-1';

  late Directory tempRoot;
  late HttpServer endpoint;
  late String videoUrl;
  late EncryptedDownloadService service;
  late DownloadRecordsStore records;
  late _FakeConnectivity connectivity;

  Uint8List body(int length) => Uint8List.fromList(List<int>.generate(length, (i) => (i * 7 + 1) % 256));

  setUpAll(() async {
    Hive.registerAdapters();
    await S.load(const Locale('en'));
    SharedPreferences.setMockInitialValues({});
    if (!getIt.isRegistered<SharedPreferences>()) {
      getIt.registerSingleton<SharedPreferences>(await SharedPreferences.getInstance());
    }
    final FakeSecureStorage secure = FakeSecureStorage()
      ..store[LocalStorageKeys.userId] = 'student-1'
      ..store[LocalStorageKeys.accessToken] = 'token';
    if (getIt.isRegistered<FlutterSecureStorage>()) await getIt.unregister<FlutterSecureStorage>();
    getIt.registerSingleton<FlutterSecureStorage>(secure);
  });

  setUp(() async {
    HttpOverrides.global = null;
    tempRoot = await Directory.systemTemp.createTemp('cubit_native_');
    Directory('${tempRoot.path}/tmp').createSync(recursive: true);
    PathProviderPlatform.instance = _FakePathProvider(tempRoot.path);
    Hive.init('${tempRoot.path}/hive');
    await Hive.openBox(EncryptedDownloadService.boxName);
    await Hive.openBox<DownloadRecord>(DownloadRecordsStore.boxName);

    endpoint = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    endpoint.listen((r) async {
      r.response
        ..headers.contentType = ContentType.json
        ..write(jsonEncode({'mode': 'bunnycdn', 'directUrl': 'https://cdn.test/play.mp4'}));
      await r.response.close();
    });
    videoUrl = 'http://127.0.0.1:${endpoint.port}/video/stream/$lessonId';

    service = EncryptedDownloadService(
      keyStore: OfflineKeyStore.withStorage(FakeSecureStorage()),
      storageGuard: _NoLimitGuard(),
    );
    records = DownloadRecordsStore();
    connectivity = _FakeConnectivity();
  });

  tearDown(() async {
    await connectivity.controller.close();
    await endpoint.close(force: true);
    await Hive.close();
    try {
      tempRoot.deleteSync(recursive: true);
    } catch (_) {}
  });

  /// A fresh "app process": new engine and cubit over the same disk state.
  (DownloadCubit, NativeDownloadEngine) launch(FakeTransferClient client) {
    final NativeDownloadEngine engine = NativeDownloadEngine(service, client, _NoLimitGuard(), records);
    final DownloadCubit cubit = DownloadCubit(
      engine,
      service,
      records,
      _FakeDownloadsRepository(),
      _FakeDeviceService(),
      connectivity,
      EventBus(),
    );
    return (cubit, engine);
  }

  Future<void> settle() async {
    for (int i = 0; i < 6; i++) {
      await pumpEventQueue();
      await Future<void>.delayed(const Duration(milliseconds: 25));
    }
  }

  test('native progress and completion drive the record from downloading to removed', () async {
    final FakeTransferClient client = FakeTransferClient(tempRoot.path);
    final (DownloadCubit cubit, NativeDownloadEngine engine) = launch(client);
    addTearDown(() async {
      await cubit.close();
      await engine.dispose();
      await client.close();
    });

    await cubit.startDownload(lessonId: lessonId, videoUrl: videoUrl, title: 'Lesson');
    await settle();
    expect(records.get(lessonId)?.status, DownloadRecordStatus.downloading);
    expect(client.enqueued.single.taskId, lessonId);

    client.progress(lessonId, 0.4, 100 * 1024);
    await settle();
    expect(cubit.state.of(lessonId)?.status, DownloadItemStatus.downloading);
    expect(cubit.state.of(lessonId)?.totalBytes, 100 * 1024);

    client.writeDownloadedFile(lessonId, body(100 * 1024));
    client.status(lessonId, TransferStatus.complete);
    await settle();

    expect(cubit.state.of(lessonId)?.status, DownloadItemStatus.completed);
    expect(records.contains(lessonId), isFalse);
    expect(service.isDownloaded(lessonId), isTrue);
  });

  test('a native pause becomes a paused record', () async {
    final FakeTransferClient client = FakeTransferClient(tempRoot.path);
    final (DownloadCubit cubit, NativeDownloadEngine engine) = launch(client);
    addTearDown(() async {
      await cubit.close();
      await engine.dispose();
      await client.close();
    });
    await cubit.startDownload(lessonId: lessonId, videoUrl: videoUrl, title: 'Lesson');
    await settle();

    await cubit.pauseDownload(lessonId);
    await settle();

    expect(cubit.state.of(lessonId)?.status, DownloadItemStatus.paused);
    expect(records.get(lessonId)?.status, DownloadRecordStatus.paused);
  });

  test('an OS pause while offline becomes waiting-for-network, then resumes natively', () async {
    final FakeTransferClient client = FakeTransferClient(tempRoot.path);
    final (DownloadCubit cubit, NativeDownloadEngine engine) = launch(client);
    addTearDown(() async {
      await cubit.close();
      await engine.dispose();
      await client.close();
    });
    await cubit.startDownload(lessonId: lessonId, videoUrl: videoUrl, title: 'Lesson');
    await settle();

    connectivity.internet = false;
    client.status(lessonId, TransferStatus.paused); // the OS lost the network
    await settle();
    expect(cubit.state.of(lessonId)?.status, DownloadItemStatus.waitingForNetwork);
    expect(records.get(lessonId)?.status, DownloadRecordStatus.waitingForNetwork);

    client.snapshots[lessonId] = const TransferSnapshot(TransferStatus.paused, 100 * 1024);
    connectivity.internet = true;
    connectivity.controller.add(true);
    await settle();

    expect(client.resumeCalls, [lessonId], reason: 'resumes the OS partial instead of starting over');
    expect(cubit.state.of(lessonId)?.status, DownloadItemStatus.downloading);
  });

  test('app killed mid-download, transfer finished natively — relaunch finishes it without re-downloading', () async {
    // First process: start a download, then "kill" the app.
    final FakeTransferClient first = FakeTransferClient(tempRoot.path);
    final (DownloadCubit cubitA, NativeDownloadEngine engineA) = launch(first);
    await cubitA.startDownload(lessonId: lessonId, videoUrl: videoUrl, title: 'Lesson');
    await settle();
    expect(records.get(lessonId)?.status, DownloadRecordStatus.downloading);
    await cubitA.close();
    await engineA.dispose();
    await first.close();

    // While the app was dead, the OS finished the transfer.
    final Uint8List video = body(150 * 1024);
    final FakeTransferClient second = FakeTransferClient(tempRoot.path)
      ..snapshots[lessonId] = TransferSnapshot(TransferStatus.complete, video.length);
    second.writeDownloadedFile(lessonId, video, directory: 'edushield_videos/$lessonId');

    // Second process: the app relaunches.
    await service.reconcileOnStartup(isTracked: records.contains);
    final (DownloadCubit cubitB, NativeDownloadEngine engineB) = launch(second);
    addTearDown(() async {
      await cubitB.close();
      await engineB.dispose();
      await second.close();
    });
    await cubitB.restore();
    await settle();

    expect(second.enqueued, isEmpty, reason: 'nothing is downloaded twice');
    expect(cubitB.state.of(lessonId)?.status, DownloadItemStatus.completed);
    expect(records.contains(lessonId), isFalse);
    expect(service.isDownloaded(lessonId), isTrue);
  });

  test('app killed mid-download, transfer still running natively — relaunch attaches to it', () async {
    final FakeTransferClient first = FakeTransferClient(tempRoot.path);
    final (DownloadCubit cubitA, NativeDownloadEngine engineA) = launch(first);
    await cubitA.startDownload(lessonId: lessonId, videoUrl: videoUrl, title: 'Lesson');
    await settle();
    await cubitA.close();
    await engineA.dispose();
    await first.close();

    final FakeTransferClient second = FakeTransferClient(tempRoot.path)
      ..snapshots[lessonId] = const TransferSnapshot(TransferStatus.running, 0);
    await service.reconcileOnStartup(isTracked: records.contains);
    final (DownloadCubit cubitB, NativeDownloadEngine engineB) = launch(second);
    addTearDown(() async {
      await cubitB.close();
      await engineB.dispose();
      await second.close();
    });
    await cubitB.restore();
    await settle();

    expect(second.enqueued, isEmpty, reason: 'attached, not restarted');
    expect(cubitB.state.of(lessonId)?.status, DownloadItemStatus.downloading);

    second.writeDownloadedFile(lessonId, body(60 * 1024), directory: 'edushield_videos/$lessonId');
    second.status(lessonId, TransferStatus.complete);
    await settle();
    expect(cubitB.state.of(lessonId)?.status, DownloadItemStatus.completed);
  });
}
