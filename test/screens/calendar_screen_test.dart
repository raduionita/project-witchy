import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:witchy/models/tracking_mode.dart';
import 'package:witchy/providers/cycle_provider.dart';
import 'package:witchy/providers/logging_provider.dart';
import 'package:witchy/providers/onboarding_provider.dart';
import 'package:witchy/screens/calendar_screen.dart';
import 'package:witchy/services/prefs_service.dart';
import 'package:witchy/widgets/app_button.dart';
import 'package:witchy/widgets/cycle_calendar.dart';

void main() {
  testWidgets('cycle-mode spread passes the predicted range to the calendar', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = PrefsService();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastStart = DateTime(today.year, today.month, today.day - 26);
    final onboarding = OnboardingProvider(
      prefs,
      onboarded: true,
      cycleLength: 28,
      bleedLength: 5,
      lastPeriodStart: lastStart,
      trackingModes: {TrackingMode.cycle},
    );
    final logging = LoggingProvider(prefs);
    for (final start in [
      DateTime(lastStart.year, lastStart.month, lastStart.day - 56),
      DateTime(lastStart.year, lastStart.month, lastStart.day - 30),
      lastStart,
    ]) {
      logging.setFlow(start, 'Medium');
      logging.setFlow(DateTime(start.year, start.month, start.day + 1), 'Light');
    }
    final cycle = CycleProvider(onboarding, logging);

    expect(cycle.showPeriodRange, isTrue);
    expect(cycle.predictedRange()?.earliest, today);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<LoggingProvider>.value(value: logging),
          ChangeNotifierProvider<CycleProvider>.value(value: cycle),
        ],
        child: const MaterialApp(home: CalendarScreen()),
      ),
    );
    await tester.pumpAndSettle();

    final calendar = tester.widget<CycleCalendar>(find.byType(CycleCalendar));
    expect(calendar.cells.cellFor(today.day)?.isPredictedPeriod, isTrue);

    final tomorrow = DateTime(today.year, today.month, today.day + 1);
    if (tomorrow.month == today.month) {
      expect(calendar.cells.cellFor(tomorrow.day)?.isPredictedPeriod, isTrue);
    }
  });

  testWidgets('an empty selected day shows the log card', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = PrefsService();
    final now = DateTime.now();
    final lastStart = DateTime(now.year, now.month, now.day - 13);
    final onboarding = OnboardingProvider(
      prefs,
      onboarded: true,
      cycleLength: 28,
      bleedLength: 5,
      lastPeriodStart: lastStart,
      trackingModes: {TrackingMode.cycle},
    );
    final logging = LoggingProvider(prefs);
    final cycle = CycleProvider(onboarding, logging);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<LoggingProvider>.value(value: logging),
          ChangeNotifierProvider<CycleProvider>.value(value: cycle),
        ],
        child: const MaterialApp(home: CalendarScreen()),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Nothing logged yet'), findsOneWidget);
    expect(find.text('Log this day'), findsOneWidget);
    expect(find.byType(AppButton), findsOneWidget);
  });
}
