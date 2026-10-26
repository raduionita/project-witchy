import 'package:flutter/foundation.dart';

import '../models/alert_item.dart';
import '../models/alert_type.dart';
import '../services/alert_generator.dart';
import '../services/prefs_service.dart';
import 'cycle_provider.dart';
import 'logging_provider.dart';

/// Persisted alert inbox. Regenerates candidates from cycle + logging state,
/// merges them by stable id (keeping read state), and prunes expired entries.
class AlertProvider extends ChangeNotifier {
  AlertProvider(this._prefs, {List<AlertItem>? items, Set<String>? dismissedIds})
      : _items = [
          for (final item in items ?? const <AlertItem>[])
            if (!(dismissedIds?.contains(item.id) ?? false)) item,
        ],
        _dismissedIds = {...?dismissedIds};

  final PrefsService _prefs;
  final List<AlertItem> _items;
  final Set<String> _dismissedIds;
  CycleProvider? _cycle;
  LoggingProvider? _logging;

  static const int _maxItems = 30;
  static const int _maxDismissed = 200;

  /// Generated alerts that describe the current cycle state. If the underlying
  /// state changes (logging today, a moved ovulation peak, a new phase), the
  /// previous version must be dropped instead of lingering beside the new one.
  static const List<String> _livePrefixes = ['late-d', 'period-d', 'fertile-', 'log-'];

  static bool _isLiveId(String id) => _livePrefixes.any(id.startsWith);

  static Future<AlertProvider> load(PrefsService prefs) async {
    final items = await prefs.alertItems();
    final dismissed = await prefs.dismissedAlertIds();
    return AlertProvider(prefs, items: items, dismissedIds: dismissed.toSet());
  }

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

    final fresh = AlertGenerator.generate(
      cycle: cycle,
      logging: logging,
      now: t,
    ).where((a) => !_dismissedIds.contains(a.id)).toList();
    final freshIds = {for (final alert in fresh) alert.id};
    final merged = <AlertItem>[..._items];
    // Live alerts are regenerated from current state. Remove an old one when
    // the state no longer produces it (e.g. Log Missing after a log, or a
    // fertility alert after the peak moves into the luteal phase).
    merged.removeWhere((a) => _isLiveId(a.id) && !freshIds.contains(a.id));
    for (final alert in fresh) {
      if (!merged.any((a) => a.id == alert.id)) merged.add(alert);
    }
    // One-shots live here (not in the pure generator): they fire once per
    // stable id and are never re-emitted under a different id.
    final entry = logging.peekDay(today);
    if (entry?.ovulationTest == 'positive' &&
        cycle.showFertilityPredictions &&
        cycle.predictionsConfident(today: t) &&
        !merged.any((a) => a.id == 'opk-positive-${LoggingProvider.keyFor(today)}')) {
      merged.add(
        AlertItem(
          id: 'opk-positive-${LoggingProvider.keyFor(today)}',
          type: AlertType.fertileWindow,
          title: 'Positive Ovulation Test',
          body: 'Ovulation is likely tomorrow. Timing is most favorable now.',
          createdAt: t,
          eventDate: today,
        ),
      );
    }
    if (entry != null &&
        entry.flow.isNotEmpty &&
        !cycle.pregnancyActive &&
        !merged.any((a) => a.id == 'period-today-${LoggingProvider.keyFor(today)}')) {
      merged.add(
        AlertItem(
          id: 'period-today-${LoggingProvider.keyFor(today)}',
          type: AlertType.periodPredicted,
          title: 'Period Started',
          body: 'Period started today - log it to refine predictions.',
          createdAt: t,
          eventDate: today,
        ),
      );
    }
    // A dismissed alert stays dismissed even when the generator or a one-shot
    // would otherwise recreate the same stable id.
    merged.removeWhere((a) => _dismissedIds.contains(a.id));
    merged.removeWhere((a) => a.eventDate.isBefore(today));
    // Upcoming events first; same-day ties break by newest generation time.
    merged.sort((a, b) {
      final byEvent = b.eventDate.compareTo(a.eventDate);
      return byEvent != 0 ? byEvent : b.createdAt.compareTo(a.createdAt);
    });
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

  void dismiss(String id) {
    final before = _items.length;
    _items.removeWhere((a) => a.id == id);
    final added = _dismissedIds.add(id);
    if (_dismissedIds.length > _maxDismissed) {
      final overflow = _dismissedIds.length - _maxDismissed;
      final oldest = _dismissedIds.take(overflow).toList();
      _dismissedIds.removeAll(oldest);
    }
    if (_items.length != before || added) {
      notifyListeners();
      _save();
      _saveDismissed();
    }
  }

  /// Re-inserts a dismissed alert (undo), keeping event-date order.
  void restore(AlertItem item) {
    if (_items.any((a) => a.id == item.id)) return;
    _dismissedIds.remove(item.id);
    _items.add(item);
    _items.sort((a, b) {
      final byEvent = b.eventDate.compareTo(a.eventDate);
      return byEvent != 0 ? byEvent : b.createdAt.compareTo(a.createdAt);
    });
    notifyListeners();
    _save();
    _saveDismissed();
  }

  void _save() => _prefs.saveAlertItems(_items);

  void _saveDismissed() => _prefs.saveDismissedAlertIds(_dismissedIds.toList());

  /// In-memory reset after Delete All Data (prefs already wiped).
  /// Called last so cycle-triggered regeneration runs before this clears.
  void resetToDefaults() {
    _items.clear();
    _dismissedIds.clear();
    notifyListeners();
  }
}
