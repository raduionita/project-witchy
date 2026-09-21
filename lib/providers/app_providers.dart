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

class LoggingProvider extends ChangeNotifier {
  String flow = 'Medium';
  final Set<String> moods = {};
  final Set<String> symptoms = {'Uterine Cramps'};
  double pain = 6;
  String notes = 'Drank chamomile raspberry leaf infusion. Felt waves of emotional clearing in the afternoon.';

  void setFlow(String v) {
    flow = v;
    notifyListeners();
  }

  void toggleMood(String v) {
    moods.contains(v) ? moods.remove(v) : moods.add(v);
    notifyListeners();
  }

  void toggleSymptom(String v) {
    symptoms.contains(v) ? symptoms.remove(v) : symptoms.add(v);
    notifyListeners();
  }

  void setPain(double v) {
    pain = v;
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
