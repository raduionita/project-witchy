import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:witchy/models/tracking_mode.dart';
import 'package:witchy/providers/cycle_provider.dart';
import 'package:witchy/providers/gestation_provider.dart';
import 'package:witchy/providers/logging_provider.dart';
import 'package:witchy/providers/onboarding_provider.dart';
import 'package:witchy/screens/sanctuary_screen.dart';
import 'package:witchy/services/prefs_service.dart';

void main() {
  Future<void> pumpSanctuary(
    WidgetTester tester, {
    required TrackingMode mode,
    Set<TrackingMode>? modes,
    DateTime? lmpDate,
    DateTime? lastPeriodStart,
    List<DateTime> seedStarts = const [],
  }) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = PrefsService();
    final onboarding = OnboardingProvider(
      prefs,
      onboarded: true,
      cycleLength: 28,
      bleedLength: 5,
      lastPeriodStart: lastPeriodStart ?? DateTime.now().subtract(const Duration(days: 13)),
      trackingModes: modes ?? {mode},
    );
    final logging = LoggingProvider(prefs);
    for (final start in seedStarts) {
      logging.setFlow(start, 'Medium');
    }
    final gestation = GestationProvider(prefs, lmpDate: lmpDate);
    final cycle = CycleProvider(onboarding, logging, gestation: gestation);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<PrefsService>.value(value: prefs),
          ChangeNotifierProvider<OnboardingProvider>.value(value: onboarding),
          ChangeNotifierProvider<LoggingProvider>.value(value: logging),
          ChangeNotifierProvider<CycleProvider>.value(value: cycle),
        ],
        child: const MaterialApp(home: SanctuaryScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('perimenopause shows a bleeding window and hides the fertility card', (tester) async {
    await pumpSanctuary(tester, mode: TrackingMode.perimenopause);
    expect(find.text('BLEEDING IN'), findsOneWidget);
    expect(find.text('FERTILITY WINDOW'), findsNothing);
    // No observed history: single-day window still rendered with range sub.
    expect(find.textContaining('· range'), findsOneWidget);
    expect(find.textContaining('· predicted'), findsNothing);
  });

  testWidgets('cycle mode keeps the single-day countdown and fertility card', (tester) async {
    await pumpSanctuary(tester, mode: TrackingMode.cycle);
    expect(find.text('FERTILITY WINDOW'), findsOneWidget);
    expect(find.textContaining('· predicted'), findsWidgets);
    expect(find.textContaining('· range'), findsNothing);
  });

  testWidgets('cycle mode with variable history shows the earliest-latest range', (tester) async {
    final now = DateTime.now();
    final last = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 13));
    await pumpSanctuary(tester, mode: TrackingMode.cycle, seedStarts: [last.subtract(const Duration(days: 63)), last.subtract(const Duration(days: 28)), last]);
    expect(find.text('FERTILITY WINDOW'), findsOneWidget);
    expect(find.textContaining('· range'), findsOneWidget);
    expect(find.textContaining('· predicted'), findsNothing);
  });

  testWidgets('pregnancy gap state shows the setup nudge', (tester) async {
    await pumpSanctuary(tester, mode: TrackingMode.cycle, modes: {TrackingMode.cycle, TrackingMode.pregnancy});
    expect(find.text('Set up tracker'), findsOneWidget);
    expect(find.text('add dates in Pregnancy Tracker'), findsOneWidget);
    // Cycle predictions still run until dates are entered.
    expect(find.text('FERTILITY WINDOW'), findsOneWidget);
  });

  testWidgets('dated pregnancy replaces the countdown and hides fertility', (tester) async {
    await pumpSanctuary(
      tester,
      mode: TrackingMode.cycle,
      modes: {TrackingMode.cycle, TrackingMode.pregnancy},
      lmpDate: DateTime.now().subtract(const Duration(days: 60)),
    );
    expect(find.text('Pregnancy'), findsOneWidget);
    expect(find.text('open Pregnancy Tracker'), findsOneWidget);
    expect(find.text('FERTILITY WINDOW'), findsNothing);
  });

  testWidgets('shows the medical disclaimer under predictions', (tester) async {
    await pumpSanctuary(tester, mode: TrackingMode.cycle);
    expect(find.text('Predictions are estimates - not a contraceptive and not medical advice.'), findsOneWidget);
  });

  testWidgets('late but projecting shows Days Late on the countdown', (tester) async {
    final now = DateTime.now();
    final last = DateTime(now.year, now.month, now.day - 30);
    await pumpSanctuary(
      tester,
      mode: TrackingMode.cycle,
      lastPeriodStart: last,
      seedStarts: [DateTime(last.year, last.month, last.day - 28), last],
    );
    expect(find.text('2 Days Late'), findsOneWidget);
    expect(find.text('log your period to re-anchor'), findsOneWidget);
    // Predictions still run while projecting: fertility card stays.
    expect(find.text('FERTILITY WINDOW'), findsOneWidget);
  });
}
