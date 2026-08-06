import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:witchy/features/settings/locale_provider.dart';
import 'package:witchy/services/storage_service.dart';

Future<StorageService> _freshStorage() async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return StorageService(prefs);
}

void main() {
  group('AppLocaleOption', () {
    test('exposes code, isSystem, locale and storageKey', () {
      expect(AppLocaleOption.system.isSystem, isTrue);
      expect(AppLocaleOption.system.code, isNull);
      expect(AppLocaleOption.system.locale, isNull);
      expect(AppLocaleOption.system.storageKey, 'system');

      expect(AppLocaleOption.english.isSystem, isFalse);
      expect(AppLocaleOption.english.locale, const Locale('en'));
      expect(AppLocaleOption.english.storageKey, 'en');

      expect(AppLocaleOption.spanish.isSystem, isFalse);
      expect(AppLocaleOption.spanish.locale, const Locale('es'));
      expect(AppLocaleOption.spanish.storageKey, 'es');
    });
  });

  group('LocaleProvider', () {
    test('defaults to the system locale', () async {
      final LocaleProvider provider =
          LocaleProvider(await _freshStorage())..load();
      expect(provider.option, AppLocaleOption.system);
      expect(provider.locale, isNull);
    });

    test('setOption notifies, persists, and reloads across instances',
        () async {
      final StorageService storage = await _freshStorage();
      final LocaleProvider first = LocaleProvider(storage)..load();
      var notified = 0;
      first.addListener(() => notified++);

      await first.setOption(AppLocaleOption.spanish);
      expect(first.option, AppLocaleOption.spanish);
      expect(first.locale, const Locale('es'));
      expect(notified, greaterThan(0));

      final LocaleProvider reloaded = LocaleProvider(storage)..load();
      expect(reloaded.option, AppLocaleOption.spanish);
      expect(reloaded.locale, const Locale('es'));

      await reloaded.setOption(AppLocaleOption.system);
      final LocaleProvider finalState = LocaleProvider(storage)..load();
      expect(finalState.option, AppLocaleOption.system);
      expect(finalState.locale, isNull);
    });

    test('load reads a previously persisted locale', () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'witchy.appearance.locale': '"en"',
      });
      final StorageService storage =
          StorageService(await SharedPreferences.getInstance());
      final LocaleProvider provider = LocaleProvider(storage)..load();
      expect(provider.option, AppLocaleOption.english);
      expect(provider.locale, const Locale('en'));
    });

    test('setOption ignores an unknown persisted value and stays system',
        () async {
      SharedPreferences.setMockInitialValues(<String, Object>{
        'witchy.appearance.locale': '"fr"',
      });
      final StorageService storage =
          StorageService(await SharedPreferences.getInstance());
      final LocaleProvider provider = LocaleProvider(storage)..load();
      expect(provider.option, AppLocaleOption.system);
    });
  });
}
