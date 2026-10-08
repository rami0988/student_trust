import 'dart:async';
import 'dart:io';

import 'package:bloc_test/bloc_test.dart';
import 'package:dio/dio.dart';
import 'package:event_bus/event_bus.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:mobile_template/core/di/di.dart';
import 'package:mobile_template/core/event_bus/account_deactivated_event.dart';
import 'package:mobile_template/core/services/connectivity_service.dart';
import 'package:mobile_template/core/services/device_service.dart';
import 'package:mobile_template/core/utils/local_storage_keys.dart';
import 'package:mobile_template/core/utils/request_result.dart';
import 'package:mobile_template/features/downloads/data/local/download_records_store.dart';
import 'package:mobile_template/features/downloads/data/local/offline_key_store.dart';
import 'package:mobile_template/features/downloads/data/models/download_record.dart';
import 'package:mobile_template/features/downloads/data/services/download_engine.dart';
import 'package:mobile_template/features/downloads/data/services/encrypted_download_service.dart';
import 'package:mobile_template/features/downloads/data/services/storage_guard.dart';
import 'package:mobile_template/features/downloads/domain/entities/download_item.dart';
import 'package:mobile_template/features/downloads/domain/repositories/downloads_repository.dart';
import 'package:mobile_template/features/downloads/presentation/cubit/download_cubit.dart';
import 'package:mobile_template/features/downloads/presentation/cubit/download_state.dart';
import 'package:mobile_template/generated/l10n.dart';
import 'package:mobile_template/hive/hive_registrar.g.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../helpers/fake_secure_storage.dart';

// ---------------------------------------------------------------------------
// Fakes
// ---------------------------------------------------------------------------

/// A scriptable engine: each `start` hangs until the test completes or fails
/// it, and the test drives progress through the captured callback.
class _FakeEngine implements DownloadEngine {
  final Map<String, Completer<DownloadOutcome>> _pending = {};
  final Map<String, void Function(TransferProgress)> _progress = {};
  final List<String> started = [];
  final List<String> cancelled = [];

  @override
  Future<DownloadOutcome> start(DownloadRequest request, {required void Function(TransferProgress) onProgress}) {
    started.add(request.lessonId);
    _progress[request.lessonId] = onProgress;
    final Completer<DownloadOutcome> c = Completer<DownloadOutcome>();
    _pending[request.lessonId] = c;
    return c.future;
  }

  void progress(String id, {required int bytes, required int total, double? fraction}) => _progress[id]!(
    TransferProgress(fraction: fraction ?? bytes / total * 0.85, bytesReceived: bytes, totalBytes: total),
  );

  void finish(String id, DownloadOutcome outcome) => _pending.remove(id)?.complete(outcome);

  void fail(String id, Object error) => _pending.remove(id)?.completeError(error);

  @override
  void pause(String lessonId) => finish(lessonId, DownloadOutcome.paused);

  @override
  void cancel(String lessonId) {
    cancelled.add(lessonId);
    finish(lessonId, DownloadOutcome.canceled);
  }

  @override
  bool isActive(String lessonId) => _pending.containsKey(lessonId);
}

class _FakeDownloadsRepository extends Fake implements DownloadsRepository {
  final List<String> registered = [];

  @override
  Future<RequestResult<void>> registerDownload({
    required String lessonId,
    required String deviceUuid,
    required int chunkCount,
  }) async {
    registered.add(lessonId);
    return const SuccessResult<void>(null);
  }
}

class _FakeDeviceService extends Fake implements DeviceService {
  @override
  Future<String> getDeviceUuid() async => 'device-1';
}

class _FakeConnectivity extends Fake implements ConnectivityService {
  bool internet = true;
  final StreamController<bool> controller = StreamController<bool>.broadcast();

  @override
  Future<bool> hasInternet() async => internet;

  @override
  Stream<bool> get isOnline => controller.stream;
}

class _InMemorySecureStorage extends FlutterSecureStorage {
  final Map<String, String> store = <String, String>{};

