import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:injectable/injectable.dart';

import '../services/offline_crypto.dart';

/// Per-download v2 encryption keys, held in the platform keystore (Android
/// Keystore-backed storage / iOS Keychain).
///
/// ## Why a separate, namespaced storage
///
/// Logout and session expiry wipe the app's secure storage wholesale
/// (`SharedPreferencesHelper.clearAllSecuredData` → `deleteAll()`). Keys kept
/// there would vanish on every ordinary logout and turn every download into
/// undecryptable bytes — while the policy is that a normal session end KEEPS
/// downloads. So the keys live in their own namespace that `deleteAll()` on
/// the default instance never reaches:
///  * Android: `storageNamespace` isolates the data file AND the Keystore
///    aliases;
///  * iOS: a dedicated keychain `accountName`, readable only after first
///    unlock and only on THIS device (excluded from backups and device
///    transfers — copying the files to another phone gets you nothing).
///
/// Keys are removed only through this class: per lesson on delete, all of them
/// when the account is deactivated.
@lazySingleton
class OfflineKeyStore {
  /// The DI constructor deliberately takes no storage parameter: injection
  /// would hand over the app's DEFAULT instance — the one logout wipes.
  OfflineKeyStore() : _storage = const FlutterSecureStorage(aOptions: androidOptions, iOptions: iosOptions);

  @visibleForTesting
  OfflineKeyStore.withStorage(this._storage);

  final FlutterSecureStorage _storage;

  static const String _namespace = 'edushield_offline_keys';
  static const String _prefix = 'dl_v2_';

  static const AndroidOptions androidOptions = AndroidOptions(storageNamespace: _namespace);
  static const IOSOptions iosOptions = IOSOptions(
    accountName: _namespace,
    accessibility: KeychainAccessibility.first_unlock_this_device,
    synchronizable: false,
  );

  String _keyFor(String lessonId) => '$_prefix$lessonId';

  Future<void> write(String lessonId, OfflineKeyMaterial keys) => _storage.write(
    key: _keyFor(lessonId),
    value: base64Encode(keys.bytes),
    aOptions: androidOptions,
    iOptions: iosOptions,
  );

  /// The lesson's keys, or null when missing (deleted, or lost with an app
  /// reinstall — the download is then unrecoverable and must be re-fetched).
  Future<OfflineKeyMaterial?> read(String lessonId) async {
    final String? raw = await _storage.read(key: _keyFor(lessonId), aOptions: androidOptions, iOptions: iosOptions);
    if (raw == null || raw.isEmpty) return null;
    try {
      return OfflineKeyMaterial.fromBytes(base64Decode(raw));
    } catch (_) {
      return null; // malformed entry: treat as lost
    }
  }

  Future<void> delete(String lessonId) =>
      _storage.delete(key: _keyFor(lessonId), aOptions: androidOptions, iOptions: iosOptions);

  /// Removes every download key (account deactivated / subscription ended).
  /// Only touches this namespace's own entries.
  Future<void> deleteAll() async {
    final Map<String, String> all = await _storage.readAll(aOptions: androidOptions, iOptions: iosOptions);
    for (final String key in all.keys.where((k) => k.startsWith(_prefix))) {
      await _storage.delete(key: key, aOptions: androidOptions, iOptions: iosOptions);
    }
  }
}
