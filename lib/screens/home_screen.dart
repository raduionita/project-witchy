// Home screen - main navigation hub for Witchy app

import 'package:flutter/material.dart';
import '../screens/tracking_screen.dart';
import '../screens/calendar_screen.dart';
import '../screens/pregnancy_screen.dart';
import '../screens/settings_screen.dart';
import '../utils/constants.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Theme.of(context).colorScheme.surface,
        child: Column(
          children: [
            _buildHeroSection(context),
            const Expanded(child: SizedBox()), // Spacer for bottom nav
          ],
        ),
      ),
      bottomNavigationBar: _buildBottomNavigation(context),
    );
  }

  Widget _buildHeroSection(BuildContext context) {
    const heroText = 'Witchy';
    const heroSubtitle = 'Your Period & Fertility Companion';

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(heroText, style: Theme.of(context).textTheme.headlineLarge?.copyWith(color: AppColors.primary)),
          const SizedBox(height: 8),
          Text(heroSubtitle, style: Theme.of(context).textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary)),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation(BuildContext context) {
    const options = [
      BottomNavItem(Icon(Icons.circle, size: 24), 'Cycle', TrackingScreen()),
      BottomNavItem(Icon(Icons.calendar_month, size: 24), 'Calendar', CalendarScreen()),
      BottomNavItem(Icon(Icons.pregnancy, size: 24), 'Pregnancy', PregnancyScreen()),
      BottomNavItem(Icon(Icons.settings, size: 24), 'Settings', SettingsScreen()),
    ];

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      selectedItem: 0,
      elevation: 4,
      selectedColor: AppColors.primary,
      unselectedColor: AppColors.textSecondary,
      selectedItemStyle: const SelectedItemStyle(overlayColor: Colors.transparent),
      elevation: 4,
      elevation: 0,
      items: options.map((item) => BottomNavigationBarItem(
        icon: Icon(item.icon),
        label: item.label,
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => item.page)),
      )).toList(),
    );
  }

  class BottomNavItem {
    final Icon icon;
    final String label;
    final Widget page;

    BottomNavItem({required this.icon, required this.label, required this.page});
  }

}
