import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:witchy/models/alert_type.dart';
import 'package:witchy/models/tracking_mode.dart';
import 'package:witchy/providers/cycle_provider.dart';
import 'package:witchy/providers/gestation_provider.dart';
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

    test('window start fires the fertile-start alert exactly once', () {
      // No logged history: pad 2 widens the 28-day window to days 7-17,
      // so Oct 9 opens the window when the last period began Oct 3.
      final s = build(DateTime(2026, 10, 3));
      final out = AlertGenerator.generate(cycle: s.cycle, logging: s.logging, now: now);
      expect(out.where((a) => a.type == AlertType.fertileWindow).single.id, 'fertile-start-2026-10-09');
      // Mid-window days stay quiet.
      final mid = build(DateTime(2026, 10, 2));
      final midOut = AlertGenerator.generate(cycle: mid.cycle, logging: mid.logging, now: now);
      expect(midOut.where((a) => a.type == AlertType.fertileWindow), isEmpty);
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

    test('perimenopause-only mode emits no fertility alerts', () {
      // Fertility alerts follow the same cycle-mode gate as the calendar.
      final s = buildPeri(now.subtract(const Duration(days: 13)));
      final out = AlertGenerator.generate(cycle: s.cycle, logging: s.logging, now: now);
      expect(out.where((a) => a.type == AlertType.fertileWindow), isEmpty);
    });

    test('perimenopause stays quiet outside the raw ovulation day', () {
      final s = buildPeri(now.subtract(const Duration(days: 5)));
      final out = AlertGenerator.generate(cycle: s.cycle, logging: s.logging, now: now);
      expect(out.where((a) => a.type == AlertType.fertileWindow), isEmpty);
    });

    test('one day late fires a late alert instead of the period countdown', () {
      final s = build(now.subtract(const Duration(days: 29)));
      final out = AlertGenerator.generate(cycle: s.cycle, logging: s.logging, now: now);
      final late = out.where((a) => a.type == AlertType.periodPredicted).single;
      expect(late.id, 'late-d1-2026-10-09');
      expect(late.body, contains('1 day late'));
      expect(out.where((a) => a.id.startsWith('period-d')), isEmpty);
    });

    test('five days late still fires the late alert', () {
      final s = build(now.subtract(const Duration(days: 33)));
      final out = AlertGenerator.generate(cycle: s.cycle, logging: s.logging, now: now);
      final late = out.where((a) => a.type == AlertType.periodPredicted).single;
      expect(late.id, 'late-d5-2026-10-09');
      expect(late.body, contains('5 days late'));
    });

    test('on-time due date fires no late alert', () {
      final s = build(now.subtract(const Duration(days: 28)));
      final out = AlertGenerator.generate(cycle: s.cycle, logging: s.logging, now: now);
      expect(out.where((a) => a.id.startsWith('late-d')), isEmpty);
    });

    test('lost confidence hides fertility alerts even mid-window', () {
      // 62 days elapsed: cycle day 7 opens the widened window, but 34 days
      // late is past longest+5, so no fertile-start alert fires.
      final s = build(now.subtract(const Duration(days: 62)));
      final out = AlertGenerator.generate(cycle: s.cycle, logging: s.logging, now: now);
      expect(out.where((a) => a.type == AlertType.fertileWindow), isEmpty);
    });

    test('stopped projection hides the period countdown', () {
      // 83 days elapsed: modular math says due in 1 day, but 55 days late
      // is past longest+10, so no period alert fires.
      final s = build(now.subtract(const Duration(days: 83)));
      final out = AlertGenerator.generate(cycle: s.cycle, logging: s.logging, now: now);
      expect(out.where((a) => a.type == AlertType.periodPredicted), isEmpty);
    });

    group('pregnancy suppression (A5)', () {
      Src buildPreg(DateTime lastStart) {
        final onboarding = OnboardingProvider(
          prefs,
          onboarded: true,
          cycleLength: 28,
          bleedLength: 5,
          lastPeriodStart: lastStart,
          trackingModes: {TrackingMode.cycle, TrackingMode.pregnancy},
        );
        final logging = LoggingProvider(prefs);
        final gestation = GestationProvider(prefs, lmpDate: DateTime(2026, 8, 1));
        return (cycle: CycleProvider(onboarding, logging, gestation: gestation), logging: logging);
      }

      test('suppressed countdown day fires no period alert', () {
        // Due Oct 11 (2 days out) would fire period-d2 without suppression.
        final s = buildPreg(DateTime(2026, 9, 13));
        final out = AlertGenerator.generate(cycle: s.cycle, logging: s.logging, now: now);
        expect(out.where((a) => a.type == AlertType.periodPredicted), isEmpty);
      });

      test('suppressed late day fires no late alert', () {
        // Due Oct 6 means 3 days late - would fire late-d3 without suppression.
        final s = buildPreg(DateTime(2026, 9, 8));
        final out = AlertGenerator.generate(cycle: s.cycle, logging: s.logging, now: now);
        expect(out.where((a) => a.type == AlertType.periodPredicted), isEmpty);
        expect(out.where((a) => a.type == AlertType.fertileWindow), isEmpty);
      });

      test('moon milestones still fire while suppressed', () {
        final s = buildPreg(DateTime(2026, 9, 13));
        // The reference new moon itself always carries a new-moon alert.
        final out = AlertGenerator.generate(cycle: s.cycle, logging: s.logging, now: AlertGenerator.newMoonEpoch);
        expect(out.where((a) => a.id.startsWith('moon-new-')), hasLength(1));
      });
    });
  });
}
