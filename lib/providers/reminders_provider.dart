import 'package:flutter/material.dart';

import '../models/mock_data.dart';
import '../models/reminder_item.dart';
import '../services/prefs_service.dart';

class RemindersProvider extends ChangeNotifier {
  RemindersProvider(this._prefs, {required this.items});

  final PrefsService _prefs;
  final List<ReminderItem> items;

  static Future<RemindersProvider> load(PrefsService prefs) async {
    final items = MockData.reminders();
    final configs = await prefs.reminderConfigs();
    if (configs != null) {
      for (final item in items) {
        final c = configs[item.title];
        if (c is bool) {
          item.enabled = c;
        } else if (c is Map) {
          item.enabled = (c['enabled'] as bool?) ?? item.enabled;
          item.time = (c['time'] as String?) ?? item.time;
          item.freq = (c['freq'] as String?) ?? item.freq;
        }
      }
    }
    return RemindersProvider(prefs, items: items);
  }

  void toggle(int i, bool v) {
    items[i].enabled = v;
    notifyListeners();
    _save();
  }

  void setTime(int i, String time) {
    items[i].time = time;
    notifyListeners();
    _save();
  }

  void setFrequency(int i, String freq) {
    items[i].freq = freq;
    notifyListeners();
    _save();
  }

  void _save() => _prefs.saveReminderConfigs({
        for (final item in items)
          item.title: {'enabled': item.enabled, 'time': item.time, 'freq': item.freq},
      });

  /// In-memory reset after Delete All Data (prefs already wiped).
  void resetToDefaults() {
    final defaults = MockData.reminders();
    items..clear()..addAll(defaults);
    notifyListeners();
  }
}
