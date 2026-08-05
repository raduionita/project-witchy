/// App root widget for Witchy.
/// Configures MaterialApp with theme, routes, and bottom navigation.
library;

import 'package:flutter/material.dart';
import '../core/theme/app_theme.dart';
import 'screens/calendar_screen.dart';
import 'screens/home_screen.dart';
import 'screens/settings_screen.dart';

/// MaterialApp root with bottom navigation and theme.
class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Witchy',
      themeMode: ThemeMode.system,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      routes: {
        '/calendar': (context) => const CalendarScreen(),
      },
      home: const _AppShell(),
    );
  }
}

/// Application shell with bottom navigation bar.
class _AppShell extends StatefulWidget {
  const _AppShell();

  @override
  State<_AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<_AppShell> {
  int _currentIndex = 0;

  // Tab screens — lazy-initialized.
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
