import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import '../utils/local_storage_keys.dart';

/// Resolves and caches a stable per-install device UUID, used both for the
/// `X-Device-ID` header (single-device login enforcement) and for deriving the
/// offline encryption key.
@lazySingleton
class DeviceService {
  final FlutterSecureStorage _storage;
  final DeviceInfoPlugin _deviceInfo;

  DeviceService(this._storage, this._deviceInfo);

  String? _cached;

  /// Returns the cached device UUID, generating + persisting one on first use.
  Future<String> getDeviceUuid() async {
    if (_cached != null) return _cached!;

    final String? stored = await _storage.read(key: LocalStorageKeys.deviceId);
    if (stored != null && stored.isNotEmpty) {
      _cached = stored;
      return stored;
    }

    final String raw = await _rawDeviceIdentifier();
    final String uuid = sha256.convert(utf8.encode(raw)).toString();
    await _storage.write(key: LocalStorageKeys.deviceId, value: uuid);
    _cached = uuid;
    return uuid;
  }

  /// Returns true when running on real hardware, false on an emulator/simulator.
  /// Fails open on unsupported platforms (e.g. desktop/tests) to avoid false
  /// lockouts there; the production targets are Android/iOS.
  Future<bool> isPhysicalDevice() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final AndroidDeviceInfo info = await _deviceInfo.androidInfo;
        return info.isPhysicalDevice;
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final IosDeviceInfo info = await _deviceInfo.iosInfo;
        return info.isPhysicalDevice;
      }
    } catch (_) {
      return true;
    }
    return true;
  }

  Future<String> _rawDeviceIdentifier() async {
    try {
      if (defaultTargetPlatform == TargetPlatform.android) {
        final AndroidDeviceInfo info = await _deviceInfo.androidInfo;
        return '${info.id}:${info.fingerprint}:${info.model}';
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        final IosDeviceInfo info = await _deviceInfo.iosInfo;
        return '${info.identifierForVendor}:${info.model}';
      }
    } catch (_) {
      // Fall through to a random-ish fallback below.
    }
    return DateTime.now().microsecondsSinceEpoch.toString();
  }
}
