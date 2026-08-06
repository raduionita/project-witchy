import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:witchy/features/auth/auth_gateway.dart';
import 'package:witchy/features/auth/auth_provider.dart';
import 'package:witchy/features/auth/auth_service.dart';
import 'package:witchy/features/auth/models/auth_session.dart';
import 'package:witchy/features/onboarding/onboarding_screen.dart';
import 'package:witchy/providers/app_state_provider.dart';
import 'package:witchy/providers/cycle_provider.dart';
import 'package:witchy/services/storage_service.dart';

class FakeAuthGateway implements AuthGateway {
  @override
  Future<AuthSession> signInWithGoogle() async => AuthSession(
        id: 'g1',
        displayName: 'Gina',
        provider: AuthProviderType.google,
        signedInAt: DateTime(2026, 1, 1),
      );

  @override
  Future<AuthSession> signInWithApple() async => AuthSession(
        id: 'a1',
        displayName: 'Ann',
        provider: AuthProviderType.apple,
        signedInAt: DateTime(2026, 1, 1),
      );
}

void main() {
  Future<void> pumpOnboarding(WidgetTester tester) async {
    tester.view.physicalSize = const Size(800, 1600);
    tester.view.devicePixelRatio = 1.0;
    addTearDown(tester.view.reset);

    SharedPreferences.setMockInitialValues(<String, Object>{});
    final StorageService storage =
        StorageService(await SharedPreferences.getInstance());
    final AppStateProvider state = AppStateProvider(storage)..load();
    final CycleProvider cycle = CycleProvider(state)..recompute();
    final AuthProvider auth = AuthProvider(
      AuthService(storage: storage, gateway: FakeAuthGateway()),
    )..load();

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AppStateProvider>.value(value: state),
          ChangeNotifierProvider<CycleProvider>.value(value: cycle),
          ChangeNotifierProvider<AuthProvider>.value(value: auth),
        ],
        child: const MaterialApp(home: OnboardingScreen()),
      ),
    );
    await tester.pumpAndSettle();
  }

  testWidgets('the cycle length slider updates the displayed value',
      (WidgetTester tester) async {
    await pumpOnboarding(tester);

    // Step past welcome and last-period steps to the cycle length step.
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('28 days'), findsOneWidget);
    final Slider before =
        tester.widget<Slider>(find.byType(Slider));
    expect(before.value, 28);

    await tester.drag(find.byType(Slider), const Offset(300, 0));
    await tester.pumpAndSettle();

    final Slider after = tester.widget<Slider>(find.byType(Slider));
    expect(after.value, greaterThan(28));
    expect(find.text('${after.value.round()} days'), findsOneWidget);
  });

  testWidgets('the period length slider updates the displayed value',
      (WidgetTester tester) async {
    await pumpOnboarding(tester);

    for (int i = 0; i < 3; i++) {
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
    }

    expect(find.text('5 days'), findsOneWidget);
    await tester.drag(find.byType(Slider), const Offset(-300, 0));
    await tester.pumpAndSettle();

    final Slider after = tester.widget<Slider>(find.byType(Slider));
    expect(after.value, lessThan(5));
    expect(find.text('${after.value.round()} days'), findsOneWidget);
  });

  testWidgets('the last period date picker updates the shown date',
      (WidgetTester tester) async {
    await pumpOnboarding(tester);

    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    expect(find.text('Last period start'), findsOneWidget);
    await tester.tap(find.text('Last period start'));
    await tester.pumpAndSettle();

    // Pick the 1st of the current month, then confirm.
    await tester.tap(find.text('1'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    final DateTime now = DateTime.now();
    expect(
      find.text(DateFormat.yMMMd().format(DateTime(now.year, now.month, 1))),
      findsOneWidget,
    );
  });
}