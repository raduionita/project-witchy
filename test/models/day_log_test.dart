import 'package:flutter_test/flutter_test.dart';
import 'package:witchy/models/day_log.dart';

void main() {
  test('DayLog toJson/fromJson round-trip preserves all fields', () {
    final original = DayLog(
      flow: {'Heavy'},
      collection: {'Cup'},
      moods: {'Enchanted', 'Restless'},
      symptoms: {'Headache', 'Bloating'},
      digestion: {'Nausea'},
      skinHair: {'Acne'},
      cravings: {'Sweet cravings'},
      sex: {'Protected sex'},
      sleep: {'Insomnia'},
      discharge: {'Creamy'},
      pain: 8.5,
      notes: 'Full moon entry.',
    );

    final restored = DayLog.fromJson(original.toJson());

    expect(restored.flow, original.flow);
    expect(restored.collection, original.collection);
    expect(restored.moods, original.moods);
    expect(restored.symptoms, original.symptoms);
    expect(restored.digestion, original.digestion);
    expect(restored.skinHair, original.skinHair);
    expect(restored.cravings, original.cravings);
    expect(restored.sex, original.sex);
    expect(restored.sleep, original.sleep);
    expect(restored.discharge, original.discharge);
    expect(restored.pain, original.pain);
    expect(restored.notes, original.notes);
  });

  test('DayLog.fromJson falls back to defaults on empty json', () {
    final log = DayLog.fromJson(const {});

    expect(log.flow, isEmpty);
    expect(log.collection, isEmpty);
    expect(log.moods, isEmpty);
    expect(log.symptoms, isEmpty);
    expect(log.digestion, isEmpty);
    expect(log.skinHair, isEmpty);
    expect(log.cravings, isEmpty);
    expect(log.sex, isEmpty);
    expect(log.sleep, isEmpty);
    expect(log.discharge, isEmpty);
    expect(log.pain, 6);
    expect(log.notes, isEmpty);
  });

  test('DayLog.fromJson loads pre-expansion payload without new keys', () {
    final log = DayLog.fromJson(const {'flow': 'Light', 'moods': ['Happy'], 'pain': 3, 'notes': 'old'});

    expect(log.flow, {'Light'});
    expect(log.moods, {'Happy'});
    expect(log.sleep, isEmpty);
    expect(log.discharge, isEmpty);
    expect(log.pain, 3);
    expect(log.notes, 'old');
  });

  test('DayLog.fromJson maps legacy flow/discharge strings to sets', () {
    expect(DayLog.fromJson(const {'flow': 'None'}).flow, isEmpty);
    expect(DayLog.fromJson(const {'flow': 'Heavy'}).flow, {'Heavy'});
    expect(DayLog.fromJson(const {'discharge': ''}).discharge, isEmpty);
    expect(DayLog.fromJson(const {'discharge': 'Sticky'}).discharge, {'Sticky'});
  });

  test('DayLog.fromJson tolerates unknown keys', () {
    final log = DayLog.fromJson(const {'flow': 'Light', 'bogus': 42});

    expect(log.flow, {'Light'});
    expect(log.pain, 6);
  });
}
