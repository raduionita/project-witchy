import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Typed, namespaced read/write layer over [SharedPreferences].
///
/// All keys are prefixed with `witchy.` per persistence convention and to keep
/// the persisted store tidy. Values are stored as JSON strings for structured
/// data and raw primitives for simple flags.
class StorageService {
  StorageService(this._prefs);

  final SharedPreferences _prefs;

  static const String _kPrefix = 'witchy.';

  String _key(String name) => '$_kPrefix$name';

  /// Reads a single stored JSON value; returns null when absent or corrupt.
  dynamic read(String name) {
    final String? raw = _prefs.getString(_key(name));
    if (raw == null) return null;
    try {
      return jsonDecode(raw);
    } on FormatException {
      return null;
    }
  }

  /// Writes a single value by JSON-encoding it.
  Future<bool> write(String name, Object? value) {
    if (value == null) return remove(name);
    return _prefs.setString(_key(name), jsonEncode(value));
  }

  /// Reads a List of JSON values stored under [name].
  List<dynamic> readList(String name) {
    final String? raw = _prefs.getString(_key(name));
    if (raw == null) return const [];
    try {
      final Object? decoded = jsonDecode(raw);
      return decoded is List ? decoded : const [];
    } on FormatException {
      return const [];
    }
  }

  /// Writes a list of JSON values under [name].
  Future<bool> writeList(String name, List<dynamic> value) =>
      _prefs.setString(_key(name), jsonEncode(value));

  /// Simple boolean flag (used for onboarding/anonymous-mode markers).
  Future<bool> setBool(String name, bool value) =>
      _prefs.setBool(_key(name), value);

  /// Simple boolean flag read; defaults to [fallback].
  bool getBool(String name, {bool fallback = false}) =>
      _prefs.getBool(_key(name)) ?? fallback;

  /// Removes a single key.
  Future<bool> remove(String name) => _prefs.remove(_key(name));

  /// Clears all Witchy-prefixed keys.
  Future<void> clearAll() async {
    final Set<String> keys = _prefs
        .getKeys()
        .where((String key) => key.startsWith(_kPrefix))
        .toSet();
    for (final String key in keys) {
      await _prefs.remove(key);
    }
  }
}