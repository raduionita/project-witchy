import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'providers/cycle_provider.dart';
import 'providers/settings_provider.dart';
import 'providers/symptoms_provider.dart';
import 'screens/home_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/profile_screen.dart';
import 'models/period_cycle.dart';
import 'models/user_settings.dart';
import 'utils/theme_colors.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();

  Hive.registerAdapter(PeriodCycleAdapter());
  Hive.registerAdapter(SymptomAdapter());
  Hive.registerAdapter(MoodEntryAdapter());
  Hive.registerAdapter(MoodAdapter());
  Hive.registerAdapter(DischargePatternAdapter());
  Hive.registerAdapter(UserSettingsAdapter());

  runApp(const WitchyApp());
}

class WitchyApp extends StatelessWidget {
  const WitchyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CycleProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()..initialize()),
        ChangeNotifierProvider(create: (_) => SymptomsProvider()),
      ],
      child: MaterialApp(
        title: 'Witchy',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: WitchyColors.primary,
            brightness: Brightness.light,
          ),
          useMaterial3: true,
          scaffoldBackgroundColor: WitchyColors.backgroundColor,
          appBarTheme: const AppBarTheme(
            elevation: 0,
            centerTitle: false,
          ),
          cardTheme: CardTheme(
            elevation: 1,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          floatingActionButtonTheme: const FloatingActionButtonThemeData(),
        ),
        home: const WitchyHomePage(),
        routes: {
          '/profile': (context) => const ProfileScreen(),
          '/calendar': (context) => const CalendarScreen(),
        },
      ),
    );
  }
}

class WitchyHomePage extends StatefulWidget {
  const WitchyHomePage({super.key});

  @override
  State<WitchyHomePage> createState() => _WitchyHomePageState();
}

class _WitchyHomePageState extends State<WitchyHomePage> {
  int _currentIndex = 0;

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = const [
      HomeScreen(),
      CalendarScreen(),
      PlaceholderScreen(title: 'Pregnancy Tracker', icon: Icons.child_care),
      PlaceholderScreen(title: 'Health Assistant', icon: Icons.chat_bubble),
      ProfileScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        selectedItemColor: WitchyColors.primary,
        unselectedItemColor: WitchyColors.lightText,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today_outlined),
            activeIcon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.child_care_outlined),
            activeIcon: Icon(Icons.child_care),
            label: 'Pregnancy',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            activeIcon: Icon(Icons.chat_bubble),
            label: 'Assistant',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }
}

class PlaceholderScreen extends StatelessWidget {
  final String title;
  final IconData icon;

  const PlaceholderScreen({
    super.key,
    required this.title,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: WitchyColors.lightText),
          const SizedBox(height: 16),
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text(
            'Coming soon',
            style: TextStyle(color: WitchyColors.lightText),
          ),
        ],
      ),
    );
  }
}
