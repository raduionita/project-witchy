import 'package:flutter/foundation.dart';

import '../models/alert_item.dart';
import '../services/alert_generator.dart';
import '../services/prefs_service.dart';
import 'cycle_provider.dart';
import 'logging_provider.dart';

/// Persisted alert inbox. Regenerates candidates from cycle + logging state,
/// merges them by stable id (keeping read state), and prunes expired entries.
class AlertProvider extends ChangeNotifier {
  AlertProvider(this._prefs, {List<AlertItem>? items}) : _items = [...?items];

  final PrefsService _prefs;
  final List<AlertItem> _items;
  CycleProvider? _cycle;
  LoggingProvider? _logging;

  static const int _maxItems = 30;

  static Future<AlertProvider> load(PrefsService prefs) async =>
      AlertProvider(prefs, items: await prefs.alertItems());

  /// Watch cycle data for regeneration and produce the first batch now.
  void bind(CycleProvider cycle, LoggingProvider logging) {
    if (_cycle != null) return;
    _cycle = cycle;
    _logging = logging;
    cycle.addListener(generate);
    generate();
  }

  List<AlertItem> get items => List.unmodifiable(_items);

  int get unreadCount => _items.where((a) => !a.read).length;

  void generate({DateTime? now}) {
    final cycle = _cycle;
    final logging = _logging;
    if (cycle == null || logging == null) return;
    final t = now ?? DateTime.now();
    final today = DateTime(t.year, t.month, t.day);

    final merged = <AlertItem>[..._items];
    for (final fresh in AlertGenerator.generate(cycle: cycle, logging: logging, now: t)) {
      if (!merged.any((a) => a.id == fresh.id)) merged.add(fresh);
    }
    merged.removeWhere((a) => a.eventDate.isBefore(today));
    merged.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final capped = merged.length > _maxItems ? merged.sublist(0, _maxItems) : merged;

    final before = [for (final a in _items) a.id];
    final after = [for (final a in capped) a.id];
    if (!listEquals(before, after)) {
      _items..clear()..addAll(capped);
      notifyListeners();
      _save();
    }
  }

  void markRead(String id) {
    final i = _items.indexWhere((a) => a.id == id);
    if (i < 0 || _items[i].read) return;
    _items[i] = _items[i].copyWith(read: true);
    notifyListeners();
    _save();
  }

  void markAllRead() {
    var changed = false;
    for (var i = 0; i < _items.length; i++) {
      if (_items[i].read) continue;
      _items[i] = _items[i].copyWith(read: true);
      changed = true;
    }
    if (changed) {
      notifyListeners();
      _save();
    }
  }

  void _save() => _prefs.saveAlertItems(_items);

  /// In-memory reset after Delete All Data (prefs already wiped).
  /// Called last so cycle-triggered regeneration runs before this clears.
  void resetToDefaults() {
    _items.clear();
    notifyListeners();
  }
}
