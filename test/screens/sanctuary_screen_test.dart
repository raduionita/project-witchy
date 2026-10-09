import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:witchy/models/tracking_mode.dart';
import 'package:witchy/providers/cycle_provider.dart';
import 'package:witchy/providers/logging_provider.dart';
import 'package:witchy/providers/onboarding_provider.dart';
import 'package:witchy/screens/sanctuary_screen.dart';
import 'package:witchy/services/prefs_service.dart';

void main() {
  Future<void> pumpSanctuary(WidgetTester tester, {required TrackingMode mode}) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = PrefsService();
    final onboarding = OnboardingProvider(
      prefs,
      onboarded: true,
      cycleLength: 28,
      bleedLength: 5,
      lastPeriodStart: DateTime.now().subtract(const Duration(days: 13)),
      trackingMode: mode,
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
        child: const MaterialApp(home: SanctuaryScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('perimenopause shows a bleeding window and hides the fertility card', (tester) async {
    await pumpSanctuary(tester, mode: TrackingMode.perimenopause);
    expect(find.text('BLEEDING IN'), findsOneWidget);
    expect(find.text('FERTILITY WINDOW'), findsNothing);
    // No observed history: single-day window still rendered with range sub.
    expect(find.textContaining('· range'), findsOneWidget);
    expect(find.textContaining('· predicted'), findsNothing);
  });

  testWidgets('cycle mode keeps the single-day countdown and fertility card', (tester) async {
    await pumpSanctuary(tester, mode: TrackingMode.cycle);
    expect(find.text('FERTILITY WINDOW'), findsOneWidget);
    expect(find.textContaining('· predicted'), findsWidgets);
    expect(find.textContaining('· range'), findsNothing);
  });
}
