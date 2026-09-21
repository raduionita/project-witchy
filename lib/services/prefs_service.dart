import 'package:shared_preferences/shared_preferences.dart';

class PrefsService {
  static const _onboarded = 'witchy_onboarded';
  static const _cycleLen = 'witchy_cycle_len';
  static const _bleedLen = 'witchy_bleed_len';
  static const _lastPeriod = 'witchy_last_period';

  Future<bool> isOnboarded() async => (await SharedPreferences.getInstance()).getBool(_onboarded) ?? false;
  Future<void> setOnboarded() async => (await SharedPreferences.getInstance()).setBool(_onboarded, true);

  Future<int> cycleLength() async => (await SharedPreferences.getInstance()).getInt(_cycleLen) ?? 28;
  Future<int> bleedLength() async => (await SharedPreferences.getInstance()).getInt(_bleedLen) ?? 5;
  Future<void> saveRhythms(int cycle, int bleed, DateTime last) async {
    final p = await SharedPreferences.getInstance();
    await p.setInt(_cycleLen, cycle);
    await p.setInt(_bleedLen, bleed);
    await p.setString(_lastPeriod, last.toIso8601String());
  }
}
