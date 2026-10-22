import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:witchy/providers/cycle_provider.dart';
import 'package:witchy/providers/logging_provider.dart';
import 'package:witchy/providers/onboarding_provider.dart';
import 'package:witchy/screens/bleed_history_screen.dart';
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

  Future<void> pumpBleeding(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<PrefsService>.value(value: prefs),
          ChangeNotifierProvider<OnboardingProvider>.value(value: onboarding),
          ChangeNotifierProvider<LoggingProvider>.value(value: logging),
          ChangeNotifierProvider<CycleProvider>.value(value: cycle),
        ],
        child: const MaterialApp(home: BleedHistoryScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows the countdown, averages and empty states', (tester) async {
    await pumpBleeding(tester);
    expect(find.text('Bleeding'), findsOneWidget);
    expect(find.text('BLEEDING IN'), findsOneWidget);
    expect(find.text('AVERAGE BLEED'), findsOneWidget);
    expect(find.text('—'), findsOneWidget);
    expect(find.text('Recent Periods'), findsOneWidget);
    expect(find.text('Log a bleeding day and your periods will appear here.'), findsOneWidget);
    expect(find.text('Flow Log'), findsOneWidget);
    expect(find.textContaining('No flow logged yet'), findsOneWidget);
  });

  testWidgets('lists logged bleed spans and flow days', (tester) async {
    final today = DateTime.now();
    final midnight = DateTime(today.year, today.month, today.day);
    logging.setFlow(midnight.subtract(const Duration(days: 3)), 'Heavy');
    logging.setFlow(midnight, 'Medium');
    await pumpBleeding(tester);

    expect(find.text('Medium'), findsOneWidget);
    expect(find.text('Heavy'), findsOneWidget);
    expect(find.textContaining('A bleeding day is logged'), findsOneWidget);
    expect(find.text('Recent Periods'), findsOneWidget);
  });

  testWidgets('late but projecting shows Days Late instead of Today', (tester) async {
    final today = DateTime.now();
    final midnight = DateTime(today.year, today.month, today.day);
    final last = DateTime(midnight.year, midnight.month, midnight.day - 30);
    onboarding = OnboardingProvider(prefs, onboarded: true, cycleLength: 28, bleedLength: 5, lastPeriodStart: last);
    logging = LoggingProvider(prefs);
    logging.setFlow(DateTime(last.year, last.month, last.day - 28), 'Medium');
    logging.setFlow(last, 'Medium');
    cycle = CycleProvider(onboarding, logging);
    await pumpBleeding(tester);

    expect(find.text('2 Days Late'), findsOneWidget);
    expect(find.text('log your period to re-anchor'), findsOneWidget);
  });

  testWidgets('add past period saves a range', (tester) async {
    await pumpBleeding(tester);
    await tester.tap(find.text('Add past period'));
    await tester.pumpAndSettle();

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
    expect(logging.periodRecords.single.end, DateTime(month.year, month.month, 2));
  });
}
