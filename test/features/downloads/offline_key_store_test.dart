import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mobile_template/features/downloads/data/local/offline_key_store.dart';
import 'package:mobile_template/features/downloads/data/services/offline_crypto.dart';

import '../../helpers/fake_secure_storage.dart';

void main() {
  late FakeSecureStorage storage;
  late OfflineKeyStore store;

  setUp(() {
    storage = FakeSecureStorage();
    store = OfflineKeyStore.withStorage(storage);
  });

  test('keys round-trip through the keystore', () async {
    final OfflineKeyMaterial keys = OfflineKeyMaterial.generate();

    await store.write('lesson-1', keys);
    final OfflineKeyMaterial? read = await store.read('lesson-1');

    expect(read?.encryptionKey, equals(keys.encryptionKey));
    expect(read?.macKey, equals(keys.macKey));
  });

  test('a missing key reads as null', () async {
    expect(await store.read('never-downloaded'), isNull);
  });

  test('a malformed entry reads as null instead of crashing', () async {
    storage.store['dl_v2_lesson-1'] = 'not base64 at all!!';
    expect(await store.read('lesson-1'), isNull);
  });

  // The bug this guards: logout wipes the app's DEFAULT secure storage. Keys
  // stored there would vanish on every ordinary logout and make every download
  // unplayable. Every call must target the dedicated namespace.
  test('every call targets the dedicated namespace, never the default storage', () async {
    await store.write('lesson-1', OfflineKeyMaterial.generate());
    await store.read('lesson-1');
    await store.delete('lesson-1');
    await store.deleteAll();

    expect(storage.androidOptionsSeen, isNotEmpty);
    for (final AndroidOptions? a in storage.androidOptionsSeen) {
      expect(a?.storageNamespace, 'edushield_offline_keys');
    }
    for (final AppleOptions? i in storage.iosOptionsSeen) {
      expect(i?.accountName, 'edushield_offline_keys');
      expect(
        i?.accessibility,
        KeychainAccessibility.first_unlock_this_device,
        reason: 'device-only, no backup/transfer',
      );
      expect(i?.synchronizable, isFalse, reason: 'never synced to iCloud Keychain');
    }
  });

  test('deleteAll removes download keys only', () async {
    await store.write('lesson-1', OfflineKeyMaterial.generate());
    await store.write('lesson-2', OfflineKeyMaterial.generate());
    storage.store['something-else'] = 'keep me';

    await store.deleteAll();

    expect(await store.read('lesson-1'), isNull);
    expect(await store.read('lesson-2'), isNull);
    expect(storage.store['something-else'], 'keep me');
  });

  test('delete removes only that lesson', () async {
    await store.write('lesson-1', OfflineKeyMaterial.generate());
    await store.write('lesson-2', OfflineKeyMaterial.generate());

    await store.delete('lesson-1');

    expect(await store.read('lesson-1'), isNull);
    expect(await store.read('lesson-2'), isNotNull);
  });
}
