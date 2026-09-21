import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'navigation/main_shell.dart';
import 'providers/app_providers.dart';
import 'screens/article_detail_screen.dart';
import 'screens/auth_screens.dart';
import 'screens/chart_screen.dart';
import 'screens/fertility_screen.dart';
import 'screens/primary_screens.dart';
import 'screens/secondary_screens.dart';
import 'screens/settings_screen.dart';
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
        debugShowCheckedModeBanner: false,
        initialRoute: '/welcome',
        routes: {
          // Canonical (DESIGN.md)
          '/welcome': (_) => const SplashScreen(),
          '/auth': (_) => const JoinScreen(),
          '/onboarding': (_) => const RhythmsScreen(),
          '/dashboard': (_) => const MainShell(initialIndex: 0),
          '/calendar': (_) => const MainShell(initialIndex: 1),
          '/dailies': (_) => const MainShell(initialIndex: 2),
          '/insights/overview': (_) => const MainShell(initialIndex: 3),
          '/community/coven': (_) => const MainShell(initialIndex: 4),
          '/profile': (_) => const ProfileScreen(),
          '/cycle/blood': (_) => const BloodScreen(),
          '/alerts': (_) => const AlertsScreen(),
          '/community/binding': (_) => const BindingScreen(),
          '/wellness/library': (_) => const LibraryScreen(),
          '/wellness/detail': (_) => const ArticleDetailScreen(),
          '/insights/chart': (_) => const ChartScreen(),
          '/fertility/window': (_) => const FertilityScreen(),
          '/pregnancy/dashboard': (_) => const GestationScreen(),
          '/profile/settings': (_) => const SettingsScreen(),
          '/profile/reminders': (_) => const RemindersScreen(),
          // Legacy aliases (one release)
          '/': (_) => const SplashScreen(),
          '/join': (_) => const JoinScreen(),
          '/rhythms': (_) => const RhythmsScreen(),
          '/shell': (_) => const MainShell(),
          '/log': (_) => const MainShell(initialIndex: 2),
          '/blood': (_) => const BloodScreen(),
          '/gestation': (_) => const GestationScreen(),
          '/coven': (_) => const CovenScreen(),
          '/library': (_) => const LibraryScreen(),
          '/reminders': (_) => const RemindersScreen(),
          '/binding': (_) => const BindingScreen(),
        },
      ),
    );
  }
}
