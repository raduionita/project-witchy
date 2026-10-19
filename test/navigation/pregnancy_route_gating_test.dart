import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:witchy/models/tracking_mode.dart';
import 'package:witchy/navigation/app_router_delegate.dart';
import 'package:witchy/providers/auth_provider.dart';
import 'package:witchy/providers/cycle_provider.dart';
import 'package:witchy/providers/gestation_provider.dart';
import 'package:witchy/providers/logging_provider.dart';
import 'package:witchy/providers/onboarding_provider.dart';
import 'package:witchy/screens/pregnancy_screen.dart';
import 'package:witchy/screens/welcome_screen.dart';
import 'package:witchy/services/prefs_service.dart';

void main() {
  Future<void> pumpAtPregnancyRoute(
    WidgetTester tester, {
    required bool onboarded,
    required Set<TrackingMode> modes,
  }) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = PrefsService();
    final onboarding = OnboardingProvider(prefs, onboarded: onboarded, trackingModes: modes);
    final logging = LoggingProvider(prefs);
    final delegate = AppRouterDelegate()..reset('/pregnancy');
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          Provider<PrefsService>.value(value: prefs),
          ChangeNotifierProvider<AuthProvider>.value(value: AuthProvider(prefs)),
          ChangeNotifierProvider<OnboardingProvider>.value(value: onboarding),
          ChangeNotifierProvider<LoggingProvider>.value(value: logging),
          ChangeNotifierProvider<CycleProvider>.value(value: CycleProvider(onboarding, logging)),
          ChangeNotifierProvider<GestationProvider>.value(value: GestationProvider(prefs)),
        ],
        // Render the delegate's pages directly - MaterialApp.router would
        // overwrite the stack with the platform's initial '/'.
        child: Builder(builder: (context) => MaterialApp(home: delegate.build(context))),
      ),
    );
    await tester.pumpAndSettle();
  }

  group('pregnancy route gating', () {
    testWidgets('renders the tracker when onboarded with pregnancy mode', (tester) async {
      await pumpAtPregnancyRoute(tester, onboarded: true, modes: {TrackingMode.pregnancy});
      expect(find.byType(PregnancyScreen), findsOneWidget);
      expect(find.byType(WelcomeScreen), findsNothing);
    });

    testWidgets('falls back to welcome when pregnancy mode is off', (tester) async {
      await pumpAtPregnancyRoute(tester, onboarded: true, modes: {TrackingMode.cycle});
      expect(find.byType(WelcomeScreen), findsOneWidget);
      expect(find.byType(PregnancyScreen), findsNothing);
    });

    testWidgets('falls back to welcome before onboarding is finished', (tester) async {
      await pumpAtPregnancyRoute(tester, onboarded: false, modes: {TrackingMode.pregnancy});
      expect(find.byType(WelcomeScreen), findsOneWidget);
      expect(find.byType(PregnancyScreen), findsNothing);
    });
  });
}
