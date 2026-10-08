import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:math';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';

/// Encryption formats for downloaded lessons, and the chunk-level crypto for
/// both. Everything heavy here runs in background isolates — never on the UI
/// isolate.
///
/// ## v2 (current): AES-256-CTR + HMAC-SHA256, 1 MiB chunks
///
/// Each chunk file is `IV(16) | ciphertext | tag(32)`:
///  * a fresh random 96-bit nonce per chunk (+ a 32-bit block counter that
///    starts at 0 — a 1 MiB chunk uses 65 536 blocks, far below overflow);
///  * the tag is HMAC-SHA256 over `domain | lessonId | chunkIndex |
///    chunkCount | IV | ciphertext`, verified BEFORE decrypting (encrypt-then-
///    MAC). Binding the index and count means chunks can't be swapped,
///    reordered, or dropped without the tag failing — and a corrupted chunk
///    fails loudly instead of decoding into garbage the player freezes on;
///  * two independent random 256-bit keys per download (encryption, MAC),
///    held in the platform keystore — see `OfflineKeyStore`.
///
/// Chunks are independent, so any byte range can be served by decrypting only
/// the chunks it touches — which is what makes streaming playback and seeking
/// possible without a plaintext copy on disk.
///
/// Why not AES-GCM: the pure-Dart GCM implementation measured ~1 MiB/s, which
/// would make finishing a large download take many minutes and stutter
/// playback. CTR + HMAC gives the same guarantees (confidentiality, per-chunk
/// integrity, random access) at ~25x the speed with no native dependency.
///
/// ## v1 (legacy, read-only): AES-256-CBC, 2 MiB chunks
///
/// Downloads made before v2 use a key derived from (student, device, lesson)
/// and one IV for every chunk, with no integrity tag. They are still read —
/// students keep their existing downloads — but never written any more.

/// Plaintext bytes per v1 chunk. Load-bearing: existing downloads use it.
const int v1ChunkSize = 2 * 1024 * 1024;

/// Plaintext bytes per v2 chunk.
const int v2ChunkSize = 1024 * 1024;

const int _v2IvLength = 16;
const int _v2TagLength = 32;

/// Bytes a v2 chunk file adds on top of its plaintext.
const int v2ChunkOverhead = _v2IvLength + _v2TagLength;

const String _v2Domain = 'EDUSHIELD-OFFLINE-V2';

enum OfflineFormat { v1Cbc, v2CtrHmac }

/// Raised when a chunk's integrity tag doesn't match: the bytes on disk were
/// corrupted or tampered with. Never retried and never "played through".
class ChunkAuthenticationException implements Exception {
  final int chunkIndex;
  const ChunkAuthenticationException(this.chunkIndex);

  @override
  String toString() => 'ChunkAuthenticationException(chunk $chunkIndex)';
}

/// The two independent per-download v2 keys.
class OfflineKeyMaterial {
  final Uint8List encryptionKey;
  final Uint8List macKey;

  OfflineKeyMaterial(this.encryptionKey, this.macKey) {
    if (encryptionKey.length != 32 || macKey.length != 32) {
      throw ArgumentError('v2 keys must be 32 bytes each');
    }
  }

  /// Fresh random keys from the platform CSPRNG.
  factory OfflineKeyMaterial.generate() => OfflineKeyMaterial(_randomBytes(32), _randomBytes(32));

  /// Both keys concatenated — the form persisted in the keystore.
  Uint8List get bytes => Uint8List.fromList([...encryptionKey, ...macKey]);

  factory OfflineKeyMaterial.fromBytes(List<int> bytes) {
    if (bytes.length != 64) throw ArgumentError('expected 64 key bytes, got ${bytes.length}');
    return OfflineKeyMaterial(Uint8List.fromList(bytes.sublist(0, 32)), Uint8List.fromList(bytes.sublist(32)));
  }
}

Uint8List _randomBytes(int n) {
  final Random rng = Random.secure();
  return Uint8List.fromList(List<int>.generate(n, (_) => rng.nextInt(256)));
}

/// Number of chunks a plaintext of [length] bytes splits into.
int chunkCountFor(int length, int chunkSize) => length <= 0 ? 0 : (length + chunkSize - 1) ~/ chunkSize;

// --- v2 chunk crypto ----------------------------------------------------------

