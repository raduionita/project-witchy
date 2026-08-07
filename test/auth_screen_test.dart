import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:witchy/features/auth/auth_gateway.dart';
import 'package:witchy/features/auth/auth_provider.dart';
import 'package:witchy/features/auth/auth_screen.dart';
import 'package:witchy/features/auth/auth_service.dart';
import 'package:witchy/features/auth/models/auth_session.dart';
import 'package:witchy/l10n/app_localizations.dart';
import 'package:witchy/services/storage_service.dart';

class FakeAuthGateway implements AuthGateway {
  bool configError = false;
  int calls = 0;
  int anonymousCalls = 0;

  @override
  Future<AuthSession> signInWithGoogle() async {
    calls++;
    if (configError) throw const AuthConfigException('Google Sign-In is not configured for this device yet.');
    return AuthSession(
      id: 'g1',
      displayName: 'Gina',
      email: 'gina@example.com',
      provider: AuthProviderType.google,
      signedInAt: DateTime(2026, 1, 1),
    );
  }

  @override
  Future<AuthSession> signInWithApple() async {
    calls++;
    if (configError) throw const AuthConfigException('Apple Sign-In is not configured for this device yet.');
    return AuthSession(
      id: 'a1',
      displayName: 'Ann',
      email: 'ann@example.com',
      provider: AuthProviderType.apple,
      signedInAt: DateTime(2026, 1, 1),
    );
  }

  @override
  Future<AuthSession> signInAnonymously() async {
    anonymousCalls++;
    return AuthSession(
      id: 'anon',
      displayName: 'Anonymous user',
      provider: AuthProviderType.anonymous,
      signedInAt: DateTime(2026, 1, 1),
    );
  }
}

Future<StorageService> freshStorage() async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return StorageService(prefs);
}

Future<AuthProvider> pumpAuthScreen(
  WidgetTester tester,
  FakeAuthGateway gateway,
) async {
  tester.view.physicalSize = const Size(800, 1400);
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.reset);

  final AuthProvider provider = AuthProvider(
    AuthService(storage: await freshStorage(), gateway: gateway),
  )..load();
  await tester.pumpWidget(
    ChangeNotifierProvider<AuthProvider>.value(
      value: provider,
      child: MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: const AuthScreen(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return provider;
}

void main() {
  testWidgets('shows Google and Apple options', (WidgetTester tester) async {
    await pumpAuthScreen(tester, FakeAuthGateway());

    expect(find.text('Sign in (optional)'), findsOneWidget);
    expect(find.text('Google Sign In'), findsOneWidget);
    expect(find.text('Apple Sign In'), findsOneWidget);
    expect(find.text('Anonymous'), findsOneWidget);
  });

  testWidgets('successful Google sign-in updates the provider',
      (WidgetTester tester) async {
    final FakeAuthGateway gateway = FakeAuthGateway();
    final AuthProvider provider = await pumpAuthScreen(tester, gateway);

    await tester.tap(find.text('Google Sign In'));
    await tester.pumpAndSettle();

    expect(gateway.calls, 1);
    expect(provider.isSignedIn, isTrue);
    expect(provider.session!.provider, AuthProviderType.google);
  });

  testWidgets('anonymous sign-in signs in without an external request',
      (WidgetTester tester) async {
    final FakeAuthGateway gateway = FakeAuthGateway();
    final AuthProvider provider = await pumpAuthScreen(tester, gateway);

    await tester.tap(find.text('Anonymous'));
    await tester.pumpAndSettle();

    expect(gateway.anonymousCalls, 1);
    expect(provider.isSignedIn, isTrue);
    expect(provider.session!.provider, AuthProviderType.anonymous);
  });

  testWidgets('configuration errors surface a friendly message',
      (WidgetTester tester) async {
    final FakeAuthGateway gateway = FakeAuthGateway()..configError = true;
    final AuthProvider provider = await pumpAuthScreen(tester, gateway);

    await tester.tap(find.text('Apple Sign In'));
    await tester.pumpAndSettle();

    expect(provider.isSignedIn, isFalse);
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.textContaining('not configured'), findsOneWidget);
  });
}
