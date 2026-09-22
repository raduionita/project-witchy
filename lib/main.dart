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
          // app start [initialRoute]
          '/': (_) => const SplashScreen(),
          // Splash -> footer row -> [always] -> "Sign In" link
          '/auth': (_) => const JoinScreen(),
          // Splash -> foot -> [always] -> "Awaken Your Power" btn; Join -> form -> [mock signIn resolves] -> "Cast Invitation Scroll" btn
          '/onboarding': (_) => const RhythmsScreen(),
          // Rhythms -> [prefs saved] -> "Bind Magic Link" btn (stack cleared); shell -> bottom nav -> [always] -> Today tab; pushed screens -> appbar -> [pop impossible] -> back fallback
          '/dashboard': (_) => const MainScreen(initialIndex: 0),
          // shell -> bottom nav -> [always] -> Calendar tab
          '/calendar': (_) => const MainScreen(initialIndex: 1),
          // shell -> bottom nav -> [always] -> Insights tab
          '/insights': (_) => const MainScreen(initialIndex: 2),
          // shell -> bottom nav -> [always] -> Magic tab
          '/coven': (_) => const MainScreen(initialIndex: 3),
          // shell (all tabs) -> app bar -> [always] -> avatar btn
          '/profile': (_) => const ProfileScreen(),
          // Profile -> app bar -> [always] -> gear btn; Profile -> Lunar Alignments card -> [always] -> "Manage" link; Profile -> Apothecary Settings card -> [always] -> "Manage" link
          '/settings': (_) => const SettingsScreen(),
          // shell (all tabs) -> app bar -> [current route != /alerts] -> bell btn
          '/alerts': (_) => const AlertsScreen(),
          // Profile -> Amulet Bells card -> [always] -> "Open Amulet Reminders" btn
          '/reminders': (_) => const RemindersScreen(),
          // Sanctuary -> Log Today's Magic -> [always] -> Flow tile
          '/cycle': (_) => const BloodScreen(),
          // Sanctuary -> stat duo -> [always] -> Peak Today card
          '/fertility': (_) => const FertilityScreen(),
          // Sanctuary -> Daily Astral Insight card -> [always] -> card tap
          '/library': (_) => const LibraryScreen(),
          // Profile -> Apothecary Settings card -> [always] -> "View" link
          '/pregnancy': (_) => const GestationScreen(),
          // Records -> Stardust Cycle Trends card -> [always] -> card tap; CycleMap -> calendar card -> [always] -> month header tap
          '/chart': (_) => const ChartScreen(),
          // Profile -> Apothecary Settings card -> [always] -> "1 Active" link
          '/binding': (_) => const BindingScreen(),
        },
        onGenerateRoute: (settings) {
          // Library -> article card -> [slug matches articleById] -> card tap => /library/<slug>; [unknown slug] -> LibraryScreen fallback
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