Uint8List _v2Aad(String lessonId, int index, int chunkCount) {
  final BytesBuilder b = BytesBuilder(copy: false)
    ..add(utf8.encode(_v2Domain))
    ..addByte(0)
    ..add(utf8.encode(lessonId))
    ..addByte(0);
  final ByteData counters = ByteData(8)
    ..setUint32(0, index)
    ..setUint32(4, chunkCount);
  b.add(counters.buffer.asUint8List());
  return b.takeBytes();
}

Uint8List _v2Tag(Uint8List macKey, Uint8List aad, Uint8List iv, Uint8List cipherText) {
  final _DigestSink sink = _DigestSink();
  final ByteConversionSink input = Hmac(sha256, macKey).startChunkedConversion(sink);
  input
    ..add(aad)
    ..add(iv)
    ..add(cipherText)
    ..close();
  return Uint8List.fromList(sink.value.bytes);
}

/// Constant-time comparison, so tag checks leak nothing through timing.
bool _constantTimeEquals(List<int> a, List<int> b) {
  if (a.length != b.length) return false;
  int diff = 0;
  for (int i = 0; i < a.length; i++) {
    diff |= a[i] ^ b[i];
  }
  return diff == 0;
}

/// Seals one v2 chunk: `IV | ciphertext | tag`.
Uint8List encryptChunkV2({
  required Uint8List plain,
  required OfflineKeyMaterial keys,
  required String lessonId,
  required int index,
  required int chunkCount,
}) {
  // 96 random bits + a 32-bit counter starting at zero.
  final Uint8List iv = Uint8List(_v2IvLength)..setRange(0, 12, _randomBytes(12));
  final Encrypter cipher = Encrypter(AES(Key(keys.encryptionKey), mode: AESMode.sic, padding: null));
  final Uint8List cipherText = cipher.encryptBytes(plain, iv: IV(iv)).bytes;
  final Uint8List tag = _v2Tag(keys.macKey, _v2Aad(lessonId, index, chunkCount), iv, cipherText);
  return (BytesBuilder(copy: false)
        ..add(iv)
        ..add(cipherText)
        ..add(tag))
      .takeBytes();
}

/// Verifies then opens one v2 chunk. Throws [ChunkAuthenticationException] if
/// the tag doesn't match (corruption, tampering, or a chunk from elsewhere).
Uint8List decryptChunkV2({
  required Uint8List sealed,
  required OfflineKeyMaterial keys,
  required String lessonId,
  required int index,
  required int chunkCount,
}) {
  if (sealed.length < v2ChunkOverhead) throw ChunkAuthenticationException(index);
  final Uint8List iv = Uint8List.sublistView(sealed, 0, _v2IvLength);
  final Uint8List cipherText = Uint8List.sublistView(sealed, _v2IvLength, sealed.length - _v2TagLength);
  final Uint8List tag = Uint8List.sublistView(sealed, sealed.length - _v2TagLength);
  final Uint8List expected = _v2Tag(keys.macKey, _v2Aad(lessonId, index, chunkCount), iv, cipherText);
  if (!_constantTimeEquals(tag, expected)) throw ChunkAuthenticationException(index);
  final Encrypter cipher = Encrypter(AES(Key(keys.encryptionKey), mode: AESMode.sic, padding: null));
  return Uint8List.fromList(cipher.decryptBytes(Encrypted(cipherText), iv: IV(iv)));
}

// --- v1 chunk crypto (legacy, read-only) -------------------------------------

Uint8List decryptChunkV1({required Uint8List sealed, required Uint8List key, required Uint8List iv}) {
  final Encrypter cipher = Encrypter(AES(Key(key), mode: AESMode.cbc));
  return Uint8List.fromList(cipher.decryptBytes(Encrypted(sealed), iv: IV(iv)));
}

// --- v2 encryption pass (background isolate) ----------------------------------

/// One batch of the v2 encryption pass: chunks [firstChunk] up to (not
/// including) [endChunk] of the partial file at [partPath].
class EncryptBatchV2 {
  final String partPath;
  final String lessonDirPath;
  final String lessonId;
  final Uint8List keyBytes;
  final int firstChunk;
  final int endChunk;
  final int chunkCount;

  const EncryptBatchV2({
    required this.partPath,
    required this.lessonDirPath,
    required this.lessonId,
    required this.keyBytes,
    required this.firstChunk,
    required this.endChunk,
    required this.chunkCount,
  });
}

