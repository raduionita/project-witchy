import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:witchy/models/tracking_mode.dart';
import 'package:witchy/services/prefs_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test('drops a removed birth-control mode from stored modes', () async {
    SharedPreferences.setMockInitialValues({
      'witchy_tracking_modes': '["pregnancy","contraception"]',
    });

    expect(await PrefsService().trackingModes(), {TrackingMode.pregnancy});
  });

  test('falls back to cycle when every stored mode was removed', () async {
    SharedPreferences.setMockInitialValues({
      'witchy_tracking_modes': '["contraception"]',
    });

    expect(await PrefsService().trackingModes(), {TrackingMode.cycle});
  });

  test('keeps known stored modes together', () async {
    SharedPreferences.setMockInitialValues({
      'witchy_tracking_modes': '["cycle","pregnancy"]',
    });

    expect(await PrefsService().trackingModes(), {TrackingMode.cycle, TrackingMode.pregnancy});
  });

  test('still reads the legacy single-mode key', () async {
    SharedPreferences.setMockInitialValues({'witchy_tracking_mode': 'pregnancy'});

    expect(await PrefsService().trackingModes(), {TrackingMode.pregnancy});
  });

  test('defaults to cycle with no stored value', () async {
    SharedPreferences.setMockInitialValues({});

    expect(await PrefsService().trackingModes(), {TrackingMode.cycle});
  });
}
