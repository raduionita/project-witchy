import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:witchy/providers/cycle_provider.dart';
import 'package:witchy/providers/gestation_provider.dart';
import 'package:witchy/providers/logging_provider.dart';
import 'package:witchy/providers/onboarding_provider.dart';
import 'package:witchy/screens/pregnancy_screen.dart';
import 'package:witchy/services/prefs_service.dart';

void main() {
  Future<GestationProvider> provider({DateTime? lmp}) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = PrefsService();
    return GestationProvider(prefs, lmpDate: lmp);
  }

  Future<void> pumpScreen(WidgetTester tester, GestationProvider gestation, {int cycleLength = 28}) async {
    final prefs = PrefsService();
    final onboarding = OnboardingProvider(prefs, onboarded: true, cycleLength: cycleLength);
    final logging = LoggingProvider(prefs);
    final cycle = CycleProvider(onboarding, logging);
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<GestationProvider>.value(value: gestation),
          ChangeNotifierProvider<CycleProvider>.value(value: cycle),
        ],
        child: const MaterialApp(home: PregnancyScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('empty state prompts for the last period date without LMP', (tester) async {
    await pumpScreen(tester, await provider());
    expect(find.text('Your pregnancy tracker is ready'), findsOneWidget);
    expect(find.text('Set last period date'), findsOneWidget);
    expect(find.textContaining('Week'), findsNothing);
    expect(find.text('This Week'), findsNothing);
  });

  testWidgets('seeded LMP renders computed week, countdown and content', (tester) async {
    final today = DateTime.now();
    final lmp = DateTime(today.year, today.month, today.day).subtract(const Duration(days: 84));
    await pumpScreen(tester, await provider(lmp: lmp));
    expect(find.text('Week 12 (Day 0)'), findsOneWidget);
    expect(find.text('196 days until your due date'), findsOneWidget);
    expect(find.text('Apple Size'), findsOneWidget);
    expect(find.text('Pregnancy Tips'), findsOneWidget);
    expect(find.text('Set last period date'), findsNothing);
    expect(find.text('Last period'), findsOneWidget);
  });

  testWidgets('LMP row is tappable and keeps the screen alive', (tester) async {
    final today = DateTime.now();
    final lmp = DateTime(today.year, today.month, today.day).subtract(const Duration(days: 10));
    await pumpScreen(tester, await provider(lmp: lmp));
    expect(find.textContaining('Week 1 (Day 3)'), findsOneWidget);
    expect(find.textContaining('Poppy Seed'), findsOneWidget);
  });

  testWidgets('due date card shows LMP provenance without override', (tester) async {
    final today = DateTime.now();
    final lmp = DateTime(today.year, today.month, today.day).subtract(const Duration(days: 84));
    await pumpScreen(tester, await provider(lmp: lmp));
    expect(find.text('Due date: LMP'), findsOneWidget);
    expect(find.text('Set doctor due date'), findsOneWidget);
    expect(find.textContaining('Parikh estimate'), findsNothing);
  });

  testWidgets('non-28-day cycle shows the Parikh alternative', (tester) async {
    final today = DateTime.now();
    final lmp = DateTime(today.year, today.month, today.day).subtract(const Duration(days: 84));
    await pumpScreen(tester, await provider(lmp: lmp), cycleLength: 35);
    expect(find.textContaining('Parikh estimate for a 35-day cycle'), findsOneWidget);
  });

  testWidgets('doctor override switches provenance and offers LMP fallback', (tester) async {
    final today = DateTime.now();
    final day = DateTime(today.year, today.month, today.day);
    final gestation = await provider(lmp: day.subtract(const Duration(days: 84)));
    await gestation.setEddOverride(day.add(const Duration(days: 200)));
    await pumpScreen(tester, gestation);
    expect(find.text('Due date: doctor-set'), findsOneWidget);
    expect(find.text('Change doctor due date'), findsOneWidget);
    expect(find.text('Use LMP date'), findsOneWidget);
    expect(find.textContaining('Parikh estimate'), findsNothing);
  });

  testWidgets('dated tracker shows the medical disclaimer, empty state does not', (tester) async {
    await pumpScreen(tester, await provider());
    expect(find.text('Predictions are estimates - not a contraceptive and not medical advice.'), findsNothing);
    final today = DateTime.now();
    final lmp = DateTime(today.year, today.month, today.day).subtract(const Duration(days: 84));
    await pumpScreen(tester, await provider(lmp: lmp));
    // Long screen: scroll the footer into view before asserting.
    await tester.dragUntilVisible(
      find.text('Predictions are estimates - not a contraceptive and not medical advice.'),
      find.byType(Scrollable),
      const Offset(0, -300),
    );
    await tester.pumpAndSettle();
    expect(find.text('Predictions are estimates - not a contraceptive and not medical advice.'), findsOneWidget);
  });
}
