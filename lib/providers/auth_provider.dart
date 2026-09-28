import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import '../models/auth_identity.dart';
import '../services/prefs_service.dart';

class AuthProvider extends ChangeNotifier {
  AuthProvider(this._prefs, {this.signedIn = false, this.identity});

  final PrefsService _prefs;
  static Future<void>? _googleInit;
  bool signedIn;
  bool busy = false;
  AuthIdentity? identity;
  String? lastError;

  static Future<AuthProvider> load(PrefsService prefs) async {
    final session = await prefs.session();
    if (session == null) return AuthProvider(prefs);
    return AuthProvider(prefs, signedIn: true, identity: AuthIdentity.fromMap(session));
  }

  Future<void> signInWithEmail(String email) async {
    final trimmed = email.trim();
    return _authenticate(() async {
      if (!trimmed.contains('@') || !trimmed.contains('.')) throw Exception('Enter a valid email to join the coven');
      return {'method': 'email', 'email': trimmed, 'name': trimmed.split('@').first};
    });
  }

  Future<void> signInWithGoogle() async => _authenticate(() async {
    final instance = GoogleSignIn.instance;
    _googleInit ??= instance.initialize();
    await _googleInit;
    final account = await instance.authenticate();
    return {
      'method': 'google',
      if (account.email.isNotEmpty) 'email': account.email,
      if (account.displayName != null && account.displayName!.isNotEmpty) 'name': account.displayName!,
    };
  });

  Future<void> signInWithApple() async => _authenticate(() async {
    if (!await SignInWithApple.isAvailable()) throw Exception('Apple Sign-In is unavailable on this device');
    final credential = await SignInWithApple.getAppleIDCredential(
      scopes: const [AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
    );
    final name = [credential.givenName, credential.familyName].whereType<String>().join(' ').trim();
    return {
      'method': 'apple',
      if (credential.email != null && credential.email!.isNotEmpty) 'email': credential.email!,
      if (name.isNotEmpty) 'name': name,
    };
  });

  Future<void> signOut() async {
    if (identity?.method == 'google') {
      try {
        await GoogleSignIn.instance.signOut();
      } catch (_) {}
    }
    await _prefs.clearSession();
    signedIn = false;
    identity = null;
    lastError = null;
    notifyListeners();
  }

  Future<void> _authenticate(Future<Map<String, String>?> Function() task) async {
    busy = true;
    lastError = null;
    notifyListeners();
    try {
      final session = await task();
      if (session != null) {
        await _prefs.saveSession(session);
        identity = AuthIdentity.fromMap(session);
        signedIn = true;
      }
    } on GoogleSignInException catch (e) {
      if (e.code != GoogleSignInExceptionCode.canceled) lastError = e.description ?? 'Google sign-in failed (${e.code.name})';
    } on SignInWithAppleAuthorizationException catch (e) {
      if (e.code != AuthorizationErrorCode.canceled) lastError = e.message;
    } catch (e) {
      lastError = _friendlyMessage(e);
    } finally {
      busy = false;
      notifyListeners();
    }
  }

  String _friendlyMessage(Object error) {
    final text = error.toString();
    final separator = text.indexOf(': ');
    return separator == -1 ? text : text.substring(separator + 2);
  }
}
