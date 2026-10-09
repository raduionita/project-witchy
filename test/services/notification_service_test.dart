import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:witchy/models/mock_data.dart';
import 'package:witchy/models/reminder_item.dart';
import 'package:witchy/services/notification_service.dart';

void main() {
  final now = DateTime(2026, 10, 9);
  final predictedStart = DateTime(2026, 10, 14);
  final fertileStart = DateTime(2026, 10, 10);

  List<BellSpec> build(List<ReminderItem> items, {DateTime? fertile}) => NotificationService.buildNotificationRequests(
        items,
        predictedStart: predictedStart,
        fertileStart: fertile ?? fertileStart,
        bleedLength: 5,
        now: now,
      );

  group('buildNotificationRequests', () {
    test('skips disabled bells', () {
      final specs = build(MockData.reminders());
      expect(specs.map((s) => s.title), ['Log Period Commencing', 'Take Cosmic Pill', 'PMS Warning']);
    });

    test('daily recurring bell keeps time match', () {
      final specs = build(MockData.reminders());
      final pill = specs.firstWhere((s) => s.title == 'Take Cosmic Pill');
      expect(pill.match, DateTimeComponents.time);
      expect(pill.hours, [8]);
      expect(pill.minute, 30);
      expect(pill.ids, hasLength(pill.hours.length));
      expect(pill.oneShots, isEmpty);
    });

    test('daily during peak fans out one-shot per bleed day', () {
      final specs = build(MockData.reminders());
      final period = specs.firstWhere((s) => s.title == 'Log Period Commencing');
      expect(period.match, isNull);
      expect(period.hours, isEmpty);
      expect(period.minute, 0);
      final days = period.oneShots.map((s) => s.at).toList();
      expect(days, [DateTime(2026, 10, 14, 9), DateTime(2026, 10, 15, 9), DateTime(2026, 10, 16, 9), DateTime(2026, 10, 17, 9), DateTime(2026, 10, 18, 9)]);
      expect(period.oneShots.first.id, NotificationService.idAtDate('Log Period Commencing', predictedStart));
      expect(period.oneShots.map((s) => s.id).toSet(), hasLength(5));
    });

    test('3 days prior fires once at predicted start minus three', () {
      final specs = build(MockData.reminders());
      final pms = specs.firstWhere((s) => s.title == 'PMS Warning');
      expect(pms.match, isNull);
      expect(pms.oneShots, hasLength(1));
      expect(pms.oneShots.single.at, DateTime(2026, 10, 11, 18));
    });

    test('window start fires once at fertile window start', () {
      final items = MockData.reminders();
      items.firstWhere((i) => i.title == 'Fertility Window Alert').enabled = true;
      final specs = build(items);
      final win = specs.firstWhere((s) => s.title == 'Fertility Window Alert');
      expect(win.match, isNull);
      expect(win.oneShots, hasLength(1));
      expect(win.oneShots.single.at, DateTime(2026, 10, 10, 7));
    });

    test('one-shot dates already past are dropped', () {
      final lateNow = DateTime(2026, 10, 20);
      final specs = NotificationService.buildNotificationRequests(
        MockData.reminders(),
        predictedStart: predictedStart,
        fertileStart: fertileStart,
        bleedLength: 5,
        now: lateNow,
      );
      expect(specs.map((s) => s.title), ['Take Cosmic Pill']);
    });

    test('one-shot freqs without anchors produce no schedule', () {
      final specs = NotificationService.buildNotificationRequests(MockData.reminders(), now: now);
      expect(specs.map((s) => s.title), ['Take Cosmic Pill']);
    });

    test('hourly bell fans out over daytime hours with unique ids', () {
      final items = MockData.reminders();
      items.firstWhere((i) => i.title == 'Somatic Hydration').enabled = true;
      final spec = build(items).firstWhere((s) => s.title == 'Somatic Hydration');
      expect(spec.hours, [8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20]);
      expect(spec.ids.toSet(), hasLength(spec.hours.length));
    });

    test('ids are deterministic, bounded and distinct per title', () {
      final a = NotificationService.idAtHour('Log Period Commencing', 9);
      final b = NotificationService.idAtHour('Log Period Commencing', 9);
      expect(a, b);
      expect(a, inInclusiveRange(0, 0x7fffffff));
      expect(NotificationService.idAtHour('PMS Warning', 18), isNot(a));
      final d1 = NotificationService.idAtDate('Log Period Commencing', DateTime(2026, 10, 14));
      final d2 = NotificationService.idAtDate('Log Period Commencing', DateTime(2026, 10, 14));
      expect(d1, d2);
      expect(d1, inInclusiveRange(0, 0x7fffffff));
      expect(NotificationService.idAtDate('Log Period Commencing', DateTime(2026, 10, 15)), isNot(d1));
    });

    test('empty when nothing is enabled', () {
      final items = MockData.reminders();
      for (final item in items) {
        item.enabled = false;
      }
      expect(NotificationService.buildNotificationRequests(items, now: now), isEmpty);
    });
  });
}
