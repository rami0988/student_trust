import 'dart:async';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:mobile_template/core/error/failures.dart';
import 'package:mobile_template/core/services/connectivity_service.dart';
import 'package:mobile_template/core/utils/request_result.dart';
import 'package:mobile_template/features/downloads/data/local/offline_key_store.dart';
import 'package:mobile_template/features/downloads/data/services/download_revalidator.dart';
import 'package:mobile_template/features/downloads/data/services/encrypted_download_service.dart';
import 'package:mobile_template/features/downloads/domain/entities/download_verdict.dart';
import 'package:mobile_template/features/downloads/domain/repositories/downloads_repository.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../../helpers/fake_secure_storage.dart';

/// Answers batch validation from a script; records every request.
class _FakeDownloadsRepository extends Fake implements DownloadsRepository {
  final Map<String, DownloadVerdict> verdicts = {};
  Failure? failWith;
  final List<List<String>> requests = [];

  @override
  Future<RequestResult<Map<String, DownloadVerdict>>> validateDownloads(List<String> lessonIds) async {
    requests.add(List<String>.of(lessonIds));
    final Failure? f = failWith;
    if (f != null) return FailureResult<Map<String, DownloadVerdict>>(f);
    return SuccessResult<Map<String, DownloadVerdict>>({
      for (final String id in lessonIds)
        if (verdicts.containsKey(id)) id: verdicts[id]!,
    });
  }
}

class _FakeConnectivity extends Fake implements ConnectivityService {
  final StreamController<bool> controller = StreamController<bool>.broadcast();

  @override
  Stream<bool> get isOnline => controller.stream;
}

class _FakePathProvider extends PathProviderPlatform with MockPlatformInterfaceMixin {
  final String root;
  _FakePathProvider(this.root);

  @override
  Future<String?> getApplicationDocumentsPath() async => root;

  @override
  Future<String?> getTemporaryPath() async => '$root/tmp';
}

