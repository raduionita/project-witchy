import 'package:flutter/material.dart';

import '../../l10n/app_localizations.dart';
import '../../services/storage_service.dart';

/// Theme appearance options shown in Settings.
enum AppThemeOption {
  light,
}

/// Presentation helpers for [AppThemeOption].
extension AppThemeOptionX on AppThemeOption {
  /// Human label shown in the Settings picker.
  String label(AppLocalizations l10n) => switch (this) {
        AppThemeOption.light => l10n.themeDefaultLight,
      };

  /// The [ThemeMode] that materializes this option.
  ThemeMode get themeMode => switch (this) {
        AppThemeOption.light => ThemeMode.light,
      };

  /// Stable value persisted under the appearance key.
  String get storageKey => switch (this) {
        AppThemeOption.light => 'light',
      };
}

/// Reactive facade over the persisted theme option.
///
/// Persistence uses [StorageService] (`shared_preferences`): the selection
/// survives restarts and is read once at boot via [load].
class ThemeProvider extends ChangeNotifier {
  ThemeProvider(this._storage);

  static const String _kThemeKey = 'appearance.theme';

  final StorageService _storage;

  AppThemeOption _option = AppThemeOption.light;

  /// Currently selected appearance option.
  AppThemeOption get option => _option;

  /// Material [ThemeMode] derived from [option].
  ThemeMode get themeMode => _option.themeMode;

  /// Restores the persisted option, defaulting to [AppThemeOption.light].
  void load() {
    final dynamic raw = _storage.read(_kThemeKey);
    if (raw is String) {
      for (final AppThemeOption candidate in AppThemeOption.values) {
        if (candidate.storageKey == raw) {
          _option = candidate;
          break;
        }
      }
    }
    notifyListeners();
  }

  /// Selects [option] and persists it.
  Future<void> setOption(AppThemeOption option) async {
    if (option == _option) return;
    _option = option;
    notifyListeners();
    await _storage.write(_kThemeKey, option.storageKey);
  }
}
