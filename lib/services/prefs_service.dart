import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/alert_item.dart';
import '../models/article.dart';
import '../models/day_log.dart';
import '../models/tracking_mode.dart';

class PrefsService {
  static const _onboarded = 'witchy_onboarded';
  static const _cycleLen = 'witchy_cycle_len';
  static const _bleedLen = 'witchy_bleed_len';
  static const _lastPeriod = 'witchy_last_period';
  static const _dayLogs = 'witchy_day_logs';
  static const _lunarNotifications = 'witchy_lunar_notifications';
  static const _darkMode = 'witchy_dark_mode';
  static const _reminders = 'witchy_reminders';
  static const _session = 'witchy_session';
  static const _privacyAccepted = 'witchy_privacy_accepted';
  static const _birthYear = 'witchy_birth_year';
  static const _feedCache = 'witchy_feed_cache';
  static const _trackingMode = 'witchy_tracking_mode';
  static const _trackingModes = 'witchy_tracking_modes';
  static const _alerts = 'witchy_alerts';
  static const _pregnancyLmp = 'witchy_pregnancy_lmp';

  Future<bool> isPrivacyAccepted() async => (await SharedPreferences.getInstance()).getBool(_privacyAccepted) ?? false;
  Future<void> setPrivacyAccepted() async => (await SharedPreferences.getInstance()).setBool(_privacyAccepted, true);

  Future<int?> birthYear() async => (await SharedPreferences.getInstance()).getInt(_birthYear);
  Future<void> setBirthYear(int year) async => (await SharedPreferences.getInstance()).setInt(_birthYear, year);

  /// Active tracking modes; migrates the legacy single-mode string and defaults to {cycle}.
  Future<Set<TrackingMode>> trackingModes() async {
    final p = await SharedPreferences.getInstance();
    final raw = p.getString(_trackingModes);
    if (raw != null) {
      return (jsonDecode(raw) as List<dynamic>).map((e) => TrackingMode.fromJson(e)).toSet();
    }
    final legacy = p.getString(_trackingMode);
    return legacy == null ? {TrackingMode.cycle} : {TrackingMode.fromJson(legacy)};
  }

  Future<void> setTrackingModes(Set<TrackingMode> modes) async => (await SharedPreferences.getInstance()).setString(_trackingModes, jsonEncode([for (final m in modes) m.name]));

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

  Future<List<Article>?> feedCache() async {
    final raw = (await SharedPreferences.getInstance()).getString(_feedCache);
    if (raw == null) return null;
    return (jsonDecode(raw) as List<dynamic>).map((e) => Article.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveFeedCache(List<Article> articles) async {
    final encoded = jsonEncode(articles.map((a) => a.toJson()).toList());
    await (await SharedPreferences.getInstance()).setString(_feedCache, encoded);
  }

  Future<List<AlertItem>> alertItems() async {
    final raw = (await SharedPreferences.getInstance()).getString(_alerts);
    if (raw == null) return [];
    return (jsonDecode(raw) as List<dynamic>).map((e) => AlertItem.fromJson(e as Map<String, dynamic>)).toList();
  }

  Future<void> saveAlertItems(List<AlertItem> items) async {
    final encoded = jsonEncode(items.map((a) => a.toJson()).toList());
    await (await SharedPreferences.getInstance()).setString(_alerts, encoded);
  }

  Future<DateTime?> lmpDate() async {
    final raw = (await SharedPreferences.getInstance()).getString(_pregnancyLmp);
    return raw == null ? null : DateTime.tryParse(raw);
  }

  Future<void> setLmpDate(DateTime date) async => (await SharedPreferences.getInstance()).setString(_pregnancyLmp, date.toIso8601String());

  Future<void> clearLegacyBindingFlags() async {
    final p = await SharedPreferences.getInstance();
    await p.remove('witchy_share_bleed');
    await p.remove('witchy_share_fertile');
    await p.remove('witchy_share_symptoms');
  }

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

  /// Removes every app key (Delete All Data) - leaves foreign keys untouched.
  Future<void> clearAllData() async {
    final p = await SharedPreferences.getInstance();
    final witchyKeys = p.getKeys().where((k) => k.startsWith('witchy_')).toList();
    for (final key in witchyKeys) {
      await p.remove(key);
    }
  }
}
