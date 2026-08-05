/// Main entry point for Witchy.
/// Initializes storage, sets up Provider scope, and runs the app.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_constants.dart';
import 'providers/app_provider.dart';
import 'providers/tracking_provider.dart';
import 'screens/home_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/settings_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/storage_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize storage service.
  final storageService = await StorageService().init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AppProvider>(
          create: (_) => AppProvider(storageService: storageService)..init(),
        ),
        ChangeNotifierProvider<TrackingProvider>(
          create: (context) => TrackingProvider(
            appProvider: context.read<AppProvider>(),
          )..init(),
        ),
      ],
      child: const WitchyApp(),
    ),
  );
}

/// The root Witchy application widget.
class WitchyApp extends StatelessWidget {
  const WitchyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: kAppTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF6A1B9A),
      ),
      home: const _OnboardingGate(),
    );
  }
}

/// Gate widget that checks if onboarding is complete and routes accordingly.
class _OnboardingGate extends StatefulWidget {
  const _OnboardingGate();

  @override
  State<_OnboardingGate> createState() => _OnboardingGateState();
}

class _OnboardingGateState extends State<_OnboardingGate> {
  late final Future<bool> _hasCompletedFuture;

  @override
  void initState() {
    super.initState();
    _hasCompletedFuture = _checkOnboarding();
  }

  static Future<bool> _checkOnboarding() async {
    final storageService = await StorageService().init();
    return storageService.isOnboardingComplete();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _hasCompletedFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final hasCompleted = snapshot.data == true;

        if (hasCompleted) {
          return const _MainApp();
        }

        // Show onboarding screen.
        return const OnboardingScreen();
      },
    );
  }
}

/// Main application when onboarding is complete.
class _MainApp extends StatelessWidget {
  const _MainApp();

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: kAppTitle,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: const Color(0xFF6A1B9A),
      ),
      home: const _AppShell(),
    );
  }
}

/// Application shell with bottom navigation.
class _AppShell extends StatefulWidget {
  const _AppShell();

  @override
  State<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<_AppShell> {
  int _currentIndex = 0;

  late final List<Widget> _tabs = [
    const HomeScreen(),
    const CalendarScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _tabs,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_today),
            label: 'Calendar',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}
