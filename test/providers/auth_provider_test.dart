import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:witchy/providers/auth_provider.dart';
import 'package:witchy/services/prefs_service.dart';

void main() {
  late PrefsService prefs;
  late SharedPreferences raw;

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    prefs = PrefsService();
    raw = await SharedPreferences.getInstance();
  });

  test('AuthProvider.load restores identity from saved session', () async {
    await prefs.saveSession({'method': 'google', 'email': 'moon@star.io', 'name': 'Luna'});

    final auth = await AuthProvider.load(prefs);

    expect(auth.signedIn, isTrue);
    expect(auth.identity?.method, 'google');
    expect(auth.identity?.email, 'moon@star.io');
    expect(auth.identity?.name, 'Luna');
  });

  test('AuthProvider.load with no session starts signed out', () async {
    final auth = await AuthProvider.load(prefs);

    expect(auth.signedIn, isFalse);
    expect(auth.identity, isNull);
  });

  test('signOut clears session and identity', () async {
    await prefs.saveSession({'method': 'google', 'email': 'selene@moon.co', 'name': 'Selene'});
    final auth = await AuthProvider.load(prefs);
    expect(auth.signedIn, isTrue);

    await auth.signOut();

    expect(auth.signedIn, isFalse);
    expect(auth.identity, isNull);
    expect(auth.lastError, isNull);
    expect(await prefs.session(), isNull);
    expect(raw.getString('witchy_session'), isNull);
  });
}
