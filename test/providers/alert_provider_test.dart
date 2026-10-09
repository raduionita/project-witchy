import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:witchy/models/alert_item.dart';
import 'package:witchy/models/alert_type.dart';
import 'package:witchy/providers/alert_provider.dart';
import 'package:witchy/providers/cycle_provider.dart';
import 'package:witchy/providers/logging_provider.dart';
import 'package:witchy/providers/onboarding_provider.dart';
import 'package:witchy/services/prefs_service.dart';

void main() {
  late PrefsService prefs;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    prefs = PrefsService();
  });

  AlertItem item(String id, {bool read = false, DateTime? event}) => AlertItem(
    id: id,
    type: AlertType.logMissing,
    title: 'Title $id',
    body: 'Body $id',
    createdAt: DateTime(2026, 10, 9, 9),
    eventDate: event ?? DateTime(2026, 10, 9),
    read: read,
  );

  test('alerts persist across reload', () async {
    final provider = AlertProvider(prefs, items: [item('a'), item('b', read: true)]);
    provider.markRead('a');
    await prefs.saveAlertItems(provider.items);

    final reloaded = await AlertProvider.load(prefs);
    expect(reloaded.items.map((a) => a.id), ['a', 'b']);
    expect(reloaded.items.every((a) => a.read), isTrue);
    expect(reloaded.unreadCount, 0);
  });

  test('markRead flips one alert and counts unread', () {
    final provider = AlertProvider(prefs, items: [item('a'), item('b')]);
    expect(provider.unreadCount, 2);

    provider.markRead('a');
    expect(provider.unreadCount, 1);
    expect(provider.items.firstWhere((a) => a.id == 'a').read, isTrue);

    provider.markAllRead();
    expect(provider.unreadCount, 0);

    provider.markRead('missing-id');
    expect(provider.items.length, 2);
  });

  test('generate merges by stable id and keeps read state', () {
    final onboarding = OnboardingProvider(
      prefs,
      onboarded: true,
      cycleLength: 28,
      bleedLength: 5,
      lastPeriodStart: DateTime.now().subtract(const Duration(days: 26)),
    );
    final logging = LoggingProvider(prefs);
    final cycle = CycleProvider(onboarding, logging);
    final provider = AlertProvider(prefs);
    provider.bind(cycle, logging);

    expect(provider.items, isNotEmpty);
    final count = provider.items.length;
    final period = provider.items.firstWhere((a) => a.type == AlertType.periodPredicted);
    provider.markRead(period.id);

    provider.generate();
    expect(provider.items.length, count);
    expect(provider.items.firstWhere((a) => a.id == period.id).read, isTrue);
    expect(provider.unreadCount, count - 1);
  });

  test('expired events are pruned on generate', () {
    final stale = item('stale', event: DateTime(2026, 1, 1));
    final provider = AlertProvider(prefs, items: [stale]);
    final onboarding = OnboardingProvider(
      prefs,
      onboarded: true,
      cycleLength: 28,
      bleedLength: 5,
      lastPeriodStart: DateTime.now().subtract(const Duration(days: 5)),
    );
    final logging = LoggingProvider(prefs);
    provider.bind(CycleProvider(onboarding, logging), logging);

    expect(provider.items.where((a) => a.id == 'stale'), isEmpty);
  });
}