void main() {
  late Directory tempRoot;
  late Box box;
  late EncryptedDownloadService service;
  late _FakeDownloadsRepository repository;
  late _FakeConnectivity connectivity;
  late DownloadRevalidator revalidator;
  late DateTime now;
  bool signedIn = true;

  setUp(() async {
    tempRoot = await Directory.systemTemp.createTemp('revalidator_');
    Directory('${tempRoot.path}/tmp').createSync(recursive: true);
    PathProviderPlatform.instance = _FakePathProvider(tempRoot.path);
    Hive.init('${tempRoot.path}/hive');
    box = await Hive.openBox(EncryptedDownloadService.boxName);
    service = EncryptedDownloadService(keyStore: OfflineKeyStore.withStorage(FakeSecureStorage()));
    repository = _FakeDownloadsRepository();
    connectivity = _FakeConnectivity();
    revalidator = DownloadRevalidator(service, repository, connectivity);
    now = DateTime(2026, 10, 8, 9);
    signedIn = true;
    DownloadRevalidator.clock = () => now;
    DownloadRevalidator.hasSession = () async => signedIn;
  });

  tearDown(() async {
    await revalidator.stop();
    await connectivity.controller.close();
    DownloadRevalidator.clock = DateTime.now;
    await Hive.close();
    try {
      tempRoot.deleteSync(recursive: true);
    } catch (_) {}
  });

  /// A completed download, [downloadedDaysAgo] / [validatedDaysAgo] old.
  Future<void> downloaded(String id, {int downloadedDaysAgo = 1, int validatedDaysAgo = 1}) async {
    Directory('${tempRoot.path}/edushield_videos/$id').createSync(recursive: true);
    final DateTime real = DateTime.now();
    await box.put(id, {
      'lessonId': id,
      'title': 'Lesson $id',
      'chunkCount': 1,
      'format': 2,
      'isComplete': true,
      'downloadedAt': real.subtract(Duration(days: downloadedDaysAgo)).toIso8601String(),
      'lastValidatedAt': real.subtract(Duration(days: validatedDaysAgo)).toIso8601String(),
    });
  }

  bool isLocked(String id) => service.getDownloadedLessons().firstWhere((l) => l.lessonId == id).isLocked;

  group('verdicts', () {
    test('a valid verdict lifts the 7-day lock without opening the lesson', () async {
      await downloaded('a', downloadedDaysAgo: 10, validatedDaysAgo: 9);
      expect(isLocked('a'), isTrue);
      repository.verdicts['a'] = const DownloadVerdict(isValid: true);

      final RevalidationReport report = await revalidator.revalidate(force: true);

      expect(report.validated, ['a']);
      expect(isLocked('a'), isFalse);
      expect(service.isDownloaded('a'), isTrue);
    });

    test('a revoked lesson (subscription ended, grade, deleted) is removed', () async {
      for (final String id in ['unsub', 'grade', 'gone']) {
        await downloaded(id);
      }
      repository.verdicts
        ..['unsub'] = const DownloadVerdict(isValid: false, reason: 'NOT_SUBSCRIBED')
        ..['grade'] = const DownloadVerdict(isValid: false, reason: 'GRADE_ACCESS_DENIED')
        ..['gone'] = const DownloadVerdict(isValid: false, reason: 'LESSON_NOT_FOUND');

      final RevalidationReport report = await revalidator.revalidate(force: true);

      expect(report.removed, unorderedEquals(['unsub', 'grade', 'gone']));
      expect(service.getDownloadedLessons(), isEmpty);
      expect(Directory('${tempRoot.path}/edushield_videos/unsub').existsSync(), isFalse);
    });

    test('a lesson the server did not answer for is left exactly as it was', () async {
      await downloaded('a', downloadedDaysAgo: 10, validatedDaysAgo: 9);

      await revalidator.revalidate(force: true);

      expect(service.isDownloaded('a'), isTrue);
      expect(isLocked('a'), isTrue, reason: 'no verdict = no change, either way');
    });
  });

  group('safety: no verdict never deletes', () {
    test('a failed request changes nothing', () async {
      await downloaded('a');
      repository.failWith = const NetworkFailure('offline', null);

      final RevalidationReport report = await revalidator.revalidate(force: true);

      expect(report.reachedServer, isFalse);
      expect(report.removed, isEmpty);
      expect(service.isDownloaded('a'), isTrue);
    });

    test('a server error changes nothing', () async {
      await downloaded('a');
      repository.failWith = const ServerFailure('boom', 500);

      await revalidator.revalidate(force: true);

      expect(service.isDownloaded('a'), isTrue);
    });

    test('without a session nothing is sent to the server', () async {
      await downloaded('a');
      signedIn = false;

      await revalidator.revalidate(force: true);

      expect(repository.requests, isEmpty);
    });
  });

  group('30-day hard cap', () {
    test('expired downloads are purged locally even offline and without a session', () async {
      await downloaded('old', downloadedDaysAgo: 31, validatedDaysAgo: 0);
      await downloaded('fresh', downloadedDaysAgo: 2);
      signedIn = false;

      final RevalidationReport report = await revalidator.revalidate(force: true);

      expect(report.expired, ['old']);
      expect(service.isDownloaded('old'), isFalse);
      expect(service.isDownloaded('fresh'), isTrue);
    });
  });

  group('scheduling', () {
    test('passes are throttled to one per 15 minutes; force and the interval bypass it', () async {
      await downloaded('a');

      await revalidator.revalidate(force: true);
      await revalidator.revalidate();
      expect(repository.requests, hasLength(1), reason: 'throttled');

      await revalidator.revalidate(force: true);
      expect(repository.requests, hasLength(2), reason: 'force bypasses the throttle');

      now = now.add(const Duration(minutes: 16));
      await revalidator.revalidate();
      expect(repository.requests, hasLength(3), reason: 'the interval has passed');
    });

    test('a large library is checked in batches of at most 100', () async {
      for (int i = 0; i < 230; i++) {
        await downloaded('l$i');
      }

      await revalidator.revalidate(force: true);

      expect(repository.requests.map((r) => r.length), [100, 100, 30]);
    });

    test('concurrent calls share one pass', () async {
      await downloaded('a');

      await Future.wait([revalidator.revalidate(force: true), revalidator.revalidate(force: true)]);

      expect(repository.requests, hasLength(1));
    });

    test('start() checks at launch and again when connectivity returns', () async {
      await downloaded('a');

      revalidator.start();
      await pumpEventQueue();
      expect(repository.requests, hasLength(1), reason: 'launch pass');

      now = now.add(const Duration(minutes: 20));
      connectivity.controller.add(false);
      await pumpEventQueue();
      expect(repository.requests, hasLength(1), reason: 'going offline does nothing');

      connectivity.controller.add(true);
      await pumpEventQueue();
      expect(repository.requests, hasLength(2), reason: 'coming back online re-checks');
    });
  });
}
