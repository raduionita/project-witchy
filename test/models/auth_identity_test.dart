import 'package:flutter_test/flutter_test.dart';
import 'package:witchy/models/auth_identity.dart';

void main() {
  test('AuthIdentity toMap/fromMap round-trip preserves fields', () {
    const original = AuthIdentity(method: 'google', name: 'Selene', email: 'selene@moon.co');

    final restored = AuthIdentity.fromMap(original.toMap());

    expect(restored.method, original.method);
    expect(restored.name, original.name);
    expect(restored.email, original.email);
  });

  test('AuthIdentity omits empty name and email from map', () {
    const identity = AuthIdentity(method: 'apple', name: '', email: '');

    final map = identity.toMap();

    expect(map.keys, ['method']);
    expect(AuthIdentity.fromMap(map).name, isNull);
    expect(AuthIdentity.fromMap(map).email, isNull);
  });

  test('AuthIdentity.fromMap defaults method to email on missing keys', () {
    final restored = AuthIdentity.fromMap(const {});

    expect(restored.method, 'email');
    expect(restored.name, isNull);
    expect(restored.email, isNull);
  });
}
