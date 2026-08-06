import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Boots the app by loading persisted data before the UI renders.
///
/// Exposes [isBootstrapped] so the router can switch from the splash screen
/// to the main shell once initialization completes. Phase 0 only initializes
/// storage; feature providers hook in during later phases.
class AppBootstrap extends ChangeNotifier {
  bool _isBootstrapped = false;

  /// Whether initialization has completed.
  bool get isBootstrapped => _isBootstrapped;

  /// Whether this is the first launch (no stored profile yet).
  bool get isFirstRun => _isFirstRun;
  bool _isFirstRun = true;

  /// Loads persisted storage and flips [isBootstrapped].
  Future<void> initialize() async {
    if (_isBootstrapped) return;

    final SharedPreferences prefs = await SharedPreferences.getInstance();

    // Phase 1 introduces real repositories; for now a first-run marker lives
    // behind a namespaced key so future phases can read it.
    _isFirstRun = !(prefs.getBool('witchy.onboarded') ?? false);

    _isBootstrapped = true;
    notifyListeners();
  }
}
