import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:witchy/models/alert_item.dart';
import 'package:witchy/models/alert_type.dart';
import 'package:witchy/models/tracking_mode.dart';
import 'package:witchy/providers/alert_provider.dart';
import 'package:witchy/providers/cycle_provider.dart';
import 'package:witchy/providers/gestation_provider.dart';
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

  group('provider-level one-shots (B4/B6)', () {
    DateTime today() {
      final now = DateTime.now();
      return DateTime(now.year, now.month, now.day);
    }

    String todayKey() => LoggingProvider.keyFor(today());

    ({OnboardingProvider onboarding, LoggingProvider logging, CycleProvider cycle, AlertProvider provider}) bindStandard({
      Set<TrackingMode>? modes,
      DateTime? lmp,
      int cycleLength = 28,
      int daysAgo = 10,
    }) {
      final onboarding = OnboardingProvider(
        prefs,
        onboarded: true,
        cycleLength: cycleLength,
        bleedLength: 5,
        lastPeriodStart: today().add(Duration(days: -daysAgo)),
        trackingModes: modes,
      );
      final logging = LoggingProvider(prefs);
      final cycle = CycleProvider(onboarding, logging, gestation: GestationProvider(prefs, lmpDate: lmp));
      final provider = AlertProvider(prefs);
      provider.bind(cycle, logging);
      return (onboarding: onboarding, logging: logging, cycle: cycle, provider: provider);
    }

    test('positive OPK today fires opk-positive once', () {
      final s = bindStandard();
      s.logging.setOvulationTest(today(), 'positive');
      s.provider.generate();

      final id = 'opk-positive-${todayKey()}';
      expect(s.provider.items.where((a) => a.id == id), hasLength(1));
      expect(s.provider.items.firstWhere((a) => a.id == id).type, AlertType.fertileWindow);
      s.provider.generate();
      expect(s.provider.items.where((a) => a.id == id), hasLength(1));
    });

    test('logged flow today fires period-today', () {
      final s = bindStandard();
      s.logging.setFlow(today(), 'Heavy');
      s.provider.generate();

      final id = 'period-today-${todayKey()}';
      expect(s.provider.items.where((a) => a.id == id), hasLength(1));
      expect(s.provider.items.firstWhere((a) => a.id == id).type, AlertType.periodPredicted);
    });

    test('pregnancy suppression hides the OPK one-shot', () {
      final s = bindStandard(modes: {TrackingMode.cycle, TrackingMode.pregnancy}, lmp: today().add(const Duration(days: -60)));
      s.logging.setOvulationTest(today(), 'positive');
      s.provider.generate();

      expect(s.provider.items.where((a) => a.id == 'opk-positive-${todayKey()}'), isEmpty);
    });

    test('low confidence hides the OPK one-shot', () {
      final s = bindStandard(cycleLength: 40, daysAgo: 90);
      s.logging.setOvulationTest(today(), 'positive');
      s.provider.generate();

      expect(s.provider.items.where((a) => a.id == 'opk-positive-${todayKey()}'), isEmpty);
    });

    test('dismissed one-shot restores exactly once (undo interplay)', () {
      final s = bindStandard();
      s.logging.setFlow(today(), 'Heavy');
      s.provider.generate();

      final id = 'period-today-${todayKey()}';
      final item = s.provider.items.firstWhere((a) => a.id == id);
      s.provider.dismiss(id);
      expect(s.provider.items.where((a) => a.id == id), isEmpty);
      s.provider.restore(item);
      expect(s.provider.items.where((a) => a.id == id), hasLength(1));
      s.provider.restore(item);
      expect(s.provider.items.where((a) => a.id == id), hasLength(1));
    });

    test('logging today removes the stale Log Missing alert', () {
      final s = bindStandard();
      final evening = DateTime(today().year, today().month, today().day, 18, 30);
      s.provider.generate(now: evening);
      expect(s.provider.items.where((a) => a.type == AlertType.logMissing), isNotEmpty);
      s.logging.setFlow(today(), 'Medium');
      s.provider.generate(now: evening);
      expect(s.provider.items.where((a) => a.type == AlertType.logMissing), isEmpty);
    });

    test('removes a stale same-day fertility alert', () {
      final s = bindStandard(modes: {TrackingMode.pregnancy}, lmp: today().add(const Duration(days: -60)));
      final id = 'fertile-${todayKey()}';
      s.provider.restore(item(id, read: true));
      s.provider.generate();
      expect(s.provider.items.where((a) => a.id == id), isEmpty);
    });

    test('dismissed moon alerts stay gone after generate and reload', () async {
      final id = 'moon-full-${todayKey()}';
      final provider = AlertProvider(prefs, items: [item(id, event: today())]);
      final onboarding = OnboardingProvider(prefs, onboarded: true, cycleLength: 28, bleedLength: 5, lastPeriodStart: today().add(const Duration(days: -10)));
      final logging = LoggingProvider(prefs);
      final cycle = CycleProvider(onboarding, logging);
      provider.bind(cycle, logging);

      provider.dismiss(id);
      provider.generate();
      expect(provider.items.where((a) => a.id == id), isEmpty);
      await pumpEventQueue();

      final reloaded = await AlertProvider.load(prefs);
      expect(reloaded.items.where((a) => a.id == id), isEmpty);
      expect(await prefs.dismissedAlertIds(), contains(id));
    });
  });
}
