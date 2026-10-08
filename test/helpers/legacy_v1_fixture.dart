import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:crypto/crypto.dart';
import 'package:encrypt/encrypt.dart';

/// Writes a downloaded lesson EXACTLY the way app versions before v2 did:
/// AES-256-CBC (PKCS7), 2 MiB plaintext chunks named `chunk_<i>.enc`, a key
/// derived as `sha256("$studentId:$deviceUuid:$lessonId")` and one IV,
/// `sha256("$lessonId:$studentId")[0..16]`, shared by every chunk.
///
/// Deliberately re-implemented here rather than calling production code: if
/// the shipped v1 decrypt path ever drifts from what old versions really wrote,
/// the backward-compatibility tests must fail — students would otherwise lose
/// every download they already have.
///
/// Returns the number of chunks written.
int writeLegacyV1Chunks({
  required String lessonDirPath,
  required Uint8List plain,
  required String studentId,
  required String deviceUuid,
  required String lessonId,
}) {
  const int legacyChunk = 2 * 1024 * 1024;
  final List<int> key = sha256.convert(utf8.encode('$studentId:$deviceUuid:$lessonId')).bytes;
  final List<int> iv = sha256.convert(utf8.encode('$lessonId:$studentId')).bytes.sublist(0, 16);
  final Encrypter encrypter = Encrypter(AES(Key(Uint8List.fromList(key)), mode: AESMode.cbc));
  Directory(lessonDirPath).createSync(recursive: true);
  int index = 0;
  for (int pos = 0; pos < plain.length; pos += legacyChunk) {
    final int end = (pos + legacyChunk < plain.length) ? pos + legacyChunk : plain.length;
    final Encrypted sealed = encrypter.encryptBytes(
      Uint8List.sublistView(plain, pos, end),
      iv: IV(Uint8List.fromList(iv)),
    );
    File('$lessonDirPath/chunk_$index.enc').writeAsBytesSync(sealed.bytes);
    index++;
  }
  return index;
}

/// The Hive metadata a pre-v2 app wrote for a completed download: no `format`
/// key at all. [sizeBytes] is optional because the earliest versions didn't
/// record it either.
Map<String, dynamic> legacyV1Meta({
  required String lessonId,
  required int chunkCount,
  required String studentId,
  required String deviceUuid,
  int? sizeBytes,
}) {
  final String now = DateTime.now().toIso8601String();
  return <String, dynamic>{
    'lessonId': lessonId,
    'title': 'Legacy lesson',
    'durationSeconds': 60,
    'chunkCount': chunkCount,
    'sizeBytes': ?sizeBytes,
    'isComplete': true,
    'downloadedAt': now,
    'studentId': studentId,
    'deviceUuid': deviceUuid,
    'lastValidatedAt': now,
  };
}
