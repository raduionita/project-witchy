import 'package:flutter/foundation.dart';

import '../../services/storage_service.dart';

/// Reactive facade over the privacy-related settings.
///
/// Today this is the anonymous-mode flag, persisted through [StorageService]
/// (`shared_preferences`). When enabled the app avoids persisting any
/// identifying information (name/email) — see the Settings hub, which clears
/// the stored session on enable.
class PrivacyProvider extends ChangeNotifier {
  PrivacyProvider(this._storage);

  static const String _kAnonymousModeKey = 'privacy.anonymousMode';

  final StorageService _storage;

  bool _anonymousMode = false;

  /// Whether anonymous mode is active.
  bool get anonymousMode => _anonymousMode;

  /// Restores the persisted anonymous-mode flag.
  void load() {
    _anonymousMode = _storage.getBool(_kAnonymousModeKey, fallback: false);
    notifyListeners();
  }

  /// Enables/disables anonymous mode and persists it.
  Future<void> setAnonymousMode(bool enabled) async {
    if (enabled == _anonymousMode) return;
    _anonymousMode = enabled;
    notifyListeners();
    await _storage.setBool(_kAnonymousModeKey, enabled);
  }
}
