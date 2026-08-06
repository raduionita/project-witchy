import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../providers/app_state_provider.dart';
import '../services/storage_service.dart';

/// Boots the app by loading persisted data before the UI renders.
///
/// Exposes [isBootstrapped] so the router can switch from the splash screen
/// to the main shell once initialization completes, and [state] which provides
/// every repository to the widget tree.
class AppBootstrap extends ChangeNotifier {
  bool _isBootstrapped = false;

  /// Whether initialization has completed.
  bool get isBootstrapped => _isBootstrapped;

  /// Whether this is the first launch (no stored profile yet).
  bool get isFirstRun => _isFirstRun;
  bool _isFirstRun = true;

  /// The app-wide data facade, available once bootstrapped.
  AppStateProvider? _state;

  AppStateProvider? get state => _state;

  /// Loads persisted storage and flips [isBootstrapped].
  Future<void> initialize() async {
    if (_isBootstrapped) return;

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final StorageService storage = StorageService(prefs);

    final AppStateProvider appState = AppStateProvider(storage);
    appState.load();
    _state = appState;

    _isFirstRun = appState.profile.profile == null;
    _isBootstrapped = true;
    notifyListeners();
  }
}