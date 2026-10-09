import 'package:flutter_test/flutter_test.dart';
import 'package:witchy/models/tracking_mode.dart';

void main() {
  test('toJson/fromJson round-trip', () {
    for (final mode in TrackingMode.values) {
      expect(TrackingMode.fromJson(mode.toJson()), mode);
    }
  });

  test('fromJson defaults to cycle for unknown or missing values', () {
    expect(TrackingMode.fromJson('nonsense'), TrackingMode.cycle);
    expect(TrackingMode.fromJson(null), TrackingMode.cycle);
    expect(TrackingMode.fromJson(42), TrackingMode.cycle);
  });

  test('labels cover the three onboarding chips', () {
    expect(TrackingMode.values.map((m) => m.label), ['Cycle', 'Pregnancy', 'Perimenopause']);
  });
}
