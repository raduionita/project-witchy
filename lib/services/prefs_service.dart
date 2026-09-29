import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/day_log.dart';

class PrefsService {
  static const _onboarded = 'witchy_onboarded';
  static const _cycleLen = 'witchy_cycle_len';
  static const _bleedLen = 'witchy_bleed_len';
  static const _lastPeriod = 'witchy_last_period';
  static const _dayLogs = 'witchy_day_logs';
  static const _lunarNotifications = 'witchy_lunar_notifications';
  static const _darkMode = 'witchy_dark_mode';
  static const _shareBleed = 'witchy_share_bleed';
  static const _shareFertile = 'witchy_share_fertile';
  static const _shareSymptoms = 'witchy_share_symptoms';
  static const _reminders = 'witchy_reminders';
  static const _session = 'witchy_session';
  static const _privacyAccepted = 'witchy_privacy_accepted';
  static const _birthYear = 'witchy_birth_year';

  Future<bool> isPrivacyAccepted() async => (await SharedPreferences.getInstance()).getBool(_privacyAccepted) ?? false;
  Future<void> setPrivacyAccepted() async => (await SharedPreferences.getInstance()).setBool(_privacyAccepted, true);

  Future<int?> birthYear() async => (await SharedPreferences.getInstance()).getInt(_birthYear);
  Future<void> setBirthYear(int year) async => (await SharedPreferences.getInstance()).setInt(_birthYear, year);

  Future<bool> isOnboarded() async => (await SharedPreferences.getInstance()).getBool(_onboarded) ?? false;
  Future<void> setOnboarded() async => (await SharedPreferences.getInstance()).setBool(_onboarded, true);

  Future<int> cycleLength() async => (await SharedPreferences.getInstance()).getInt(_cycleLen) ?? 28;
  Future<int> bleedLength() async => (await SharedPreferences.getInstance()).getInt(_bleedLen) ?? 5;
  Future<DateTime?> lastPeriod() async {
    final raw = (await SharedPreferences.getInstance()).getString(_lastPeriod);
    return raw == null ? null : DateTime.tryParse(raw);
  }

  Future<void> saveRhythms(int cycle, int bleed, DateTime last) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_cycleLen, cycle);
    await p.setInt(_bleedLen, bleed);
    await p.setString(_lastPeriod, last.toIso8601String());
  }

  Future<Map<String, DayLog>> loadDayLogs() async {
    final raw = (await SharedPreferences.getInstance()).getString(_dayLogs);
    if (raw == null) return {};
    final decoded = jsonDecode(raw) as Map<String, dynamic>;
    return decoded.map((key, value) => MapEntry(key, DayLog.fromJson(value as Map<String, dynamic>)));
  }

  Future<void> saveDayLogs(Map<String, DayLog> days) async {
    final encoded = jsonEncode(days.map((key, value) => MapEntry(key, value.toJson())));
    await (await SharedPreferences.getInstance()).setString(_dayLogs, encoded);
  }

  Future<bool> lunarNotifications() async => (await SharedPreferences.getInstance()).getBool(_lunarNotifications) ?? true;
  Future<void> setLunarNotifications(bool v) async => (await SharedPreferences.getInstance()).setBool(_lunarNotifications, v);

  Future<bool> darkMode() async => (await SharedPreferences.getInstance()).getBool(_darkMode) ?? false;
  Future<void> setDarkMode(bool v) async => (await SharedPreferences.getInstance()).setBool(_darkMode, v);

  Future<bool> shareBleed() async => (await SharedPreferences.getInstance()).getBool(_shareBleed) ?? true;
  Future<void> setShareBleed(bool v) async => (await SharedPreferences.getInstance()).setBool(_shareBleed, v);

  Future<bool> shareFertile() async => (await SharedPreferences.getInstance()).getBool(_shareFertile) ?? true;
  Future<void> setShareFertile(bool v) async => (await SharedPreferences.getInstance()).setBool(_shareFertile, v);

  Future<bool> shareSymptoms() async => (await SharedPreferences.getInstance()).getBool(_shareSymptoms) ?? false;
  Future<void> setShareSymptoms(bool v) async => (await SharedPreferences.getInstance()).setBool(_shareSymptoms, v);

  Future<Map<String, bool>?> reminderStates() async {
    final raw = (await SharedPreferences.getInstance()).getString(_reminders);
    if (raw == null) return null;
    return (jsonDecode(raw) as Map<String, dynamic>).map((key, value) => MapEntry(key, value as bool));
  }

  Future<void> saveReminderStates(Map<String, bool> states) async => (await SharedPreferences.getInstance()).setString(_reminders, jsonEncode(states));

  Future<Map<String, String>?> session() async {
    final raw = (await SharedPreferences.getInstance()).getString(_session);
    if (raw == null) return null;
    return (jsonDecode(raw) as Map<String, dynamic>).map((key, value) => MapEntry(key, value as String));
  }

  Future<void> saveSession(Map<String, String> data) async => (await SharedPreferences.getInstance()).setString(_session, jsonEncode(data));
  Future<void> clearSession() async => (await SharedPreferences.getInstance()).remove(_session);
}
