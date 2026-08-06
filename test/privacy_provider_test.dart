import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:witchy/features/settings/privacy_provider.dart';
import 'package:witchy/services/storage_service.dart';

Future<StorageService> _freshStorage() async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return StorageService(prefs);
}

void main() {
  group('PrivacyProvider', () {
    test('defaults to anonymous mode off', () async {
      final PrivacyProvider provider = PrivacyProvider(await _freshStorage())
        ..load();
      expect(provider.anonymousMode, isFalse);
    });

    test('setAnonymousMode persists across instances', () async {
      final StorageService storage = await _freshStorage();
      final PrivacyProvider first = PrivacyProvider(storage)..load();
      var notified = 0;
      first.addListener(() => notified++);

      await first.setAnonymousMode(true);
      expect(first.anonymousMode, isTrue);
      expect(notified, greaterThan(0));

      final PrivacyProvider reloaded = PrivacyProvider(storage)..load();
      expect(reloaded.anonymousMode, isTrue);

      await reloaded.setAnonymousMode(false);
      final PrivacyProvider finalState = PrivacyProvider(storage)..load();
      expect(finalState.anonymousMode, isFalse);
    });

    test('load reads a previously persisted anonymous-mode flag', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'witchy.privacy.anonymousMode': true,
      });
      final StorageService storage =
          StorageService(await SharedPreferences.getInstance());
      final PrivacyProvider provider = PrivacyProvider(storage)..load();
      expect(provider.anonymousMode, isTrue);
    });
  });
}
