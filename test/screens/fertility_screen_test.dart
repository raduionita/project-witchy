import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:witchy/providers/cycle_provider.dart';
import 'package:witchy/providers/logging_provider.dart';
import 'package:witchy/providers/onboarding_provider.dart';
import 'package:witchy/screens/fertility_screen.dart';
import 'package:witchy/services/prefs_service.dart';

void main() {
  Future<void> pumpFertility(
    WidgetTester tester, {
    DateTime? lastPeriodStart,
  }) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = PrefsService();
    final onboarding = OnboardingProvider(
      prefs,
      onboarded: true,
      cycleLength: 28,
      bleedLength: 5,
      lastPeriodStart: lastPeriodStart ?? DateTime.now().subtract(const Duration(days: 13)),
    );
    final logging = LoggingProvider(prefs);
    final cycle = CycleProvider(onboarding, logging);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<PrefsService>.value(value: prefs),
          ChangeNotifierProvider<OnboardingProvider>.value(value: onboarding),
          ChangeNotifierProvider<LoggingProvider>.value(value: logging),
          ChangeNotifierProvider<CycleProvider>.value(value: cycle),
        ],
        child: const MaterialApp(home: FertilityScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('shows the medical disclaimer under predictions', (tester) async {
    await pumpFertility(tester);
    expect(find.text('Fertility Window'), findsWidgets);
    expect(find.text('Predictions are estimates - not a contraceptive and not medical advice.'), findsOneWidget);
    expect(find.text('Based on default 28 days'), findsOneWidget);
  });

  testWidgets('uses neutral cycle framing without a goal', (tester) async {
    await pumpFertility(tester);
    expect(find.text('Cycle notes'), findsOneWidget);
    expect(find.text('TTC Tips'), findsNothing);
    expect(find.text('FERTILITY'), findsOneWidget);
  });
}