  @override
  Future<String?> read({
    required String key,
    AppleOptions? iOptions,
    AndroidOptions? aOptions,
    LinuxOptions? lOptions,
    WebOptions? webOptions,
    AppleOptions? mOptions,
    WindowsOptions? wOptions,
  }) async => store[key];
}

class _FakePathProvider extends PathProviderPlatform with MockPlatformInterfaceMixin {
  final String root;
  _FakePathProvider(this.root);

  @override
  Future<String?> getApplicationDocumentsPath() async => root;

  @override
  Future<String?> getTemporaryPath() async => '$root/tmp';
}

// ---------------------------------------------------------------------------

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late Directory tempRoot;
  late _FakeEngine engine;
  late EncryptedDownloadService service;
  late DownloadRecordsStore records;
  late _FakeDownloadsRepository repository;
  late _FakeConnectivity connectivity;
  late EventBus eventBus;
  late DateTime now;

  const int mb = 1024 * 1024;

  setUpAll(() async {
    Hive.registerAdapters();
    await S.load(const Locale('en'));

    SharedPreferences.setMockInitialValues({});
    if (!getIt.isRegistered<SharedPreferences>()) {
      getIt.registerSingleton<SharedPreferences>(await SharedPreferences.getInstance());
    }
    final _InMemorySecureStorage secure = _InMemorySecureStorage()
      ..store[LocalStorageKeys.userId] = 'student-1'
      ..store[LocalStorageKeys.accessToken] = 'token';
    if (getIt.isRegistered<FlutterSecureStorage>()) await getIt.unregister<FlutterSecureStorage>();
    getIt.registerSingleton<FlutterSecureStorage>(secure);
  });

  setUp(() async {
    tempRoot = await Directory.systemTemp.createTemp('cubit_test_');
    Directory('${tempRoot.path}/tmp').createSync(recursive: true);
    PathProviderPlatform.instance = _FakePathProvider(tempRoot.path);
    Hive.init('${tempRoot.path}/hive');
    await Hive.openBox(EncryptedDownloadService.boxName);
    await Hive.openBox<DownloadRecord>(DownloadRecordsStore.boxName);

    engine = _FakeEngine();
    service = EncryptedDownloadService(keyStore: OfflineKeyStore.withStorage(FakeSecureStorage()));
    records = DownloadRecordsStore();
    repository = _FakeDownloadsRepository();
    connectivity = _FakeConnectivity();
    eventBus = EventBus();

    now = DateTime(2026, 10, 1, 12);
    DownloadCubit.clock = () => now;
  });

  tearDown(() async {
    DownloadCubit.clock = DateTime.now;
    await connectivity.controller.close();
    await Hive.close();
    try {
      tempRoot.deleteSync(recursive: true);
    } catch (_) {}
  });

  DownloadCubit build() =>
      DownloadCubit(engine, service, records, repository, _FakeDeviceService(), connectivity, eventBus);

  /// Hive persists with real file I/O, which `pumpEventQueue` alone doesn't
  /// wait for — give pending disk writes a moment to land, then drain.
  Future<void> settle() async {
    await pumpEventQueue();
    await Future<void>.delayed(const Duration(milliseconds: 30));
    await pumpEventQueue();
  }

  Future<void> start(DownloadCubit cubit, String id) async {
    await cubit.startDownload(lessonId: id, videoUrl: 'https://api.test/video/stream/$id', title: 'Lesson $id');
    await settle();
  }

  group('persistence', () {
    test('a requested download is persisted BEFORE it finishes', () async {
      final DownloadCubit cubit = build();
      addTearDown(cubit.close);

      await start(cubit, 'a');

      expect(records.get('a')?.status, DownloadRecordStatus.downloading);
      expect(records.get('a')?.title, 'Lesson a');
      expect(engine.started, ['a']);
      expect(cubit.state.of('a')?.status, DownloadItemStatus.downloading);
    });

    test('completion removes the record, marks it completed and registers it', () async {
      final DownloadCubit cubit = build();
      addTearDown(cubit.close);
      await start(cubit, 'a');

      engine.finish('a', DownloadOutcome.completed);
      await settle();

      expect(records.contains('a'), isFalse);
      expect(cubit.state.of('a')?.status, DownloadItemStatus.completed);
      expect(repository.registered, ['a']);
    });

    test('a pause persists the byte position so a restart shows where it stopped', () async {
      final DownloadCubit cubit = build();
      addTearDown(cubit.close);
      await start(cubit, 'a');
      engine.progress('a', bytes: 3 * mb, total: 10 * mb);

      await cubit.pauseDownload('a');
      await settle();

      expect(cubit.state.of('a')?.status, DownloadItemStatus.paused);
      expect(records.get('a')?.status, DownloadRecordStatus.paused);
      expect(records.get('a')?.bytesReceived, 3 * mb);
      expect(records.get('a')?.totalBytes, 10 * mb);
    });

    test('at most two transfer at once; the third waits and starts when a slot frees', () async {
      final DownloadCubit cubit = build();
      addTearDown(cubit.close);
      await start(cubit, 'a');
      await start(cubit, 'b');
      await start(cubit, 'c');

      expect(engine.started, ['a', 'b']);
      expect(cubit.state.of('c')?.status, DownloadItemStatus.queued);

      engine.finish('a', DownloadOutcome.completed);
      await settle();
      expect(engine.started, ['a', 'b', 'c']);
    });

    test('cancelling a queued download drops its record without touching the engine', () async {
      final DownloadCubit cubit = build();
      addTearDown(cubit.close);
      await start(cubit, 'a');
      await start(cubit, 'b');
      await start(cubit, 'c'); // queued

      await cubit.cancelDownload('c');
      await settle();

      expect(records.contains('c'), isFalse);
      expect(cubit.state.of('c'), isNull);
      expect(engine.cancelled, isNot(contains('c')));
    });
  });

  group('restore after an app kill', () {
    Future<void> seed(String id, DownloadRecordStatus status, {int bytes = 0, int total = 0, String? error}) async {
      await records.put(
        DownloadRecord.queued(
          lessonId: id,
          videoUrl: 'https://api.test/video/stream/$id',
          title: 'Lesson $id',
          now: now,
        ),
      );
      if (status != DownloadRecordStatus.queued) {
        // Walk a legal path so the seeded record is realistic.
        if (status != DownloadRecordStatus.paused && status != DownloadRecordStatus.waitingForNetwork) {
          await records.transition(id, DownloadRecordStatus.downloading, bytesReceived: bytes, totalBytes: total);
        }
        if (status != DownloadRecordStatus.downloading) {
          await records.transition(id, status, bytesReceived: bytes, totalBytes: total, error: error);
        }
      }
    }

    blocTest<DownloadCubit, DownloadState>(
      'interrupted downloads resume, paused stay paused, waiting and failed keep their state',
      setUp: () async {
        await seed('interrupted', DownloadRecordStatus.downloading, bytes: 4 * mb, total: 10 * mb);
        await seed('paused', DownloadRecordStatus.paused, bytes: 2 * mb, total: 10 * mb);
        await seed('waiting', DownloadRecordStatus.waitingForNetwork, error: 'offline');
        await seed('failed', DownloadRecordStatus.failed, error: 'boom');
      },
      build: build,
      act: (cubit) async {
        await cubit.restore();
        await settle();
        // Checked here: blocTest closes the cubit before `verify`, and closing
        // (correctly) cancels the connectivity subscription.
        expect(connectivity.controller.hasListener, isTrue, reason: 'something is waiting, so watch the network');
      },
      verify: (cubit) {
        expect(engine.started, ['interrupted'], reason: 'only the interrupted one auto-resumes');
        expect(cubit.state.of('interrupted')?.status, DownloadItemStatus.downloading);
        expect(cubit.state.of('paused')?.status, DownloadItemStatus.paused);
        expect(cubit.state.of('paused')?.bytesReceived, 2 * mb, reason: 'the UI shows where it stopped');
        expect(cubit.state.of('waiting')?.status, DownloadItemStatus.waitingForNetwork);
        expect(cubit.state.of('failed')?.status, DownloadItemStatus.failed);
        expect(cubit.state.of('failed')?.error, 'boom');
      },
    );

    blocTest<DownloadCubit, DownloadState>(
      'a record whose lesson actually finished is cleaned up, not re-downloaded',
      setUp: () async {
        await seed('done', DownloadRecordStatus.downloading);
        await Hive.box(
          EncryptedDownloadService.boxName,
        ).put('done', {'lessonId': 'done', 'isComplete': true, 'chunkCount': 1});
      },
      build: build,
      act: (cubit) => cubit.restore(),
      verify: (cubit) {
        expect(records.contains('done'), isFalse);
        expect(engine.started, isEmpty);
      },
    );

    blocTest<DownloadCubit, DownloadState>(
      'a download purged for passing 30 days is surfaced as expired',
      setUp: () async {
        final Directory dir = Directory('${tempRoot.path}/edushield_videos/old')..createSync(recursive: true);
        File('${dir.path}/chunk_0.enc').writeAsBytesSync([1, 2, 3]);
        await Hive.box(EncryptedDownloadService.boxName).put('old', {
          'lessonId': 'old',
          'isComplete': true,
          'chunkCount': 1,
          'downloadedAt': DateTime.now().subtract(const Duration(days: 31)).toIso8601String(),
          'lastValidatedAt': DateTime.now().toIso8601String(),
        });
        await service.reconcileOnStartup();
      },
      build: build,
      act: (cubit) => cubit.restore(),
      verify: (cubit) {
        expect(cubit.state.of('old')?.status, DownloadItemStatus.expired);
        expect(cubit.state.of('old')?.error, S.current.downloadExpired);
      },
    );
  });

  group('progress throttling and speed', () {
    test('a burst of engine ticks emits at most once per 250 ms', () async {
      final DownloadCubit cubit = build();
      addTearDown(cubit.close);
      await start(cubit, 'a');

      final List<DownloadState> emitted = [];
      final StreamSubscription<DownloadState> sub = cubit.stream.listen(emitted.add);
      addTearDown(sub.cancel);

      // 100 network chunks arriving within the same instant.
      for (int i = 1; i <= 100; i++) {
        engine.progress('a', bytes: i * 1024, total: 10 * mb);
      }
      await settle();
      expect(emitted.length, 1, reason: 'only the first tick of the burst is shown');

      now = now.add(const Duration(milliseconds: 100));
      engine.progress('a', bytes: 200 * 1024, total: 10 * mb);
      await settle();
      expect(emitted.length, 1, reason: 'still inside the 250 ms window');

      now = now.add(const Duration(milliseconds: 150));
      engine.progress('a', bytes: 300 * 1024, total: 10 * mb);
      await settle();
      expect(emitted.length, 2, reason: 'the window has elapsed');
      expect(cubit.state.of('a')?.bytesReceived, 300 * 1024);
    });

    test('the final 100% tick is never throttled away', () async {
      final DownloadCubit cubit = build();
      addTearDown(cubit.close);
      await start(cubit, 'a');
      engine.progress('a', bytes: mb, total: 10 * mb);

      engine.progress('a', bytes: 10 * mb, total: 10 * mb, fraction: 1.0); // same instant
      await settle();

      expect(cubit.state.of('a')?.progress, 1.0);
    });

    test('speed and time left are derived from bytes over time', () async {
      final DownloadCubit cubit = build();
      addTearDown(cubit.close);
      await start(cubit, 'a');
      engine.progress('a', bytes: 0, total: 10 * mb);

      now = now.add(const Duration(seconds: 1));
      engine.progress('a', bytes: mb, total: 10 * mb);
      await settle();

      final DownloadItem item = cubit.state.of('a')!;
      expect(item.speedBytesPerSecond, closeTo(mb, 1));
      expect(item.remaining, const Duration(seconds: 9));
    });
  });

  group('network resilience', () {
    test('with no internet, a failed transfer WAITS instead of failing', () async {
      final DownloadCubit cubit = build();
      addTearDown(cubit.close);
      await start(cubit, 'a');
      connectivity.internet = false;

      engine.fail('a', const SocketException('Network is unreachable'));
      await settle();

      expect(cubit.state.of('a')?.status, DownloadItemStatus.waitingForNetwork);
      expect(records.get('a')?.status, DownloadRecordStatus.waitingForNetwork);
      expect(connectivity.controller.hasListener, isTrue);
    });

    test('it resumes by itself when the connection returns', () async {
      final DownloadCubit cubit = build();
      addTearDown(cubit.close);
      await start(cubit, 'a');
      connectivity.internet = false;
      engine.fail(
        'a',
        DioException.connectionError(
          requestOptions: RequestOptions(path: '/'),
          reason: 'down',
        ),
      );
      await settle();

      connectivity.internet = true;
      connectivity.controller.add(true);
      await settle();

      expect(engine.started, ['a', 'a'], reason: 'the same lesson was started again');
      expect(cubit.state.of('a')?.status, DownloadItemStatus.downloading);
      expect(connectivity.controller.hasListener, isFalse, reason: 'nothing waits any more, so stop polling');
    });

    test('a network error while ONLINE is a real failure', () async {
      final DownloadCubit cubit = build();
      addTearDown(cubit.close);
      await start(cubit, 'a');
      connectivity.internet = true;

      engine.fail('a', const SocketException('Connection reset'));
      await settle();

      expect(cubit.state.of('a')?.status, DownloadItemStatus.failed);
      expect(records.get('a')?.status, DownloadRecordStatus.failed);
    });

    test('a server rejection is a failure even when offline is suspected', () async {
      final DownloadCubit cubit = build();
      addTearDown(cubit.close);
      await start(cubit, 'a');
      connectivity.internet = false;

      engine.fail(
        'a',
        DioException.badResponse(
          statusCode: 403,
          requestOptions: RequestOptions(path: '/'),
          response: Response<dynamic>(requestOptions: RequestOptions(path: '/'), statusCode: 403),
        ),
      );
      await settle();

      expect(cubit.state.of('a')?.status, DownloadItemStatus.failed);
    });

    test('pausing a waiting download stops it waiting', () async {
      final DownloadCubit cubit = build();
      addTearDown(cubit.close);
      await start(cubit, 'a');
      connectivity.internet = false;
      engine.fail('a', const SocketException('down'));
      await settle();

      await cubit.pauseDownload('a');
      await settle();

      expect(cubit.state.of('a')?.status, DownloadItemStatus.paused);
      expect(records.get('a')?.status, DownloadRecordStatus.paused);
      expect(connectivity.controller.hasListener, isFalse);
    });
  });

  group('typed failures', () {
    test('insufficient storage fails with a "free up space" message', () async {
      final DownloadCubit cubit = build();
      addTearDown(cubit.close);
      await start(cubit, 'a');

      engine.fail('a', const InsufficientStorageException(500 * mb, 100 * mb));
      await settle();

      expect(cubit.state.of('a')?.status, DownloadItemStatus.failed);
      expect(cubit.state.of('a')?.error, S.current.insufficientStorage);
      expect(records.contains('a'), isTrue, reason: 'kept so it can resume once space is freed');
    });
  });

  group('account deactivation', () {
    blocTest<DownloadCubit, DownloadState>(
      'AccountDeactivatedEvent purges every download, record and in-flight transfer',
      setUp: () async {
        final Directory dir = Directory('${tempRoot.path}/edushield_videos/done')..createSync(recursive: true);
        File('${dir.path}/chunk_0.enc').writeAsBytesSync([1, 2, 3]);
        await Hive.box(
          EncryptedDownloadService.boxName,
        ).put('done', {'lessonId': 'done', 'isComplete': true, 'chunkCount': 1});
      },
      build: build,
      act: (cubit) async {
        await start(cubit, 'running');
        eventBus.fire(const AccountDeactivatedEvent());
        await settle();
      },
      verify: (cubit) {
        expect(cubit.state.items, isEmpty);
        expect(records.all(), isEmpty);
        expect(engine.cancelled, contains('running'));
        expect(service.getDownloadedLessons(), isEmpty);
        expect(Directory('${tempRoot.path}/edushield_videos').existsSync(), isFalse);
      },
    );
  });
}
