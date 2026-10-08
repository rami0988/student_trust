import 'dart:io';

import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

/// Raised when a download would not fit in free space — before it starts, or
/// mid-transfer when the disk filled up underneath it. Its own type so the
/// caller can say "free up space" instead of "network error", and so the retry
/// ladder never retries it (another attempt cannot make room).
class InsufficientStorageException implements Exception {
  /// Bytes the download still needs.
  final int requiredBytes;

  /// Bytes the device reported free, or -1 when the OS reported "disk full"
  /// directly (ENOSPC) without a measurement.
  final int availableBytes;

  const InsufficientStorageException(this.requiredBytes, this.availableBytes);

  @override
  String toString() => 'InsufficientStorageException(required: $requiredBytes, available: $availableBytes)';
}

/// Checks free disk space before and during a download.
///
/// A lesson needs roughly twice its size while finishing: the plaintext
/// `.part` and the encrypted chunks being written from it exist side by side
/// until the encryption pass completes and the partial is deleted. Without
/// this check a download on a nearly-full phone ran to 90%, then failed with
/// an opaque I/O error and left a partial file eating the little space left.
///
/// Fails OPEN: when free space can't be measured (unsupported platform, a
/// native error) the download proceeds, and a genuine disk-full is still
/// caught as it happens (see [isOutOfSpace]). Refusing a download because a
/// measurement failed would be worse than the problem being guarded.
@lazySingleton
class StorageGuard {
  StorageGuard();

  static const MethodChannel _channel = MethodChannel('com.edushield/security');

  /// Plaintext partial + encrypted copy + a 10% margin for the filesystem,
  /// AES padding and the thumbnail.
  static const double requiredFactor = 2.1;

  /// Free bytes on the volume holding app-private storage, or null when it
  /// can't be measured.
  Future<int?> freeBytes() async {
    try {
      return await _channel.invokeMethod<int>('getFreeDiskBytes');
    } on MissingPluginException {
      return null;
    } on PlatformException {
      return null;
    }
  }

  /// Bytes still needed to finish a download of [totalBytes] when
  /// [alreadyOnDisk] bytes of the partial are already written.
  static int bytesStillNeeded({required int totalBytes, int alreadyOnDisk = 0}) {
    if (totalBytes <= 0) return 0;
    final int needed = (totalBytes * requiredFactor).ceil() - alreadyOnDisk;
    return needed < 0 ? 0 : needed;
  }

  /// Throws [InsufficientStorageException] when the device can't hold the
  /// rest of a [totalBytes]-sized download. No-op when [totalBytes] is
  /// unknown (0) or free space can't be measured.
  Future<void> ensureCanFit({required int totalBytes, int alreadyOnDisk = 0}) async {
    final int needed = bytesStillNeeded(totalBytes: totalBytes, alreadyOnDisk: alreadyOnDisk);
    if (needed == 0) return;
    final int? free = await freeBytes();
    if (free == null) return;
    if (free < needed) throw InsufficientStorageException(needed, free);
  }

  /// True when [error] is the OS reporting a full disk (ENOSPC is 28 on both
  /// Linux/Android and Darwin).
  static bool isOutOfSpace(Object error) {
    return error is FileSystemException && error.osError?.errorCode == 28;
  }
}
