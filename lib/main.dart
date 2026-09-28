import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'models/mock_data.dart';
import 'providers/auth_provider.dart';
import 'providers/logging_provider.dart';
import 'providers/onboarding_provider.dart';
import 'providers/reminders_provider.dart';
import 'providers/settings_provider.dart';
import 'screens/alerts_screen.dart';
import 'screens/article_detail_screen.dart';
import 'screens/binding_screen.dart';
import 'screens/blood_screen.dart';
import 'screens/chart_screen.dart';
import 'screens/fertility_screen.dart';
import 'screens/gestation_screen.dart';
import 'screens/join_screen.dart';
import 'screens/library_screen.dart';
import 'screens/main_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/reminders_screen.dart';
import 'screens/rhythms_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/splash_screen.dart';
import 'services/prefs_service.dart';
import 'theme/app_theme.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = PrefsService();
  final auth = await AuthProvider.load(prefs);
  final onboarding = await OnboardingProvider.load(prefs);
  final logging = await LoggingProvider.load(prefs);
  final settings = await SettingsProvider.load(prefs);
  final reminders = await RemindersProvider.load(prefs);
  runApp(App(auth: auth, onboarding: onboarding, logging: logging, settings: settings, reminders: reminders));
}

class App extends StatelessWidget {
  const App({
    super.key,
    required this.auth,
    required this.onboarding,
    required this.logging,
    required this.settings,
    required this.reminders,
  });

  final AuthProvider auth;
  final OnboardingProvider onboarding;
  final LoggingProvider logging;
  final SettingsProvider settings;
  final RemindersProvider reminders;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: auth),
        ChangeNotifierProvider.value(value: onboarding),
        ChangeNotifierProvider.value(value: logging),
        ChangeNotifierProvider.value(value: settings),
        ChangeNotifierProvider.value(value: reminders),
      ],
      child: MaterialApp(
        title: 'Witchy',
        theme: buildAppTheme(),
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
