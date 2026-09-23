import 'package:flutter/material.dart';
import '../models/witchy_models.dart';
import '../services/prefs_service.dart';

class MockAuthProvider extends ChangeNotifier {
  bool signedIn = false;
  bool busy = false;
  Future<void> signIn() async {
    busy = true;
    notifyListeners();
    await Future.delayed(const Duration(milliseconds: 600));
    busy = false;
    signedIn = true;
    notifyListeners();
  }

  void signOut() {
    signedIn = false;
    notifyListeners();
  }
}

class OnboardingProvider extends ChangeNotifier {
  int selectedDay = 17;
  int cycleLength = 28;
  int bleedLength = 5;
  final PrefsService _prefs = PrefsService();

  void setDay(int d) {
    selectedDay = d;
    notifyListeners();
  }

  void setCycle(int v) {
    cycleLength = v;
    notifyListeners();
  }

  void setBleed(int v) {
    bleedLength = v;
    notifyListeners();
  }

  Future<void> finish() async {
    final now = DateTime.now();
    final last = DateTime(now.year, now.month, selectedDay <= 28 ? selectedDay : 28);
    await _prefs.saveRhythms(cycleLength, bleedLength, last);
    await _prefs.setOnboarded();
  }
}

class DayLog {
  String flow;
  final Set<String> moods;
  final Set<String> symptoms;
  double pain;
  String notes;
  DayLog({this.flow = 'Medium', Set<String>? moods, Set<String>? symptoms, this.pain = 6, String? notes})
    : moods = moods ?? {},
      symptoms = symptoms ?? {'Uterine Cramps'},
      notes = notes ?? 'Drank chamomile raspberry leaf infusion. Felt waves of emotional clearing in the afternoon.';
}

class LoggingProvider extends ChangeNotifier {
  final Map<String, DayLog> _days = {};

  static String keyFor(DateTime d) => '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  DayLog day(DateTime d) => _days.putIfAbsent(keyFor(d), () => DayLog());

  void setFlow(DateTime d, String v) {
    day(d).flow = v;
    notifyListeners();
  }

  void toggleMood(DateTime d, String v) {
    final m = day(d).moods;
    m.contains(v) ? m.remove(v) : m.add(v);
    notifyListeners();
  }

  void toggleSymptom(DateTime d, String v) {
    final s = day(d).symptoms;
    s.contains(v) ? s.remove(v) : s.add(v);
    notifyListeners();
  }

  void setPain(DateTime d, double v) {
    day(d).pain = v;
    notifyListeners();
  }

  void setNotes(DateTime d, String v) {
    day(d).notes = v;
    notifyListeners();
  }
}

class SettingsProvider extends ChangeNotifier {
  bool lunarNotifications = true;
  bool darkMode = false;
  bool shareBleed = true;
  bool shareFertile = true;
  bool shareSymptoms = false;

  void setLunar(bool v) {
    lunarNotifications = v;
    notifyListeners();
  }

  void setDark(bool v) {
    darkMode = v;
    notifyListeners();
  }

  void setShareBleed(bool v) {
    shareBleed = v;
    notifyListeners();
  }

  void setShareFertile(bool v) {
    shareFertile = v;
    notifyListeners();
  }

  void setShareSymptoms(bool v) {
    shareSymptoms = v;
    notifyListeners();
  }
}

class RemindersProvider extends ChangeNotifier {
  final List<ReminderItem> items = MockData.reminders();
  void toggle(int i, bool v) {
    items[i].enabled = v;
    notifyListeners();
  }
}
