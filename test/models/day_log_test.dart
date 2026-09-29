import 'package:flutter_test/flutter_test.dart';
import 'package:witchy/models/day_log.dart';

void main() {
  test('DayLog toJson/fromJson round-trip preserves all fields', () {
    final original = DayLog(
      flow: 'Heavy',
      moods: {'Enchanted', 'Restless'},
      symptoms: {'Headache', 'Bloating'},
      pain: 8.5,
      notes: 'Full moon entry.',
    );

    final restored = DayLog.fromJson(original.toJson());

    expect(restored.flow, original.flow);
    expect(restored.moods, original.moods);
    expect(restored.symptoms, original.symptoms);
    expect(restored.pain, original.pain);
    expect(restored.notes, original.notes);
  });

  test('DayLog.fromJson falls back to defaults on empty json', () {
    final log = DayLog.fromJson(const {});

    expect(log.flow, 'None');
    expect(log.moods, isEmpty);
    expect(log.symptoms, isEmpty);
    expect(log.pain, 6);
    expect(log.notes, isEmpty);
  });

  test('DayLog.fromJson tolerates unknown keys', () {
    final log = DayLog.fromJson(const {'flow': 'Light', 'bogus': 42});

    expect(log.flow, 'Light');
    expect(log.pain, 6);
  });
}
