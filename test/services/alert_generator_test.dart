import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:witchy/models/alert_type.dart';
import 'package:witchy/models/tracking_mode.dart';
import 'package:witchy/providers/cycle_provider.dart';
import 'package:witchy/providers/logging_provider.dart';
import 'package:witchy/providers/onboarding_provider.dart';
import 'package:witchy/services/alert_generator.dart';
import 'package:witchy/services/prefs_service.dart';

typedef Src = ({CycleProvider cycle, LoggingProvider logging});

void main() {
  late PrefsService prefs;
  final now = DateTime(2026, 10, 9, 12);

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    prefs = PrefsService();
  });

  ({CycleProvider cycle, LoggingProvider logging}) build(DateTime lastStart) {
    final onboarding = OnboardingProvider(
      prefs,
      onboarded: true,
      cycleLength: 28,
      bleedLength: 5,
      lastPeriodStart: lastStart,
    );
    final logging = LoggingProvider(prefs);
    return (cycle: CycleProvider(onboarding, logging), logging: logging);
  }

  ({CycleProvider cycle, LoggingProvider logging}) buildPeri(DateTime lastStart) {
    final onboarding = OnboardingProvider(
      prefs,
      onboarded: true,
      cycleLength: 28,
      bleedLength: 5,
      lastPeriodStart: lastStart,
      trackingModes: {TrackingMode.perimenopause},
    );
    final logging = LoggingProvider(prefs);
    return (cycle: CycleProvider(onboarding, logging), logging: logging);
  }

  group('AlertGenerator', () {
    test('period predicted in 2 days fires a period alert', () {
      final s = build(now.subtract(const Duration(days: 26)));
      final out = AlertGenerator.generate(cycle: s.cycle, logging: s.logging, now: now);
      final alert = out.where((a) => a.type == AlertType.periodPredicted).single;
      expect(alert.id, startsWith('period-d2-'));
      expect(alert.body, contains('in 2 days'));
      expect(alert.eventDate, DateTime(2026, 10, 11));
    });

    test('period predicted in 1 day fires a period alert', () {
      final s = build(now.subtract(const Duration(days: 27)));
      final out = AlertGenerator.generate(cycle: s.cycle, logging: s.logging, now: now);
      final alert = out.where((a) => a.type == AlertType.periodPredicted).single;
      expect(alert.id, startsWith('period-d1-'));
      expect(alert.body, contains('in 1 day'));
    });

    test('no period alert when the prediction is further out', () {
      final s = build(now.subtract(const Duration(days: 10)));
      final out = AlertGenerator.generate(cycle: s.cycle, logging: s.logging, now: now);
      expect(out.where((a) => a.type == AlertType.periodPredicted), isEmpty);
    });

    test('ovulation day fires the fertile peak alert', () {
      // Ovulation is cycle day 14, i.e. start + 13 days.
      final s = build(now.subtract(const Duration(days: 13)));
      final out = AlertGenerator.generate(cycle: s.cycle, logging: s.logging, now: now);
      expect(out.where((a) => a.type == AlertType.fertileWindow).single.id, 'fertile-2026-10-09');
    });

    test('log missing alert only after 18:00 and only when unlogged', () {
      final s = build(now.subtract(const Duration(days: 5)));
      final evening = DateTime(2026, 10, 9, 18, 30);
      final morning = DateTime(2026, 10, 9, 10);

      bool missing(Src s, DateTime at) =>
          AlertGenerator.generate(cycle: s.cycle, logging: s.logging, now: at)
              .where((a) => a.type == AlertType.logMissing)
              .isNotEmpty;

      expect(missing(s, morning), isFalse);
      expect(missing(s, evening), isTrue);

      s.logging.setFlow(DateTime(2026, 10, 9), 'Medium');
      expect(missing(s, evening), isFalse);
    });

    test('lunar milestone detects new and full moon, null otherwise', () {
      final newMoon = AlertGenerator.lunarMilestone(AlertGenerator.newMoonEpoch);
      expect(newMoon, isNotNull);
      expect(newMoon!.id, startsWith('moon-new-'));

      final full = AlertGenerator.lunarMilestone(
        AlertGenerator.newMoonEpoch.add(Duration(milliseconds: (14.7652944265 * 86400000).round())),
      );
      expect(full, isNotNull);
      expect(full!.id, startsWith('moon-full-'));

      expect(
        AlertGenerator.lunarMilestone(AlertGenerator.newMoonEpoch.add(const Duration(days: 7))),
        isNull,
      );
    });

    test('generation is deterministic for the same inputs (stable ids)', () {
      final s = build(now.subtract(const Duration(days: 26)));
      final a = AlertGenerator.generate(cycle: s.cycle, logging: s.logging, now: now);
      final b = AlertGenerator.generate(cycle: s.cycle, logging: s.logging, now: now);
      expect([for (final x in a) x.id], [for (final x in b) x.id]);
    });

    test('perimenopause ovulation day fires the hedged window alert', () {
      // Raw ovulation is start + 13 days but the peak alert gate is suppressed.
      final s = buildPeri(now.subtract(const Duration(days: 13)));
      expect(s.cycle.isOvulationDay(DateTime(2026, 10, 9)), isFalse);
      final out = AlertGenerator.generate(cycle: s.cycle, logging: s.logging, now: now);
      final alert = out.where((a) => a.type == AlertType.fertileWindow).single;
      expect(alert.title, 'Fertility Window');
      expect(alert.body, contains('may open as early as today'));
      expect(alert.id, 'fertile-2026-10-09');
    });

    test('perimenopause stays quiet outside the raw ovulation day', () {
      final s = buildPeri(now.subtract(const Duration(days: 5)));
      final out = AlertGenerator.generate(cycle: s.cycle, logging: s.logging, now: now);
      expect(out.where((a) => a.type == AlertType.fertileWindow), isEmpty);
    });
  });
}
