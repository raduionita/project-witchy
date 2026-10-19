import 'package:flutter_test/flutter_test.dart';
import 'package:witchy/common/log_summary.dart';

void main() {
  test('an empty set falls back to the empty label', () {
    expect(summarizeLogSet(const {}), 'Not logged');
    expect(summarizeLogSet(const {}, empty: 'None'), 'None');
  });

  test('a single value is returned as-is', () {
    expect(summarizeLogSet(const {'Medium'}), 'Medium');
    expect(summarizeLogSet(const {'Good sleep'}), 'Good sleep');
  });

  test('multiple values report the first plus a count', () {
    expect(summarizeLogSet(const {'Cramps', 'Headache', 'Bloating'}), 'Cramps +2');
    expect(summarizeLogSet(const {'Happy', 'Calm'}), 'Happy +1');
  });
}
