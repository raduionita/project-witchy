import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:witchy/models/tracking_mode.dart';
import 'package:witchy/providers/cycle_provider.dart';
import 'package:witchy/providers/gestation_provider.dart';
import 'package:witchy/providers/logging_provider.dart';
import 'package:witchy/providers/onboarding_provider.dart';
import 'package:witchy/screens/today_screen.dart';
import 'package:witchy/services/prefs_service.dart';

void main() {
  Future<void> pumpToday(
    WidgetTester tester, {
    required TrackingMode mode,
    Set<TrackingMode>? modes,
    DateTime? lmpDate,
    DateTime? lastPeriodStart,
    DateTime? spottingDay,
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
      // Two days: a single flow day is spotting and would not seed cycle stats.
      logging.setFlow(start, 'Medium');
      logging.setFlow(DateTime(start.year, start.month, start.day + 1), 'Light');
    }
    if (spottingDay != null) logging.setFlow(spottingDay, 'Spotting');
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
        child: const MaterialApp(home: TodayScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('perimenopause shows a bleeding window and hides the fertility card', (tester) async {
    await pumpToday(tester, mode: TrackingMode.perimenopause);
    expect(find.text('BLEEDING IN'), findsOneWidget);
    expect(find.text('FERTILITY WINDOW'), findsNothing);
    // No observed history: single-day window still rendered with range sub.
    expect(find.textContaining('· range'), findsOneWidget);
    expect(find.textContaining('· predicted'), findsNothing);
  });

  testWidgets('cycle mode keeps the single-day countdown and fertility card', (tester) async {
    await pumpToday(tester, mode: TrackingMode.cycle);
    expect(find.text('FERTILITY WINDOW'), findsOneWidget);
    expect(find.textContaining('· predicted'), findsWidgets);
    expect(find.textContaining('· range'), findsNothing);
    expect(find.text('Based on default 28 days'), findsOneWidget);
  });

  testWidgets('before-window countdown targets the window start, not ovulation', (tester) async {
    final now = DateTime.now();
    final last = DateTime(now.year, now.month, now.day - 2);
    await pumpToday(tester, mode: TrackingMode.cycle, lastPeriodStart: last);
    // Cycle day 3 with a 28-day cycle: window opens on day 9, six days away.
    expect(find.text('In 6 Days'), findsOneWidget);
    expect(find.textContaining('· window opens'), findsOneWidget);
  });

  testWidgets('cycle mode with variable history shows the earliest-latest range', (tester) async {
    final now = DateTime.now();
    final last = DateTime(now.year, now.month, now.day).subtract(const Duration(days: 13));
    await pumpToday(tester, mode: TrackingMode.cycle, seedStarts: [last.subtract(const Duration(days: 63)), last.subtract(const Duration(days: 28)), last]);
    expect(find.text('FERTILITY WINDOW'), findsOneWidget);
    expect(find.textContaining('· range'), findsOneWidget);
    expect(find.textContaining('· predicted'), findsNothing);
    expect(find.text('Based on 2 cycles'), findsOneWidget);
  });

  testWidgets('pregnancy gap state shows the setup nudge', (tester) async {
    await pumpToday(tester, mode: TrackingMode.cycle, modes: {TrackingMode.cycle, TrackingMode.pregnancy});
    expect(find.text('Set up tracker'), findsOneWidget);
    expect(find.text('add dates in Pregnancy Tracker'), findsOneWidget);
    // Cycle predictions still run until dates are entered.
    expect(find.text('FERTILITY WINDOW'), findsOneWidget);
  });

  testWidgets('dated pregnancy replaces the countdown and hides fertility', (tester) async {
    await pumpToday(
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
    await pumpToday(tester, mode: TrackingMode.cycle);
    // The disclaimer sits at the very bottom of the scroll view.
    await tester.dragUntilVisible(
      find.text('Predictions are estimates - not a contraceptive and not medical advice.'),
      find.byType(ListView),
      const Offset(0, -200),
    );
    expect(find.text('Predictions are estimates - not a contraceptive and not medical advice.'), findsOneWidget);
  });

  testWidgets('late but projecting shows Days Late on the countdown', (tester) async {
    final now = DateTime.now();
    final last = DateTime(now.year, now.month, now.day - 30);
    await pumpToday(
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

  testWidgets('an overdue cycle pauses fertility and keeps the real cycle day', (tester) async {
    final now = DateTime.now();
    final last = DateTime(now.year, now.month, now.day - 34);
    await pumpToday(
      tester,
      mode: TrackingMode.cycle,
      lastPeriodStart: last,
      seedStarts: [DateTime(last.year, last.month, last.day - 28), last],
    );
    expect(find.text('6 Days Late'), findsOneWidget);
    expect(find.text('period overdue - consider a test'), findsOneWidget);
    expect(find.text('FERTILITY WINDOW'), findsNothing);
    // Elapsed day, not the wrapped modular day (which would be 7).
    expect(find.text('Cycle Day 35'), findsOneWidget);
  });

  testWidgets('a stopped projection still surfaces the overdue test prompt', (tester) async {
    final now = DateTime.now();
    final last = DateTime(now.year, now.month, now.day - 39);
    await pumpToday(
      tester,
      mode: TrackingMode.cycle,
      lastPeriodStart: last,
      seedStarts: [DateTime(last.year, last.month, last.day - 28), last],
    );
    expect(find.text('Log to update'), findsOneWidget);
    expect(find.text('period overdue - consider a test'), findsOneWidget);
    expect(find.text('FERTILITY WINDOW'), findsNothing);
  });

  testWidgets('a spotting day never shows a Period Day tag', (tester) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final last = DateTime(today.year, today.month, today.day - 13);
    await pumpToday(
      tester,
      mode: TrackingMode.cycle,
      lastPeriodStart: last,
      seedStarts: [last],
      spottingDay: today,
    );
    expect(find.text('Cycle Day 14'), findsOneWidget);
    expect(find.textContaining('Period Day'), findsNothing);
  });

  testWidgets('a due window that already started shows Due Now, not next-cycle dates', (tester) async {
    final now = DateTime.now();
    final last = DateTime(now.year, now.month, now.day - 29);
    await pumpToday(
      tester,
      mode: TrackingMode.cycle,
      lastPeriodStart: last,
      seedStarts: [
        DateTime(last.year, last.month, last.day - 63),
        DateTime(last.year, last.month, last.day - 28),
        last,
      ],
    );
    expect(find.text('Due Now'), findsOneWidget);
    expect(find.textContaining('27 Days'), findsNothing);
  });
}
