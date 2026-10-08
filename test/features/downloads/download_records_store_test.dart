import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';
import 'package:mobile_template/features/downloads/data/local/download_records_store.dart';
import 'package:mobile_template/features/downloads/data/models/download_record.dart';
import 'package:mobile_template/hive/hive_registrar.g.dart';

void main() {
  late Directory tempRoot;
  late DownloadRecordsStore store;

  setUpAll(() => Hive.registerAdapters());

  setUp(() async {
    tempRoot = await Directory.systemTemp.createTemp('records_test_');
    Hive.init(tempRoot.path);
    await Hive.openBox<DownloadRecord>(DownloadRecordsStore.boxName);
    store = DownloadRecordsStore();
  });

  tearDown(() async {
    await Hive.close();
    try {
      tempRoot.deleteSync(recursive: true);
    } catch (_) {}
  });

  DownloadRecord queued(String id, {DateTime? at}) => DownloadRecord.queued(
    lessonId: id,
    videoUrl: 'https://api.test/video/stream/$id',
    title: 'Lesson $id',
    durationSeconds: 600,
    now: at ?? DateTime(2026, 1, 1),
  );

  group('basic storage', () {
    test('put / get / contains round-trip every field', () async {
      await store.put(queued('a'));

      final DownloadRecord? r = store.get('a');
      expect(store.contains('a'), isTrue);
      expect(r, isNotNull);
      expect(r!.title, 'Lesson a');
      expect(r.videoUrl, 'https://api.test/video/stream/a');
      expect(r.durationSeconds, 600);
      expect(r.status, DownloadRecordStatus.queued);
      expect(r.bytesReceived, 0);
    });

    test('all() returns records in the order they were requested', () async {
      await store.put(queued('late', at: DateTime(2026, 1, 3)));
      await store.put(queued('early', at: DateTime(2026, 1, 1)));
      await store.put(queued('middle', at: DateTime(2026, 1, 2)));

      expect(store.all().map((r) => r.lessonId), ['early', 'middle', 'late']);
    });

    test('records survive the box being closed and reopened (an app kill)', () async {
      await store.put(queued('a'));
      await store.transition('a', DownloadRecordStatus.downloading, bytesReceived: 1234, totalBytes: 9999);

      await Hive.close();
      Hive.init(tempRoot.path);
      await Hive.openBox<DownloadRecord>(DownloadRecordsStore.boxName);

      final DownloadRecord? r = DownloadRecordsStore().get('a');
      expect(r?.status, DownloadRecordStatus.downloading);
      expect(r?.bytesReceived, 1234);
      expect(r?.totalBytes, 9999);
    });

    test('remove and clear', () async {
      await store.put(queued('a'));
      await store.put(queued('b'));

      await store.remove('a');
      expect(store.contains('a'), isFalse);
      expect(store.contains('b'), isTrue);

      await store.clear();
      expect(store.all(), isEmpty);
    });
  });

  group('state transitions', () {
    test('a legal transition is applied and stored', () async {
      await store.put(queued('a'));

      final DownloadRecord? r = await store.transition('a', DownloadRecordStatus.downloading);

      expect(r?.status, DownloadRecordStatus.downloading);
      expect(store.get('a')?.status, DownloadRecordStatus.downloading);
    });

    test('an illegal transition is refused and nothing changes', () async {
      // A late callback must not jump a paused download straight back into
      // "downloading" — it has to be re-queued first.
      await store.put(queued('a'));
      await store.transition('a', DownloadRecordStatus.paused);

      final DownloadRecord? r = await store.transition('a', DownloadRecordStatus.downloading);

      expect(r, isNull);
      expect(store.get('a')?.status, DownloadRecordStatus.paused);
    });

    test('a transition on a missing record is a no-op, not a crash', () async {
      expect(await store.transition('ghost', DownloadRecordStatus.queued), isNull);
      expect(store.contains('ghost'), isFalse);
    });

    test('progress checkpoints (same status) update bytes', () async {
      await store.put(queued('a'));
      await store.transition('a', DownloadRecordStatus.downloading);

      await store.transition('a', DownloadRecordStatus.downloading, bytesReceived: 500, totalBytes: 1000);

      expect(store.get('a')?.bytesReceived, 500);
      expect(store.get('a')?.totalBytes, 1000);
    });

    test('an error is stored with a failure and cleared on the next transition', () async {
      await store.put(queued('a'));
      await store.transition('a', DownloadRecordStatus.failed, error: 'boom');
      expect(store.get('a')?.error, 'boom');

      await store.transition('a', DownloadRecordStatus.queued);
      expect(store.get('a')?.error, isNull);
    });

    test('the transition table allows re-queueing and refuses skipped steps', () {
      for (final DownloadRecordStatus from in DownloadRecordStatus.values) {
        expect(DownloadRecordsStore.canTransition(from, from), isTrue, reason: 'staying put is always allowed ($from)');
      }
      expect(DownloadRecordsStore.canTransition(DownloadRecordStatus.paused, DownloadRecordStatus.queued), isTrue);
      expect(DownloadRecordsStore.canTransition(DownloadRecordStatus.failed, DownloadRecordStatus.queued), isTrue);
      expect(
        DownloadRecordsStore.canTransition(DownloadRecordStatus.waitingForNetwork, DownloadRecordStatus.queued),
        isTrue,
      );
      expect(
        DownloadRecordsStore.canTransition(DownloadRecordStatus.failed, DownloadRecordStatus.downloading),
        isFalse,
      );
      expect(DownloadRecordsStore.canTransition(DownloadRecordStatus.paused, DownloadRecordStatus.failed), isFalse);
    });
  });

  group('recovery after restart', () {
    test('an interrupted download is re-queued; everything else keeps its status', () async {
      await store.put(queued('was-downloading'));
      await store.transition('was-downloading', DownloadRecordStatus.downloading, bytesReceived: 42);
      await store.put(queued('was-paused'));
      await store.transition('was-paused', DownloadRecordStatus.paused);
      await store.put(queued('was-waiting'));
      await store.transition('was-waiting', DownloadRecordStatus.waitingForNetwork);
      await store.put(queued('was-queued'));

      final List<DownloadRecord> recovered = await store.recoverAfterRestart();
      final Map<String, DownloadRecordStatus> byId = {for (final r in recovered) r.lessonId: r.status};

      expect(byId['was-downloading'], DownloadRecordStatus.queued);
      expect(byId['was-paused'], DownloadRecordStatus.paused);
      expect(byId['was-waiting'], DownloadRecordStatus.waitingForNetwork);
      expect(byId['was-queued'], DownloadRecordStatus.queued);
      // The byte checkpoint survives, so the UI can show where it stopped.
      expect(store.get('was-downloading')?.bytesReceived, 42);
    });
  });
}
