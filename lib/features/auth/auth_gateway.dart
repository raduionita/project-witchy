import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'models/auth_session.dart';

/// Thrown when the user cancels a sign-in flow.
class AuthCancelledException implements Exception {
  const AuthCancelledException();
}

/// Thrown when platform sign-in is not configured (missing OAuth client).
class AuthConfigException implements Exception {
  const AuthConfigException(this.message);

  final String message;

  @override
  String toString() => message;
}

/// Boundary between auth logic and the platform sign-in plugins.
///
/// Implementations return a local-only [AuthSession]; nothing leaves the
/// device. This interface exists so the rest of the app can be tested without
/// the native plugins.
abstract interface class AuthGateway {
  /// Starts the Google Sign-In flow. Throws [AuthCancelledException] when the
  /// user cancels and [AuthConfigException] when unconfigured.
  Future<AuthSession> signInWithGoogle();

  /// Starts the Sign in with Apple flow.
  Future<AuthSession> signInWithApple();
}

/// Real gateway backed by `google_sign_in` and `sign_in_with_apple`.
///
/// Note: on Android, Google Sign-In requires a `google-services.json`
/// (Google Cloud Console) and Apple Sign-In uses the non-native web fallback
/// provided by the plugin. Until those are configured the flows surface a
/// friendly [AuthConfigException] instead of crashing.
class NativeAuthGateway implements AuthGateway {
  Future<void>? _googleInit;

  Future<void> _ensureGoogleReady() => _googleInit ??= () async {
        await GoogleSignIn.instance.initialize();
      }();

  @override
  Future<AuthSession> signInWithGoogle() async {
    try {
      await _ensureGoogleReady();
      final GoogleSignInAccount account =
          await GoogleSignIn.instance.authenticate();
      return AuthSession(
        id: account.id,
        displayName: account.displayName ?? 'Google user',
        email: account.email,
        provider: AuthProviderType.google,
        signedInAt: DateTime.now(),
      );
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled ||
          error.code == GoogleSignInExceptionCode.interrupted) {
        throw const AuthCancelledException();
      }
      throw AuthConfigException(
        'Google Sign-In is not configured for this device yet.',
      );
    }
  }

  @override
  Future<AuthSession> signInWithApple() async {
    if (!kIsWeb && !await SignInWithApple.isAvailable()) {
      throw const AuthConfigException(
        'Sign in with Apple is not available on this device.',
      );
    }
    final AuthorizationCredentialAppleID credential;
    try {
      credential = await SignInWithApple.getAppleIDCredential(
        scopes: <AppleIDAuthorizationScopes>[
          AppleIDAuthorizationScopes.fullName,
          AppleIDAuthorizationScopes.email,
        ],
      );
    } on Object {
      throw const AuthConfigException(
        'Apple Sign-In is not configured for this device yet.',
      );
    }
    final String id = credential.userIdentifier ??
        credential.identityToken ??
        credential.authorizationCode;
    if (id.isEmpty) throw const AuthCancelledException();
    return AuthSession(
      id: id,
      displayName: [
        credential.givenName,
        credential.familyName,
      ].whereType<String>().join(' ').trim(),
      email: credential.email,
      provider: AuthProviderType.apple,
      signedInAt: DateTime.now(),
    );
  }
}