/// Encrypts one batch in a background isolate. Returns plaintext bytes
/// consumed, so the caller can report progress per batch.
///
/// A top-level function on purpose: the closure captures only [batch] (plain
/// data). A closure created inside a service method could capture `this`,
/// which holds a Hive box and cannot be sent to another isolate.
Future<int> encryptBatchV2InBackground(EncryptBatchV2 batch) => Isolate.run(() => _encryptBatchV2(batch));

int _encryptBatchV2(EncryptBatchV2 batch) {
  final OfflineKeyMaterial keys = OfflineKeyMaterial.fromBytes(batch.keyBytes);
  final RandomAccessFile raf = File(batch.partPath).openSync();
  int consumed = 0;
  try {
    final int length = raf.lengthSync();
    for (int index = batch.firstChunk; index < batch.endChunk; index++) {
      final int start = index * v2ChunkSize;
      if (start >= length) break;
      final int size = (start + v2ChunkSize < length) ? v2ChunkSize : length - start;
      raf.setPositionSync(start);
      final Uint8List plain = raf.readSync(size);
      final Uint8List sealed = encryptChunkV2(
        plain: plain,
        keys: keys,
        lessonId: batch.lessonId,
        index: index,
        chunkCount: batch.chunkCount,
      );
      File(v2ChunkPath(batch.lessonDirPath, index)).writeAsBytesSync(sealed, flush: true);
      consumed += size;
    }
  } finally {
    raf.closeSync();
  }
  return consumed;
}

String v1ChunkPath(String dir, int index) => '$dir/chunk_$index.enc';
String v2ChunkPath(String dir, int index) => '$dir/chunk_$index.v2';

// --- Playback source ----------------------------------------------------------

/// Everything needed to read any byte range of one downloaded lesson. Plain
/// data only, so it can be handed to the decryption isolate.
class OfflinePlaybackSource {
  final String lessonId;
  final OfflineFormat format;
  final String lessonDirPath;
  final int chunkCount;

  /// Exact plaintext size of the video.
  final int totalBytes;

  /// v2: both keys (64 bytes). v1: the derived 32-byte key.
  final Uint8List keyBytes;

  /// v1 only: the shared CBC IV.
  final Uint8List? v1Iv;

  const OfflinePlaybackSource({
    required this.lessonId,
    required this.format,
    required this.lessonDirPath,
    required this.chunkCount,
    required this.totalBytes,
    required this.keyBytes,
    this.v1Iv,
  });

  int get plainChunkSize => format == OfflineFormat.v2CtrHmac ? v2ChunkSize : v1ChunkSize;

  String chunkPath(int index) =>
      format == OfflineFormat.v2CtrHmac ? v2ChunkPath(lessonDirPath, index) : v1ChunkPath(lessonDirPath, index);
}

/// Reads and decrypts chunk [index] of [source] (synchronous: meant to run in
/// a background isolate). Throws [ChunkAuthenticationException] on a v2 tag
/// mismatch, and the cipher's error on an undecryptable v1 chunk.
Uint8List decryptSourceChunk(OfflinePlaybackSource source, int index) {
  if (index < 0 || index >= source.chunkCount) throw RangeError.index(index, source.chunkCount);
  final Uint8List sealed = File(source.chunkPath(index)).readAsBytesSync();
  switch (source.format) {
    case OfflineFormat.v2CtrHmac:
      return decryptChunkV2(
        sealed: sealed,
        keys: OfflineKeyMaterial.fromBytes(source.keyBytes),
        lessonId: source.lessonId,
        index: index,
        chunkCount: source.chunkCount,
      );
    case OfflineFormat.v1Cbc:
      return decryptChunkV1(sealed: sealed, key: source.keyBytes, iv: source.v1Iv!);
  }
}

/// Decrypts one chunk in a short-lived background isolate (used for one-off
/// checks; streaming playback uses the long-lived worker instead).
Future<Uint8List> decryptSourceChunkInBackground(OfflinePlaybackSource source, int index) =>
    Isolate.run(() => decryptSourceChunk(source, index));

/// Receives exactly one digest from a chunked HMAC computation.
class _DigestSink implements Sink<Digest> {
  Digest? _value;
  Digest get value => _value!;

  @override
  void add(Digest data) => _value = data;

  @override
  void close() {}
}
