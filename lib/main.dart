import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'models/witchy_models.dart';
import 'providers/app_providers.dart';
import 'screens/article_detail_screen.dart';
import 'screens/auth_screens.dart';
import 'screens/chart_screen.dart';
import 'screens/fertility_screen.dart';
import 'screens/main_screen.dart';
import 'screens/primary_screens.dart';
import 'screens/reminders_screen.dart';
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
        ChangeNotifierProvider(create: (_) => LoggingProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
        ChangeNotifierProvider(create: (_) => RemindersProvider()),
      ],
      child: MaterialApp(
        title: 'Witchy',
        theme: buildWitchyTheme(),
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        routes: {
          '/' : (_) => const SplashScreen(), // Reach: app start (initialRoute)
          '/auth': (_) => const JoinScreen(), // Reach: splash "Sign In"
          '/onboarding': (_) => const RhythmsScreen(), // Reach: splash CTA, join mock sign-in
          '/dashboard': (_) => const MainScreen(initialIndex: 0), // Reach: onboarding/login; bottom nav Today; back-fallback
          '/calendar': (_) => const MainScreen(initialIndex: 1), // Reach: bottom nav Calendar
          '/insights': (_) => const MainScreen(initialIndex: 2), // Reach: bottom nav Insights
          '/coven': (_) => const MainScreen(initialIndex: 3), // Reach: bottom nav Magic
          '/profile': (_) => const ProfileScreen(), // Reach: shell avatar (all tabs)
          '/settings': (_) => const SettingsScreen(), // Reach: shell → avatar → gear / Manage links
          '/alerts': (_) => const AlertsScreen(), // Reach: shell bell
          '/reminders': (_) => const RemindersScreen(), // Reach: shell → avatar → Amulet Bells card button
          '/cycle': (_) => const BloodScreen(), // Reach: Sanctuary Flow QA
          '/fertility': (_) => const FertilityScreen(), // Reach: Sanctuary Peak card
          '/library': (_) => const LibraryScreen(), // Reach: Sanctuary insight card
          '/pregnancy': (_) => const GestationScreen(), // Reach: shell → avatar → Gestation Spells row
          '/insights/chart': (_) => const ChartScreen(), // Reach: Records trends card; CycleMap card
          '/binding': (_) => const BindingScreen(), // Reach: shell → avatar → "1 Active"
        },
        onGenerateRoute: (settings) {
          // Reach: library article tap → /library/<slug>
          final uri = Uri.parse(settings.name ?? '');
          if (uri.pathSegments.length == 2 && uri.pathSegments.first == 'library') {
            final article = MockData.articleById(uri.pathSegments[1]);
            if (article != null) return MaterialPageRoute(builder: (_) => ArticleDetailScreen(article: article), settings: settings);
            return MaterialPageRoute(builder: (_) => const LibraryScreen(), settings: settings);
          }
          return null;
        },
      ),
    );
  }
}
