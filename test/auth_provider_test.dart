import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:witchy/features/auth/auth_gateway.dart';
import 'package:witchy/features/auth/auth_provider.dart';
import 'package:witchy/features/auth/auth_service.dart';
import 'package:witchy/features/auth/models/auth_session.dart';
import 'package:witchy/services/storage_service.dart';

class FakeAuthGateway implements AuthGateway {
  bool cancelNext = false;
  bool configErrorNext = false;
  int googleCalls = 0;
  int appleCalls = 0;

  static final AuthSession _googleSession = AuthSession(
    id: 'g1',
    displayName: 'Gina',
    email: 'gina@example.com',
    provider: AuthProviderType.google,
    signedInAt: DateTime(2026, 1, 1),
  );

  static final AuthSession _appleSession = AuthSession(
    id: 'a1',
    displayName: 'Ann',
    email: 'ann@example.com',
    provider: AuthProviderType.apple,
    signedInAt: DateTime(2026, 1, 2),
  );

  @override
  Future<AuthSession> signInWithGoogle() async {
    googleCalls++;
    if (cancelNext) throw const AuthCancelledException();
    if (configErrorNext) throw const AuthConfigException('not configured');
    return _googleSession;
  }

  @override
  Future<AuthSession> signInWithApple() async {
    appleCalls++;
    if (cancelNext) throw const AuthCancelledException();
    if (configErrorNext) throw const AuthConfigException('not configured');
    return _appleSession;
  }
}

Future<StorageService> freshStorage() async {
  SharedPreferences.setMockInitialValues(<String, Object>{});
  final SharedPreferences prefs = await SharedPreferences.getInstance();
  return StorageService(prefs);
}

void main() {
  late StorageService storage;
  late FakeAuthGateway gateway;
  late AuthProvider provider;

  setUp(() async {
    storage = await freshStorage();
    gateway = FakeAuthGateway();
    provider = AuthProvider(
      AuthService(storage: storage, gateway: gateway),
    )..load();
  });

  test('starts signed out', () {
    expect(provider.isSignedIn, isFalse);
    expect(provider.session, isNull);
    expect(provider.errorMessage, isNull);
  });

  test('Google sign-in persists the session and notifies', () async {
    var notified = 0;
    provider.addListener(() => notified++);

    final bool ok = await provider.signInWithGoogle();

    expect(ok, isTrue);
    expect(provider.isSignedIn, isTrue);
    expect(provider.session!.provider, AuthProviderType.google);
    expect(provider.session!.displayName, 'Gina');
    expect(notified, greaterThan(0));

    // Persisted: a fresh provider over the same storage restores it.
    final AuthProvider reloaded = AuthProvider(
      AuthService(storage: storage, gateway: FakeAuthGateway()),
    )..load();
    expect(reloaded.isSignedIn, isTrue);
    expect(reloaded.session!.id, 'g1');
  });

  test('Apple sign-in persists the session', () async {
    final bool ok = await provider.signInWithApple();
    expect(ok, isTrue);
    expect(provider.session!.provider, AuthProviderType.apple);
    expect(provider.session!.email, 'ann@example.com');
  });

  test('cancellation is silent and leaves the user signed out', () async {
    gateway.cancelNext = true;
    final bool ok = await provider.signInWithGoogle();
    expect(ok, isFalse);
    expect(provider.isSignedIn, isFalse);
    expect(provider.errorMessage, isNull);
  });

  test('config errors surface a message but keep the user signed out',
      () async {
    gateway.configErrorNext = true;
    final bool ok = await provider.signInWithApple();
    expect(ok, isFalse);
    expect(provider.isSignedIn, isFalse);
    expect(provider.errorMessage, contains('not configured'));
  });

  test('signOut clears the session and persisted storage', () async {
    await provider.signInWithGoogle();
    expect(provider.isSignedIn, isTrue);

    await provider.signOut();
    expect(provider.isSignedIn, isFalse);
    expect(provider.errorMessage, isNull);

    final AuthProvider reloaded = AuthProvider(
      AuthService(storage: storage, gateway: FakeAuthGateway()),
    )..load();
    expect(reloaded.isSignedIn, isFalse);
  });
}
