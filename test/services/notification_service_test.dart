import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:witchy/models/mock_data.dart';
import 'package:witchy/services/notification_service.dart';

void main() {
  group('buildNotificationRequests', () {
    test('skips disabled bells', () {
      final specs = NotificationService.buildNotificationRequests(MockData.reminders());
      expect(specs.map((s) => s.title), ['Log Period Commencing', 'Take Cosmic Pill', 'PMS Warning']);
    });

    test('parses stated times into 24h schedule hours', () {
      final specs = NotificationService.buildNotificationRequests(MockData.reminders());
      final byTitle = {for (final s in specs) s.title: s};
      expect(byTitle['Log Period Commencing']!.hours, [9]);
      expect(byTitle['Take Cosmic Pill']!.hours, [8]);
      expect(byTitle['Take Cosmic Pill']!.minute, 30);
      expect(byTitle['PMS Warning']!.hours, [18]);
      expect(byTitle['PMS Warning']!.minute, 0);
      for (final spec in specs) {
        expect(spec.match, DateTimeComponents.time);
        expect(spec.ids, hasLength(spec.hours.length));
      }
    });

    test('hourly bell fans out over daytime hours with unique ids', () {
      final items = MockData.reminders();
      items.firstWhere((i) => i.title == 'Somatic Hydration').enabled = true;
      final spec = NotificationService.buildNotificationRequests(items).singleWhere((s) => s.title == 'Somatic Hydration');
      expect(spec.hours, [8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20]);
      expect(spec.ids.toSet(), hasLength(spec.hours.length));
    });

    test('ids are deterministic, bounded and distinct per title', () {
      final a = NotificationService.idAtHour('Log Period Commencing', 9);
      final b = NotificationService.idAtHour('Log Period Commencing', 9);
      expect(a, b);
      expect(a, inInclusiveRange(0, 0x7fffffff));
      expect(NotificationService.idAtHour('PMS Warning', 18), isNot(a));
    });

    test('empty when nothing is enabled', () {
      final items = MockData.reminders();
      for (final item in items) {
        item.enabled = false;
      }
      expect(NotificationService.buildNotificationRequests(items), isEmpty);
    });
  });
}
