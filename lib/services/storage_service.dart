import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/period_cycle.dart';
import '../models/symptom.dart';
import '../models/mood.dart';
import '../models/user_profile.dart';
import '../models/fertility_prediction.dart';
import '../models/pregnancy_tracker.dart';
import '../models/notification_model.dart';

class StorageService {
  static const String _userProfileKey = 'user_profile';
  static const String _periodCyclesKey = 'period_cycles';
  static const String _symptomsKey = 'symptoms';
  static const String _moodsKey = 'moods';
  static const String _fertilityPredictionsKey = 'fertility_predictions';
  static const String _pregnancyTrackerKey = 'pregnancy_tracker';
  static const String _notificationsKey = 'notifications';
  static const String _onboardingCompletedKey = 'onboarding_completed';

  Future<SharedPreferences> _getPrefs() async {
    return SharedPreferences.getInstance();
  }

  Future<void> saveUserProfile(UserProfile profile) async {
    final prefs = await _getPrefs();
    await prefs.setString(_userProfileKey, profile.toJson());
  }

  Future<UserProfile?> getUserProfile() async {
    final prefs = await _getPrefs();
    final String? data = prefs.getString(_userProfileKey);
    if (data == null) return null;
    return UserProfile.fromJson(data);
  }

  Future<void> savePeriodCycles(List<PeriodCycle> cycles) async {
    final prefs = await _getPrefs();
    final String data = json.encode(cycles.map((c) => c.toJson()).toList());
    await prefs.setString(_periodCyclesKey, data);
  }

  Future<List<PeriodCycle>> getPeriodCycles() async {
    final prefs = await _getPrefs();
    final String? data = prefs.getString(_periodCyclesKey);
    if (data == null) return [];
    final List<dynamic> decoded = json.decode(data);
    return decoded.map((c) => PeriodCycle.fromJson(c as String)).toList();
  }

  Future<void> saveSymptoms(List<Symptom> symptoms) async {
    final prefs = await _getPrefs();
    final String data = json.encode(symptoms.map((s) => s.toJson()).toList());
    await prefs.setString(_symptomsKey, data);
  }

  Future<List<Symptom>> getSymptoms() async {
    final prefs = await _getPrefs();
    final String? data = prefs.getString(_symptomsKey);
    if (data == null) return [];
    final List<dynamic> decoded = json.decode(data);
    return decoded.map((s) => Symptom.fromJson(s as String)).toList();
  }

  Future<void> saveMoods(List<MoodEntry> moods) async {
    final prefs = await _getPrefs();
    final String data = json.encode(moods.map((m) => m.toJson()).toList());
    await prefs.setString(_moodsKey, data);
  }

  Future<List<MoodEntry>> getMoods() async {
    final prefs = await _getPrefs();
    final String? data = prefs.getString(_moodsKey);
    if (data == null) return [];
    final List<dynamic> decoded = json.decode(data);
    return decoded.map((m) => MoodEntry.fromJson(m as String)).toList();
  }

  Future<void> saveFertilityPredictions(List<FertilityPrediction> predictions) async {
    final prefs = await _getPrefs();
    final String data = json.encode(predictions.map((p) => p.toJson()).toList());
    await prefs.setString(_fertilityPredictionsKey, data);
  }

  Future<List<FertilityPrediction>> getFertilityPredictions() async {
    final prefs = await _getPrefs();
    final String? data = prefs.getString(_fertilityPredictionsKey);
    if (data == null) return [];
    final List<dynamic> decoded = json.decode(data);
    return decoded.map((p) => FertilityPrediction.fromJson(p as String)).toList();
  }

  Future<void> savePregnancyTracker(PregnancyTracker tracker) async {
    final prefs = await _getPrefs();
    await prefs.setString(_pregnancyTrackerKey, tracker.toJson());
  }

  Future<PregnancyTracker?> getPregnancyTracker() async {
    final prefs = await _getPrefs();
    final String? data = prefs.getString(_pregnancyTrackerKey);
    if (data == null) return null;
    return PregnancyTracker.fromJson(data);
  }

  Future<void> saveNotifications(List<AppNotification> notifications) async {
    final prefs = await _getPrefs();
    final String data = json.encode(notifications.map((n) => n.toJson()).toList());
    await prefs.setString(_notificationsKey, data);
  }

  Future<List<AppNotification>> getNotifications() async {
    final prefs = await _getPrefs();
    final String? data = prefs.getString(_notificationsKey);
    if (data == null) return [];
    final List<dynamic> decoded = json.decode(data);
    return decoded.map((n) => AppNotification.fromJson(n as String)).toList();
  }

  Future<void> setOnboardingCompleted(bool completed) async {
    final prefs = await _getPrefs();
    await prefs.setBool(_onboardingCompletedKey, completed);
  }

  Future<bool> isOnboardingCompleted() async {
    final prefs = await _getPrefs();
    return prefs.getBool(_onboardingCompletedKey) ?? false;
  }

  Future<void> clearAllData() async {
    final prefs = await _getPrefs();
    await prefs.clear();
  }
}
