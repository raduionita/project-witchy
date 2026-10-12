import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:witchy/providers/cycle_provider.dart';
import 'package:witchy/providers/logging_provider.dart';
import 'package:witchy/providers/onboarding_provider.dart';
import 'package:witchy/screens/bleeding_screen.dart';
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

  Future<void> pumpBleeding(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<PrefsService>.value(value: prefs),
          ChangeNotifierProvider<OnboardingProvider>.value(value: onboarding),
          ChangeNotifierProvider<LoggingProvider>.value(value: logging),
          ChangeNotifierProvider<CycleProvider>.value(value: cycle),
        ],
        child: const MaterialApp(home: BleedingScreen()),
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
    expect(find.textContaining('Logged as bleed day'), findsOneWidget);
    expect(find.text('Recent Periods'), findsOneWidget);
  });
}
