import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:witchy/features/couples/couples_provider.dart';
import 'package:witchy/features/couples/couples_service.dart';
import 'package:witchy/features/couples/models/couple_link.dart';
import 'package:witchy/services/storage_service.dart';

Future<StorageService> freshStorage() async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return StorageService(prefs);
}

void main() {
  group('formatCoupleCode', () {
    test('formats a token into XXXX-XXXX-XXXX', () {
      expect(formatCoupleCode('ab12cd34ef56'), 'AB12-CD34-EF56');
    });

    test('strips non-alphanumerics', () {
      expect(formatCoupleCode('ab-12_cd'), 'AB12-CD00-0000');
    });

    test('is stable and uppercase', () {
      expect(formatCoupleCode('ab12cd34ef56'), formatCoupleCode('AB12CD34EF56'));
    });
  });

  group('CoupleLink JSON', () {
    test('round-trips through JSON', () {
      final CoupleLink link = CoupleLink(
        code: 'AB12-CD34-EF56',
        createdAt: DateTime(2026, 1, 1),
      );
      final CoupleLink restored =
          CoupleLink.fromJson(link.toJson());
      expect(restored, link);
    });
  });

  group('CoupleService', () {
    test('returns null before a link exists', () async {
      final CoupleService service = CoupleService(await freshStorage());
      expect(service.load(), isNull);
    });

    test('createLink generates a code and persists it', () async {
      final StorageService storage = await freshStorage();
      final CoupleService service = CoupleService(storage);
      final CoupleLink link = await service.createLink();

      expect(link.code, matches(RegExp(r'^[A-Z0-9]{4}-[A-Z0-9]{4}-[A-Z0-9]{4}$')));

      final CoupleService reloaded = CoupleService(storage);
      expect(reloaded.load()?.code, link.code);
    });

    test('clear removes the link', () async {
      final CoupleService service = CoupleService(await freshStorage());
      await service.createLink();
      await service.clear();
      expect(service.load(), isNull);
    });
  });

  group('CouplesProvider', () {
    test('createLink notifies and clear resets', () async {
      final CouplesProvider provider =
          CouplesProvider(CoupleService(await freshStorage()))..load();
      var notified = 0;
      provider.addListener(() => notified++);

      final CoupleLink link = await provider.createLink();
      expect(link.code, isNotEmpty);
      expect(provider.link, isNotNull);
      expect(notified, greaterThan(0));

      await provider.clear();
      expect(provider.link, isNull);
    });
  });
}
