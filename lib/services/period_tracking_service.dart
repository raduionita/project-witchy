import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/period_cycle.dart';

class PeriodTrackingService {
  static const String _cyclesKey = 'period_cycles';
  static const String _profileKey = 'user_profile';

  Future<List<PeriodCycle>> loadCycles() async {
    final prefs = await SharedPreferences.getInstance();
    final cyclesJson = prefs.getStringList(_cyclesKey) ?? [];
    return cyclesJson.map((json) => PeriodCycle.fromJson(jsonDecode(json))).toList();
  }

  Future<void> saveCycle(PeriodCycle cycle) async {
    final prefs = await SharedPreferences.getInstance();
    final cycles = await loadCycles();
    final index = cycles.indexWhere((c) => c.id == cycle.id);
    if (index != -1) {
      cycles[index] = cycle;
    } else {
      cycles.add(cycle);
    }
    final jsonList = cycles.map((c) => jsonEncode(c.toJson())).toList();
    await prefs.setStringList(_cyclesKey, jsonList);
  }

  Future<void> deleteCycle(String cycleId) async {
    final prefs = await SharedPreferences.getInstance();
    final cycles = await loadCycles();
    cycles.removeWhere((c) => c.id == cycleId);
    final jsonList = cycles.map((c) => jsonEncode(c.toJson())).toList();
    await prefs.setStringList(_cyclesKey, jsonList);
  }

  Future<Map<String, dynamic>> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final profileJson = prefs.getString(_profileKey);
    if (profileJson != null) {
      return jsonDecode(profileJson);
    }
    return {};
  }

  Future<void> saveProfile(Map<String, dynamic> profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_profileKey, jsonEncode(profile));
  }
}
