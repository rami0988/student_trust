import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_template/features/downloads/data/services/offline_crypto.dart';

import '../../helpers/legacy_v1_fixture.dart';

void main() {
  const String lessonId = 'lesson-1';
  const int mib = 1024 * 1024;

  Uint8List bytes(int length, {int seed = 7}) =>
      Uint8List.fromList(List<int>.generate(length, (i) => (i * seed + 13) % 256));

  late Directory tempDir;
  setUp(() => tempDir = Directory.systemTemp.createTempSync('offline_crypto_'));
  tearDown(() {
    try {
      tempDir.deleteSync(recursive: true);
    } catch (_) {}
  });

  /// Encrypts [plain] into v2 chunk files the way the download service does
  /// (background isolate, batched) and returns a playback source for it.
  Future<OfflinePlaybackSource> sealV2(Uint8List plain, OfflineKeyMaterial keys) async {
    final File part = File('${tempDir.path}/video.part')..writeAsBytesSync(plain);
    final int count = chunkCountFor(plain.length, v2ChunkSize);
    await encryptBatchV2InBackground(
      EncryptBatchV2(
        partPath: part.path,
        lessonDirPath: tempDir.path,
        lessonId: lessonId,
        keyBytes: keys.bytes,
        firstChunk: 0,
        endChunk: count,
        chunkCount: count,
      ),
    );
    return OfflinePlaybackSource(
      lessonId: lessonId,
      format: OfflineFormat.v2CtrHmac,
      lessonDirPath: tempDir.path,
      chunkCount: count,
      totalBytes: plain.length,
      keyBytes: keys.bytes,
    );
  }

  Uint8List readAll(OfflinePlaybackSource s) {
    final BytesBuilder b = BytesBuilder(copy: false);
    for (int i = 0; i < s.chunkCount; i++) {
      b.add(decryptSourceChunk(s, i));
    }
    return b.takeBytes();
  }

  group('v2 round trip', () {
    test('a single chunk seals and opens back to the same bytes', () {
      final OfflineKeyMaterial keys = OfflineKeyMaterial.generate();
      final Uint8List plain = bytes(5000);

      final Uint8List sealed = encryptChunkV2(plain: plain, keys: keys, lessonId: lessonId, index: 0, chunkCount: 1);

      expect(sealed.length, plain.length + v2ChunkOverhead);
      expect(decryptChunkV2(sealed: sealed, keys: keys, lessonId: lessonId, index: 0, chunkCount: 1), equals(plain));
    });

    test('a multi-chunk lesson (with a short last chunk) round-trips byte-exact', () async {
      final Uint8List plain = bytes(3 * mib + 12345);
      final OfflinePlaybackSource source = await sealV2(plain, OfflineKeyMaterial.generate());

      expect(source.chunkCount, 4);
      expect(readAll(source), equals(plain));
    });

    test('the same plaintext never produces the same ciphertext (fresh nonce per chunk)', () {
      final OfflineKeyMaterial keys = OfflineKeyMaterial.generate();
      final Uint8List plain = bytes(4096);

      final Uint8List a = encryptChunkV2(plain: plain, keys: keys, lessonId: lessonId, index: 0, chunkCount: 1);
      final Uint8List b = encryptChunkV2(plain: plain, keys: keys, lessonId: lessonId, index: 0, chunkCount: 1);

      expect(a, isNot(equals(b)));
      expect(a.sublist(0, 12), isNot(equals(b.sublist(0, 12))), reason: 'the random nonce must differ');
    });

    test('generated keys are random, 32 + 32 bytes, and survive the stored form', () {
      final OfflineKeyMaterial a = OfflineKeyMaterial.generate();
      final OfflineKeyMaterial b = OfflineKeyMaterial.generate();

      expect(a.encryptionKey, isNot(equals(b.encryptionKey)));
      expect(a.encryptionKey, isNot(equals(a.macKey)), reason: 'encryption and MAC keys must be independent');
      final OfflineKeyMaterial restored = OfflineKeyMaterial.fromBytes(a.bytes);
      expect(restored.encryptionKey, equals(a.encryptionKey));
      expect(restored.macKey, equals(a.macKey));
    });
  });

  group('random access', () {
    test('any chunk decrypts on its own, in any order, without its neighbours', () async {
      final Uint8List plain = bytes(5 * mib + 777);
      final OfflinePlaybackSource source = await sealV2(plain, OfflineKeyMaterial.generate());

      for (final int index in [4, 0, 5, 2]) {
        final int start = index * v2ChunkSize;
        final int end = (start + v2ChunkSize < plain.length) ? start + v2ChunkSize : plain.length;
        expect(
          decryptSourceChunk(source, index),
          equals(Uint8List.sublistView(plain, start, end)),
          reason: 'chunk $index',
        );
      }
    });

    test('deleting other chunks does not affect decrypting one', () async {
      final Uint8List plain = bytes(3 * mib);
      final OfflinePlaybackSource source = await sealV2(plain, OfflineKeyMaterial.generate());
      File(source.chunkPath(0)).deleteSync();
      File(source.chunkPath(2)).deleteSync();

      expect(decryptSourceChunk(source, 1), equals(Uint8List.sublistView(plain, mib, 2 * mib)));
    });
  });

  group('tamper and corruption detection', () {
    late OfflineKeyMaterial keys;
    late Uint8List sealed;

    setUp(() {
      keys = OfflineKeyMaterial.generate();
      sealed = encryptChunkV2(plain: bytes(64 * 1024), keys: keys, lessonId: lessonId, index: 3, chunkCount: 9);
    });

    Uint8List flip(Uint8List data, int at) => Uint8List.fromList(data)..[at] ^= 0x01;

    Matcher failsAuth() => throwsA(isA<ChunkAuthenticationException>());

    test('an untouched chunk verifies', () {
      expect(
        decryptChunkV2(sealed: sealed, keys: keys, lessonId: lessonId, index: 3, chunkCount: 9),
        hasLength(64 * 1024),
      );
    });

    test('one flipped bit in the ciphertext fails loudly', () {
      expect(
        () => decryptChunkV2(sealed: flip(sealed, 5000), keys: keys, lessonId: lessonId, index: 3, chunkCount: 9),
        failsAuth(),
      );
    });

    test('a modified IV fails', () {
      expect(
        () => decryptChunkV2(sealed: flip(sealed, 3), keys: keys, lessonId: lessonId, index: 3, chunkCount: 9),
        failsAuth(),
      );
    });

    test('a modified tag fails', () {
      expect(
        () => decryptChunkV2(
          sealed: flip(sealed, sealed.length - 1),
          keys: keys,
          lessonId: lessonId,
          index: 3,
          chunkCount: 9,
        ),
        failsAuth(),
      );
    });

    test('a truncated chunk fails', () {
      expect(
        () => decryptChunkV2(
          sealed: Uint8List.sublistView(sealed, 0, sealed.length - 100),
          keys: keys,
          lessonId: lessonId,
          index: 3,
          chunkCount: 9,
        ),
        failsAuth(),
      );
      expect(
        () => decryptChunkV2(sealed: Uint8List(10), keys: keys, lessonId: lessonId, index: 3, chunkCount: 9),
        failsAuth(),
      );
    });

    test('a chunk moved to another position (swap/reorder) fails', () {
      expect(
        () => decryptChunkV2(sealed: sealed, keys: keys, lessonId: lessonId, index: 4, chunkCount: 9),
        failsAuth(),
      );
    });

    test('a chunk count that does not match (chunks dropped from the end) fails', () {
      expect(
        () => decryptChunkV2(sealed: sealed, keys: keys, lessonId: lessonId, index: 3, chunkCount: 8),
        failsAuth(),
      );
    });

    test('a chunk from another lesson fails', () {
      expect(
        () => decryptChunkV2(sealed: sealed, keys: keys, lessonId: 'lesson-2', index: 3, chunkCount: 9),
        failsAuth(),
      );
    });

    test('the wrong key fails', () {
      expect(
        () => decryptChunkV2(
          sealed: sealed,
          keys: OfflineKeyMaterial.generate(),
          lessonId: lessonId,
          index: 3,
          chunkCount: 9,
        ),
        failsAuth(),
      );
    });

    test('corruption on disk is caught when reading through a playback source', () async {
      final Uint8List plain = bytes(2 * mib);
      final OfflinePlaybackSource source = await sealV2(plain, keys);
      final File chunk = File(source.chunkPath(1));
      chunk.writeAsBytesSync(flip(chunk.readAsBytesSync(), 999));

      expect(() => decryptSourceChunk(source, 1), failsAuth());
      expect(
        decryptSourceChunk(source, 0),
        equals(Uint8List.sublistView(plain, 0, mib)),
        reason: 'other chunks stay readable',
      );
    });
  });

  group('legacy v1 (backward compatibility)', () {
    const String studentId = 'student-1';
    const String deviceUuid = 'device-1';

    OfflinePlaybackSource v1Source(int chunkCount, int total, {String device = deviceUuid}) {
      // The v1 key/IV derivation, as the service performs it for old downloads.
      return OfflinePlaybackSource(
        lessonId: lessonId,
        format: OfflineFormat.v1Cbc,
        lessonDirPath: tempDir.path,
        chunkCount: chunkCount,
        totalBytes: total,
        keyBytes: _sha256('$studentId:$device:$lessonId'),
        v1Iv: Uint8List.sublistView(_sha256('$lessonId:$studentId'), 0, 16),
      );
    }

    test('a download written by an old app version decrypts byte-exact', () {
      final Uint8List plain = bytes(5 * mib + 4321);
      final int count = writeLegacyV1Chunks(
        lessonDirPath: tempDir.path,
        plain: plain,
        studentId: studentId,
        deviceUuid: deviceUuid,
        lessonId: lessonId,
      );

      expect(count, 3, reason: 'v1 used 2 MiB chunks');
      expect(readAll(v1Source(count, plain.length)), equals(plain));
    });

    test('legacy chunks are independently readable too (needed for streaming)', () {
      final Uint8List plain = bytes(5 * mib);
      final int count = writeLegacyV1Chunks(
        lessonDirPath: tempDir.path,
        plain: plain,
        studentId: studentId,
        deviceUuid: deviceUuid,
        lessonId: lessonId,
      );

      expect(
        decryptSourceChunk(v1Source(count, plain.length), 1),
        equals(Uint8List.sublistView(plain, 2 * mib, 4 * mib)),
      );
    });

    test('a legacy download cannot be opened with another device id', () {
      final Uint8List plain = bytes(mib);
      final int count = writeLegacyV1Chunks(
        lessonDirPath: tempDir.path,
        plain: plain,
        studentId: studentId,
        deviceUuid: deviceUuid,
        lessonId: lessonId,
      );

      Object? error;
      Uint8List? out;
      try {
        out = decryptSourceChunk(v1Source(count, plain.length, device: 'someone-elses-device'), 0);
      } catch (e) {
        error = e;
      }
      // CBC with a wrong key almost always fails PKCS7 unpadding; if it
      // happens to unpad, the output is still garbage, never the video.
      expect(error != null || !_listEquals(out!, plain), isTrue);
    });
  });
}

Uint8List _sha256(String input) {
  // Mirrors the legacy derivation (see legacy_v1_fixture.dart).
  return Uint8List.fromList(sha256.convert(utf8.encode(input)).bytes);
}

bool _listEquals(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  for (int i = 0; i < a.length; i++) {
    if (a[i] != b[i]) return false;
  }
  return true;
}
