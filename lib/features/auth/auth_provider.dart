import 'package:flutter/foundation.dart';

import 'auth_gateway.dart';
import 'auth_service.dart';
import 'models/auth_session.dart';

/// Reactive facade over [AuthService].
///
/// Exposes the current [AuthSession] to the widget tree and translates
/// platform errors into a user-facing [errorMessage] (cancellations are
/// swallowed silently).
class AuthProvider extends ChangeNotifier {
  AuthProvider(this._service);

  final AuthService _service;

  AuthSession? _session;
  bool _busy = false;
  String? _errorMessage;

  /// Current session, or null when signed out.
  AuthSession? get session => _session;

  /// Whether the user has a signed-in session.
  bool get isSignedIn => _session != null;

  /// Whether a sign-in/out operation is in flight.
  bool get busy => _busy;

  /// Last user-facing error, cleared on the next successful operation.
  String? get errorMessage => _errorMessage;

  /// Restores a persisted session, if any.
  void load() {
    _session = _service.load();
    notifyListeners();
  }

  Future<bool> signInWithGoogle() => _signIn(_service.signInWithGoogle);

  Future<bool> signInWithApple() => _signIn(_service.signInWithApple);

  Future<bool> _signIn(Future<AuthSession> Function() action) async {
    if (_busy) return false;
    _busy = true;
    _errorMessage = null;
    notifyListeners();
    try {
      _session = await action();
      return true;
    } on AuthCancelledException {
      return false;
    } on Object catch (error) {
      _errorMessage = error.toString();
      return false;
    } finally {
      _busy = false;
      notifyListeners();
    }
  }

  /// Signs out and clears the persisted session.
  Future<void> signOut() async {
    if (_busy) return;
    _busy = true;
    notifyListeners();
    try {
      await _service.signOut();
    } finally {
      _session = null;
      _errorMessage = null;
      _busy = false;
      notifyListeners();
    }
  }
}
