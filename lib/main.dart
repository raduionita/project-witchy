import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'services/storage_service.dart';
import 'services/cycle_service.dart';
import 'services/notification_service.dart';
import 'providers/user_provider.dart';
import 'providers/period_provider.dart';
import 'providers/fertility_provider.dart';
import 'providers/pregnancy_provider.dart';
import 'providers/notification_provider.dart';
import 'screens/onboarding_screen.dart';
import 'screens/home_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/log_period_screen.dart';
import 'screens/symptom_log_screen.dart';
import 'screens/mood_log_screen.dart';
import 'screens/pregnancy_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/insights_screen.dart';
import 'screens/partner_screen.dart';
import 'screens/content_screen.dart';
import 'screens/anonymity_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  final storageService = StorageService();
  final cycleService = CycleService();
  final notificationService = NotificationService();

  runApp(
    WitchyApp(
      storageService: storageService,
      cycleService: cycleService,
      notificationService: notificationService,
    ),
  );
}

class WitchyApp extends StatelessWidget {
  final StorageService storageService;
  final CycleService cycleService;
  final NotificationService notificationService;

  const WitchyApp({
    super.key,
    required this.storageService,
    required this.cycleService,
    required this.notificationService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => UserProvider(storageService),
        ),
        ChangeNotifierProvider(
          create: (_) => PeriodProvider(storageService),
        ),
        ChangeNotifierProvider(
          create: (_) => FertilityProvider(storageService, cycleService),
        ),
        ChangeNotifierProvider(
          create: (_) => PregnancyProvider(storageService, cycleService),
        ),
        ChangeNotifierProvider(
          create: (_) => NotificationProvider(storageService, notificationService),
        ),
      ],
      child: MaterialApp(
        title: 'Witchy',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF9C27B0),
            primary: const Color(0xFF9C27B0),
            secondary: const Color(0xFFE91E63),
          ),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            centerTitle: false,
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const RootScreen(),
          '/home': (context) => const MainNavigationScreen(),
          '/log-period': (context) => const LogPeriodScreen(),
          '/log-symptom': (context) => const SymptomLogScreen(),
          '/log-mood': (context) => const MoodLogScreen(),
        },
      ),
    );
  }
}

class RootScreen extends StatelessWidget {
  const RootScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<UserProvider>(
      builder: (context, userProvider, _) {
        if (userProvider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (!userProvider.isOnboardingCompleted) {
          return const OnboardingScreen();
        }

        return const MainNavigationScreen();
      },
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const HomeScreen(),
    const CalendarScreen(),
    const InsightsScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home_outlined),
            selectedIcon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_month_outlined),
            selectedIcon: Icon(Icons.calendar_month),
            label: 'Calendar',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Insights',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings_outlined),
            selectedIcon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF9C27B0),
        onPressed: () {
          showModalBottomSheet(
            context: context,
            builder: (context) => SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _BottomSheetItem(
                    icon: Icons.add_circle,
                    label: 'Log Period',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).pushNamed('/log-period');
                    },
                  ),
                  _BottomSheetItem(
                    icon: Icons.heart_broken,
                    label: 'Log Symptom',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).pushNamed('/log-symptom');
                    },
                  ),
                  _BottomSheetItem(
                    icon: Icons.favorite,
                    label: 'Log Mood',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).pushNamed('/log-mood');
                    },
                  ),
                  _BottomSheetItem(
                    icon: Icons.pregnant_woman,
                    label: 'Pregnancy',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const PregnancyScreen(),
                      ));
                    },
                  ),
                  _BottomSheetItem(
                    icon: Icons.people,
                    label: 'For Couples',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const PartnerScreen(),
                      ));
                    },
                  ),
                  _BottomSheetItem(
                    icon: Icons.library_books,
                    label: 'Health Library',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const ContentScreen(),
                      ));
                    },
                  ),
                  _BottomSheetItem(
                    icon: Icons.shield,
                    label: 'Privacy',
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.of(context).push(MaterialPageRoute(
                        builder: (context) => const AnonymityScreen(),
                      ));
                    },
                  ),
                ],
              ),
            ),
          );
        },
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}

class _BottomSheetItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _BottomSheetItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Row(
          children: [
            Icon(icon, color: const Color(0xFF9C27B0)),
            const SizedBox(width: 16),
            Text(
              label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}