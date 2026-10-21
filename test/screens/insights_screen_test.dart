import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:witchy/providers/cycle_provider.dart';
import 'package:witchy/providers/logging_provider.dart';
import 'package:witchy/providers/onboarding_provider.dart';
import 'package:witchy/screens/insights_screen.dart';
import 'package:witchy/services/prefs_service.dart';

DateTime previousMonth() {
  final now = DateTime.now();
  return DateTime(now.year, now.month - 1);
}

void main() {
  late PrefsService prefs;
  late OnboardingProvider onboarding;
  late LoggingProvider logging;
  late CycleProvider cycle;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    prefs = PrefsService();
    onboarding = OnboardingProvider(prefs, onboarded: true, cycleLength: 28, bleedLength: 5, lastPeriodStart: DateTime(2026, 9, 2));
    logging = LoggingProvider(prefs);
    cycle = CycleProvider(onboarding, logging);
  });

  Future<void> pumpInsights(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<PrefsService>.value(value: prefs),
          ChangeNotifierProvider<OnboardingProvider>.value(value: onboarding),
          ChangeNotifierProvider<LoggingProvider>.value(value: logging),
          ChangeNotifierProvider<CycleProvider>.value(value: cycle),
        ],
        child: const MaterialApp(home: InsightsScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('irregularity shows the empty state until two cycles are logged', (tester) async {
    await pumpInsights(tester);
    expect(find.text('Irregularity'), findsOneWidget);
    expect(find.text('Log two completed cycles to see your spread.'), findsOneWidget);
    expect(find.textContaining('variation'), findsNothing);
  });

  testWidgets('two observed cycles render the shortest-to-longest spread', (tester) async {
    for (final start in [DateTime(2026, 7, 1), DateTime(2026, 7, 29), DateTime(2026, 9, 2)]) {
      logging.setFlow(start, 'Medium');
      // Two days: a single flow day counts as spotting, not as a period.
      logging.setFlow(DateTime(start.year, start.month, start.day + 1), 'Light');
    }
    await pumpInsights(tester);
    expect(find.text('Irregularity'), findsOneWidget);
    expect(find.text('28–35 Days'), findsOneWidget);
    expect(find.text('Shortest to longest cycle'), findsOneWidget);
    expect(find.text('Regular · 7 Days'), findsOneWidget);
    expect(find.text('Log two completed cycles to see your spread.'), findsNothing);
  });

  testWidgets('add past period saves a range', (tester) async {
    await pumpInsights(tester);
    await tester.tap(find.text('Add past period'));
    await tester.pumpAndSettle();
    expect(find.text('Save period'), findsOneWidget);

    // Pick the first two days of the previous month, so they are always past.
    final month = previousMonth();
    await tester.tap(find.byKey(const Key('period-prev-month')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('period-day-${month.year}-${month.month}-1')));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key('period-day-${month.year}-${month.month}-2')));
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.text('Save period'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save period'));
    await tester.pumpAndSettle();
    expect(logging.periodRecords, hasLength(1));
    expect(logging.periodRecords.single.startOnly, isFalse);
    expect(logging.periodRecords.single.start, DateTime(month.year, month.month, 1));
    expect(logging.periodRecords.single.end, DateTime(month.year, month.month, 2));
  });

  testWidgets('editing a record saves without duplicating it', (tester) async {
    logging.addPeriodRecord(DateTime(2026, 7, 1), end: DateTime(2026, 7, 4));
    await pumpInsights(tester);
    await tester.scrollUntilVisible(find.text('Jul 1 - Jul 4'), 300);
    await tester.tap(find.text('Jul 1 - Jul 4'));
    await tester.pumpAndSettle();
    expect(find.text('Edit past period'), findsOneWidget);
    await tester.ensureVisible(find.text('Save period'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Save period'));
    await tester.pumpAndSettle();
    expect(logging.periodRecords, hasLength(1));
    expect(logging.periodRecords.single.end, DateTime(2026, 7, 4));
  });

  testWidgets('period history row opens the editor and deletes the record', (tester) async {
    logging.addPeriodRecord(DateTime(2026, 7, 1));
    await pumpInsights(tester);
    await tester.scrollUntilVisible(find.text('Jul 1'), 300);
    await tester.tap(find.text('Jul 1'));
    await tester.pumpAndSettle();
    expect(find.text('Edit past period'), findsOneWidget);
    await tester.ensureVisible(find.text('Delete period'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Delete period'));
    await tester.pumpAndSettle();
    expect(find.text('Delete this period?'), findsOneWidget);
    await tester.tap(find.text('Delete'));
    await tester.pumpAndSettle();
    expect(logging.periodRecords, isEmpty);
  });
}
