import '../../services/storage_service.dart';
import 'auth_gateway.dart';
import 'models/auth_session.dart';

/// Orchestrates sign-in providers and persists the local-only session.
///
/// Persistence uses [StorageService] (backed by `shared_preferences`): the
/// stored session holds the provider identity only — no tokens, no cloud.
class AuthService {
  AuthService({required StorageService storage, required AuthGateway gateway})
      : _storage = storage,
        _gateway = gateway;

  static const String _kSessionKey = 'auth.session';

  final StorageService _storage;
  final AuthGateway _gateway;

  /// Restores a previously persisted session, or null when signed out.
  AuthSession? load() {
    final dynamic raw = _storage.read(_kSessionKey);
    if (raw is! Map<String, dynamic>) return null;
    try {
      return AuthSession.fromJson(raw);
    } on Object {
      return null;
    }
  }

  /// Starts Google Sign-In and persists the resulting session.
  Future<AuthSession> signInWithGoogle() async {
    final AuthSession session = await _gateway.signInWithGoogle();
    await _persist(session);
    return session;
  }

  /// Starts Apple Sign-In and persists the resulting session.
  Future<AuthSession> signInWithApple() async {
    final AuthSession session = await _gateway.signInWithApple();
    await _persist(session);
    return session;
  }

  Future<void> _persist(AuthSession session) =>
      _storage.write(_kSessionKey, session.toJson());

  /// Clears the persisted session.
  Future<void> signOut() => _storage.remove(_kSessionKey);
}
