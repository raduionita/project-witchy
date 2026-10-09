import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:witchy/providers/cycle_provider.dart';
import 'package:witchy/providers/logging_provider.dart';
import 'package:witchy/providers/onboarding_provider.dart';
import 'package:witchy/screens/records_screen.dart';
import 'package:witchy/services/prefs_service.dart';

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

  Future<void> pumpRecords(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<PrefsService>.value(value: prefs),
          ChangeNotifierProvider<OnboardingProvider>.value(value: onboarding),
          ChangeNotifierProvider<LoggingProvider>.value(value: logging),
          ChangeNotifierProvider<CycleProvider>.value(value: cycle),
        ],
        child: const MaterialApp(home: RecordsScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('irregularity shows the empty state until two cycles are logged', (tester) async {
    await pumpRecords(tester);
    expect(find.text('Irregularity'), findsOneWidget);
    expect(find.text('Log two completed cycles to see your spread.'), findsOneWidget);
    expect(find.textContaining('variation'), findsNothing);
  });

  testWidgets('two observed cycles render the shortest-to-longest spread', (tester) async {
    for (final start in [DateTime(2026, 7, 1), DateTime(2026, 7, 29), DateTime(2026, 9, 2)]) {
      logging.setFlow(start, 'Medium');
    }
    await pumpRecords(tester);
    expect(find.text('Irregularity'), findsOneWidget);
    expect(find.text('28–35 Days'), findsOneWidget);
    expect(find.text('Shortest to longest cycle'), findsOneWidget);
    expect(find.text('7 Days variation'), findsOneWidget);
    expect(find.text('Log two completed cycles to see your spread.'), findsNothing);
  });
}
