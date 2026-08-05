// Persistence service for saving/loading cycle data to shared_preferences

import 'package:shared_preferences/shared_preferences.dart';
import '../models/cycle_models.dart';

/// Service for persisting cycle data to shared_preferences
class PersistenceService {
  final SharedPreferences _prefs;

  PersistenceService(this._prefs);

  // Keys for shared_preferences
  static const String _keyCycleEntries = 'cycle_entries';
  static const String _keyPregnancyInfo = 'pregnancy_info';
  static const String _keyPerimenopauseTracker = 'perimenopause_tracker';

  // Save cycle entries
  Future<void> saveCycleEntries(List<CycleEntry> entries) async {
    final jsonList = entries.map((e) => e.toJson()).toList();
    await _prefs.setString(_keyCycleEntries, jsonEncode(jsonList));
  }

  // Load cycle entries
  List<CycleEntry> loadCycleEntries() {
    final json = _prefs.getString(_keyCycleEntries);
    if (json == null) return [];

    try {
      final jsonList = jsonDecode(json) as List<dynamic>;
      return jsonList.map((j) => CycleEntry.fromJson(j)).toList();
    } catch (e) {
      return [];
    }
  }

  // Save pregnancy info
  Future<void> savePregnancyInfo(PregnancyInfo info) async {
    await _prefs.setString(_keyPregnancyInfo, jsonEncode(info.toJson()));
  }

  // Load pregnancy info
  PregnancyInfo? loadPregnancyInfo() {
    final json = _prefs.getString(_keyPregnancyInfo);
    if (json == null) return null;

    try {
      final data = jsonDecode(json) as Map<String, dynamic>;
      return PregnancyInfo.fromJson(data);
    } catch (e) {
      return null;
    }
  }

  // Save perimenopause tracker
  Future<void> savePerimenopauseTracker(PerimenopauseTracker tracker) async {
    await _prefs.setString(_keyPerimenopauseTracker, jsonEncode(tracker.toJson()));
  }

  // Load perimenopause tracker
  PerimenopauseTracker? loadPerimenopauseTracker() {
    final json = _prefs.getString(_keyPerimenopauseTracker);
    if (json == null) return null;

    try {
      final data = jsonDecode(json) as Map<String, dynamic>;
      return PerimenopauseTracker.fromJson(data);
    } catch (e) {
      return null;
    }
  }

    // Clear all data
  Future<void> clearAllData() async {
    await _prefs.remove(_keyCycleEntries);
    await _prefs.remove(_keyPregnancyInfo);
    await _prefs.remove(_keyPerimenopauseTracker);
    await _prefs.remove(_keySymptoms);
  }

  // Save symptoms
  Future<void> saveSymptoms(List<TrackedSymptom> symptoms) async {
    final jsonList = symptoms.map((s) => s.toJson()).toList();
    await _prefs.setString(_keySymptoms, jsonEncode(jsonList));
  }

  // Load symptoms
  List<Map<String, dynamic>> loadSymptoms() {
    final json = _prefs.getString(_keySymptoms);
    if (json == null) return [];

    try {
      return jsonDecode(json) as List<Map<String, dynamic>>;
    } catch (e) {
      return [];
    }
  }

}
