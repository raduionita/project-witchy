import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:witchy/app/app_bootstrap.dart';
import 'package:witchy/app.dart';
import 'package:witchy/features/onboarding/onboarding_screen.dart';
import 'package:witchy/screens/main_shell.dart';

void main() {
  testWidgets('first launch routes to onboarding', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final AppBootstrap bootstrap = AppBootstrap();
    await bootstrap.initialize();

    await tester.pumpWidget(WitchyApp(bootstrap: bootstrap));
    await tester.pumpAndSettle();

    expect(find.byType(OnboardingScreen), findsOneWidget);
    expect(find.byType(MainShellScreen), findsNothing);
  });

  testWidgets('onboarded launch routes to the main shell', (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues(<String, Object>{
      'witchy.profile': jsonEncode(<String, Object>{
        'id': 'p1',
        'averageCycleLength': 28,
        'averagePeriodLength': 5,
        'lutealPhaseLength': 14,
        'onboarded': true,
      }),
    });
    final AppBootstrap bootstrap = AppBootstrap();
    await bootstrap.initialize();

    await tester.pumpWidget(WitchyApp(bootstrap: bootstrap));
    await tester.pumpAndSettle();

    expect(find.byType(MainShellScreen), findsOneWidget);
    expect(find.byType(OnboardingScreen), findsNothing);
  });

  test('bootstrap flags first run when no profile is stored', () async {
    SharedPreferences.setMockInitialValues(<String, Object>{});
    final AppBootstrap bootstrap = AppBootstrap();
    await bootstrap.initialize();
    expect(bootstrap.isBootstrapped, isTrue);
    expect(bootstrap.isFirstRun, isTrue);
  });
}