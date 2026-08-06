import 'dart:ui';

import 'package:flutter/foundation.dart';

import '../../services/storage_service.dart';

/// Language options shown in Settings.
enum AppLocaleOption {
  system(code: null),
  english(code: 'en'),
  spanish(code: 'es');

  const AppLocaleOption({required this.code});

  /// BCP-47 code for this option, or null for "follow the device".
  final String? code;

  /// Whether this option defers to the device locale.
  bool get isSystem => code == null;

  /// The [Locale] to hand MaterialApp, or null to follow the device.
  Locale? get locale => code == null ? null : Locale(code!);

  /// Stable value persisted under the appearance key.
  String get storageKey => code ?? 'system';
}

/// Reactive facade over the persisted language choice.
///
/// Persistence uses [StorageService] (`shared_preferences`). The default is
/// [AppLocaleOption.system], which defers to the device locale — MaterialApp
/// falls back to the first supported locale (English) when the device language
/// is not available.
class LocaleProvider extends ChangeNotifier {
  LocaleProvider(this._storage);

  static const String _kLocaleKey = 'appearance.locale';

  final StorageService _storage;

  AppLocaleOption _option = AppLocaleOption.system;

  /// Currently selected language option.
  AppLocaleOption get option => _option;

  /// The resolved [Locale] for MaterialApp (null follows the device).
  Locale? get locale => _option.locale;

  /// Restores the persisted option, defaulting to the system locale.
  void load() {
    final dynamic raw = _storage.read(_kLocaleKey);
    if (raw is String) {
      for (final AppLocaleOption candidate in AppLocaleOption.values) {
        if (candidate.storageKey == raw) {
          _option = candidate;
          break;
        }
      }
    }
    notifyListeners();
  }

  /// Selects [option] and persists it.
  Future<void> setOption(AppLocaleOption option) async {
    if (option == _option) return;
    _option = option;
    notifyListeners();
    await _storage.write(_kLocaleKey, option.storageKey);
  }
}
