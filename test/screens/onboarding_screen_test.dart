import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:witchy/models/cycle_goal.dart';
import 'package:witchy/providers/onboarding_provider.dart';
import 'package:witchy/providers/settings_provider.dart';
import 'package:witchy/screens/onboarding_screen.dart';
import 'package:witchy/services/prefs_service.dart';
import 'package:witchy/widgets/app_chip.dart';

void main() {
  late PrefsService prefs;
  late OnboardingProvider onboarding;
  late SettingsProvider settings;

  setUp(() {
    SharedPreferences.setMockInitialValues({});
    prefs = PrefsService();
    onboarding = OnboardingProvider(prefs);
    settings = SettingsProvider(prefs);
  });

  /// The chip carrying [label]; goal labels are unique on this screen.
  Finder chipFor(String label) => find.ancestor(of: find.text(label), matching: find.byType(AppChip));

  Future<void> pumpOnboarding(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<PrefsService>.value(value: prefs),
          ChangeNotifierProvider<OnboardingProvider>.value(value: onboarding),
          ChangeNotifierProvider<SettingsProvider>.value(value: settings),
        ],
        child: const MaterialApp(home: OnboardingScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('goal chips are one row of equal-width chips', (tester) async {
    await pumpOnboarding(tester);
    final chips = CycleGoal.values.map((goal) => chipFor(goal.label)).toList();
    for (final chip in chips) {
      expect(chip, findsOneWidget);
    }

    final widths = chips.map((chip) => tester.getSize(chip).width).toList();
    expect(widths[1], moreOrLessEquals(widths[0], epsilon: 0.5));

    final tops = chips.map((chip) => tester.getTopLeft(chip).dy).toList();
    expect(tops[1], moreOrLessEquals(tops[0], epsilon: 0.5));

    // A long label is clipped to one line rather than wrapped, so it cannot
    // make its chip taller than the others.
    final text = tester.widget<Text>(find.text(CycleGoal.conceive.label));
    expect(text.maxLines, 1);
    expect(text.softWrap, isFalse);
    expect(text.overflow, TextOverflow.clip);
  });

  testWidgets('tapping a goal chip records the goal', (tester) async {
    await pumpOnboarding(tester);
    expect(settings.goal, CycleGoal.track);
    await tester.tap(chipFor(CycleGoal.conceive.label));
    await tester.pumpAndSettle();
    expect(settings.goal, CycleGoal.conceive);
  });
}
