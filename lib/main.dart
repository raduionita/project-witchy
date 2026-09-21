import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'navigation/main_shell.dart';
import 'providers/app_providers.dart';
import 'screens/auth_screens.dart';
import 'screens/secondary_screens.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const WitchyApp());
}

class WitchyApp extends StatelessWidget {
  const WitchyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MockAuthProvider()),
        ChangeNotifierProvider(create: (_) => OnboardingProvider()),
        ChangeNotifierProvider(create: (_) => LogProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => RemindersProvider()),
      ],
      child: MaterialApp(
        title: 'Witchy',
        theme: buildWitchyTheme(),
        initialRoute: '/',
        routes: {
          '/': (_) => const SplashScreen(),
          '/join': (_) => const JoinScreen(),
          '/rhythms': (_) => const RhythmsScreen(),
          '/shell': (_) => const MainShell(),
          '/blood': (_) => const BloodScreen(),
          '/log': (_) => const MainShell(),
          '/gestation': (_) => const GestationScreen(),
          '/alerts': (_) => const AlertsScreen(),
          '/coven': (_) => const CovenScreen(),
          '/library': (_) => const LibraryScreen(),
          '/reminders': (_) => const RemindersScreen(),
          '/binding': (_) => const BindingScreen(),
        },
      ),
    );
  }
}
