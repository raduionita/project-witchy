import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:witchy/features/auth/auth_gateway.dart';
import 'package:witchy/features/auth/auth_provider.dart';
import 'package:witchy/features/auth/auth_service.dart';
import 'package:witchy/features/auth/models/auth_session.dart';
import 'package:witchy/features/onboarding/onboarding_screen.dart';
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

Future<AuthProvider> pumpOnboarding(WidgetTester tester) async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  final AuthProvider auth = AuthProvider(
    AuthService(storage: StorageService(prefs), gateway: FakeAuthGateway()),
  )..load();
  await tester.pumpWidget(
    ChangeNotifierProvider<AuthProvider>.value(
      value: auth,
      child: const MaterialApp(home: OnboardingScreen()),
    ),
  );
  await tester.pumpAndSettle();
  return auth;
}

void main() {
  testWidgets('onboarding ends with an optional account step',
      (WidgetTester tester) async {
    await pumpOnboarding(tester);

    expect(find.text('Create an account (optional)'), findsNothing);

    for (int i = 0; i < 4; i++) {
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
    }

    expect(find.text('Create an account (optional)'), findsOneWidget);
    expect(find.text('Continue with Google'), findsOneWidget);
    expect(find.text('Continue with Apple'), findsOneWidget);
    expect(find.text('Skip for now'), findsOneWidget);
  });

  testWidgets('signing in on the account step records the session',
      (WidgetTester tester) async {
    final AuthProvider auth = await pumpOnboarding(tester);

    for (int i = 0; i < 4; i++) {
      await tester.tap(find.text('Next'));
      await tester.pumpAndSettle();
    }

    await tester.tap(find.text('Continue with Google'));
    await tester.pumpAndSettle();

    expect(auth.isSignedIn, isTrue);
    expect(auth.session!.provider, AuthProviderType.google);
  });
}
