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
    final states = await prefs.reminderStates();
    if (states != null) {
      for (final item in items) {
        final enabled = states[item.title];
        if (enabled != null) item.enabled = enabled;
      }
    }
    return RemindersProvider(prefs, items: items);
  }

  void toggle(int i, bool v) {
    items[i].enabled = v;
    notifyListeners();
    _save();
  }

  void _save() => _prefs.saveReminderStates({for (final item in items) item.title: item.enabled});
}
