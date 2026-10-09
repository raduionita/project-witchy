import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:witchy/providers/cycle_provider.dart';
import 'package:witchy/providers/logging_provider.dart';
import 'package:witchy/providers/onboarding_provider.dart';
import 'package:witchy/screens/chart_screen.dart';
import 'package:witchy/services/prefs_service.dart';

void main() {
  late PrefsService prefs;
  late OnboardingProvider onboarding;
  late LoggingProvider logging;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    prefs = PrefsService();
    onboarding = OnboardingProvider(prefs, onboarded: true, cycleLength: 28, bleedLength: 5, lastPeriodStart: DateTime.now());
    logging = LoggingProvider(prefs);
  });

  Future<void> pumpChart(WidgetTester tester) async {
    final cycle = CycleProvider(onboarding, logging);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<LoggingProvider>.value(value: logging),
          ChangeNotifierProvider<CycleProvider>.value(value: cycle),
        ],
        child: const MaterialApp(home: ChartScreen()),
      ),
    );
    await tester.pump();
  }

  testWidgets('empty state prompts to log a temperature', (tester) async {
    await pumpChart(tester);

    expect(find.text('No temperatures yet'), findsOneWidget);
    expect(find.text('Log your temperature'), findsOneWidget);
    expect(find.text('Biphasic Temperature Shift'), findsNothing);
  });

  testWidgets('renders the plot and shift averages once temperatures exist', (tester) async {
    final today = DateTime.now();
    for (var i = 0; i < 10; i++) {
      logging.setTemperature(DateTime(today.year, today.month, today.day - i), 36.0 + (i % 3) * 0.2);
    }
    await pumpChart(tester);

    expect(find.text('Biphasic Temperature Shift'), findsOneWidget);
    expect(find.text('Pre-shift average'), findsOneWidget);
    expect(find.text('Post-shift rise'), findsOneWidget);
    expect(find.text('No temperatures yet'), findsNothing);
  });
}
