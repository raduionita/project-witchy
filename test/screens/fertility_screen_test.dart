import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:witchy/models/cycle_goal.dart';
import 'package:witchy/providers/cycle_provider.dart';
import 'package:witchy/providers/logging_provider.dart';
import 'package:witchy/providers/onboarding_provider.dart';
import 'package:witchy/providers/settings_provider.dart';
import 'package:witchy/screens/fertility_screen.dart';
import 'package:witchy/services/prefs_service.dart';

void main() {
  Future<void> pumpFertility(
    WidgetTester tester, {
    CycleGoal goal = CycleGoal.track,
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
    final settings = SettingsProvider(prefs, goal: goal);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<PrefsService>.value(value: prefs),
          ChangeNotifierProvider<OnboardingProvider>.value(value: onboarding),
          ChangeNotifierProvider<LoggingProvider>.value(value: logging),
          ChangeNotifierProvider<CycleProvider>.value(value: cycle),
          ChangeNotifierProvider<SettingsProvider>.value(value: settings),
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
  });

  testWidgets('conceive goal keeps the TTC framing', (tester) async {
    await pumpFertility(tester, goal: CycleGoal.conceive);
    expect(find.text('TTC Tips'), findsOneWidget);
  });

}
