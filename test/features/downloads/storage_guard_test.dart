import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_template/features/downloads/data/services/storage_guard.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  const MethodChannel channel = MethodChannel('com.edushield/security');
  final TestDefaultBinaryMessenger messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

  void reportFree(Object? Function() answer) {
    messenger.setMockMethodCallHandler(channel, (call) async {
      if (call.method != 'getFreeDiskBytes') return null;
      final Object? value = answer();
      if (value is Exception) throw value;
      return value;
    });
  }

  tearDown(() => messenger.setMockMethodCallHandler(channel, null));

  const int mb = 1024 * 1024;

  group('space requirement', () {
    test('a fresh download needs ~2.1x its size (partial + encrypted copy + margin)', () {
      expect(StorageGuard.bytesStillNeeded(totalBytes: 100 * mb), (100 * mb * 2.1).ceil());
    });

    test('bytes already on disk are subtracted on resume', () {
      final int fresh = StorageGuard.bytesStillNeeded(totalBytes: 100 * mb);
      expect(StorageGuard.bytesStillNeeded(totalBytes: 100 * mb, alreadyOnDisk: 40 * mb), fresh - 40 * mb);
    });

    test('an unknown size (0) requires nothing — the check is skipped, not failed', () {
      expect(StorageGuard.bytesStillNeeded(totalBytes: 0), 0);
    });
  });

  group('ensureCanFit', () {
    test('passes when there is enough room', () async {
      reportFree(() => 1024 * mb);
      await expectLater(StorageGuard().ensureCanFit(totalBytes: 100 * mb), completes);
    });

    test('throws InsufficientStorageException with the real figures when there is not', () async {
      reportFree(() => 150 * mb);

      await expectLater(
        StorageGuard().ensureCanFit(totalBytes: 100 * mb),
        throwsA(
          isA<InsufficientStorageException>()
              .having((e) => e.availableBytes, 'available', 150 * mb)
              .having((e) => e.requiredBytes, 'required', (100 * mb * 2.1).ceil()),
        ),
      );
    });

    test('a resume that only needs the remainder is allowed', () async {
      // 210 MB needed fresh; 120 MB already on disk leaves 90 MB to find.
      reportFree(() => 100 * mb);
      await expectLater(StorageGuard().ensureCanFit(totalBytes: 100 * mb, alreadyOnDisk: 120 * mb), completes);
    });

    test('fails OPEN when the platform has no implementation', () async {
      // No mock handler -> MissingPluginException. A missing measurement must
      // never block a download.
      await expectLater(StorageGuard().ensureCanFit(totalBytes: 100 * mb), completes);
    });

    test('fails OPEN when the native side reports an error', () async {
      reportFree(() => PlatformException(code: 'STATFS_FAILED'));
      await expectLater(StorageGuard().ensureCanFit(totalBytes: 100 * mb), completes);
    });
  });

  group('disk-full detection', () {
    test('ENOSPC (errno 28) is recognised', () {
      expect(
        StorageGuard.isOutOfSpace(
          const FileSystemException('write failed', 'x', OSError('No space left on device', 28)),
        ),
        isTrue,
      );
    });

    test('other I/O errors are not mistaken for a full disk', () {
      expect(
        StorageGuard.isOutOfSpace(const FileSystemException('denied', 'x', OSError('Permission denied', 13))),
        isFalse,
      );
      expect(StorageGuard.isOutOfSpace(const SocketException('reset')), isFalse);
    });
  });
}
