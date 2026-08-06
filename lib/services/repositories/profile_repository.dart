import '../../models/user_profile.dart';
import '../storage_service.dart';

/// Persists the current [UserProfile].
class ProfileRepository {
  ProfileRepository(this._storage);

  final StorageService _storage;

  static const String _kProfileKey = 'profile';

  UserProfile? _cached;

  /// Currently stored profile, or null when the user has not onboarded.
  UserProfile? get profile => _cached;

  /// Loads the profile into memory. Returns null on first launch.
  UserProfile? load() {
    if (_cached != null) return _cached;

    final dynamic raw = _storage.read(_kProfileKey);
    if (raw is Map<String, dynamic>) {
      try {
        _cached = UserProfile.fromJson(raw);
      } on Object {
        _cached = null;
      }
    }
    return _cached;
  }

  /// Persists [profile] and updates the in-memory cache.
  Future<void> save(UserProfile profile) async {
    _cached = profile;
    await _storage.write(_kProfileKey, profile.toJson());
  }

  /// Removes the stored profile and clears the cache.
  Future<void> clear() async {
    _cached = null;
    await _storage.remove(_kProfileKey);
  }
}