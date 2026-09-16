import 'package:flutter/material.dart';

import '../features/calendar/calendar_screen.dart';
import '../features/home/home_screen.dart';
import '../features/insights/insights_screen.dart';
import '../features/logging/logging_screen.dart';
import '../features/reminders/alerts_screen.dart';
import '../features/settings/settings_screen.dart';
import '../l10n/app_localizations.dart';
import '../utils/app_theme.dart';
import '../widgets/app_content_column.dart';

class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  int _index = 0;

  late final List<Widget> _tabs = <Widget>[const HomeScreen(), const CalendarScreen(), LoggingScreen(onOpenCalendar: () => setState(() => _index = 1)), const InsightsScreen(), const SettingsScreen()];

  String _titleFor(AppLocalizations l10n) {
    return switch (_index) {
      0 => l10n.homeToday,
      1 => l10n.navCalendar,
      2 => l10n.navLogging,
      3 => l10n.navInsights,
      _ => l10n.navSettings,
    };
  }

  Widget _barItem({required IconData icon, required IconData activeIcon, required String label, required bool selected, required VoidCallback onTap}) {
    final Color color = selected ? AppColors.kPurple : const Color(0xFFA795B8);
    return Expanded(
      child: Semantics(
        button: true,
        selected: selected,
        label: label,
        child: InkWell(
          onTap: onTap,
          child: ConstrainedBox(
            constraints: const BoxConstraints(minHeight: AppSizing.kMinTouch),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  clipBehavior: Clip.none,
                  children: [
                    Icon(selected ? activeIcon : icon, size: 20, color: color),
                    if (selected)
                      Positioned(
                        bottom: -6,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Container(width: 18, height: 2.5, decoration: BoxDecoration(color: AppColors.kPurple, borderRadius: BorderRadius.circular(2))),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(label, style: TextStyle(fontSize: 9.5, fontWeight: FontWeight.w500, color: color)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _bottomBar(AppLocalizations l10n) {
    return SafeArea(
      top: false,
      child: Container(
        height: 78,
        padding: const EdgeInsets.only(top: 10),
        decoration: const BoxDecoration(color: Colors.white, border: Border(top: BorderSide(color: AppColors.kLine))),
        child: Row(
          children: [
            _barItem(icon: Icons.nights_stay_outlined, activeIcon: Icons.nights_stay, label: l10n.navHome, selected: _index == 0, onTap: () => setState(() => _index = 0)),
            _barItem(icon: Icons.calendar_today_outlined, activeIcon: Icons.calendar_month, label: l10n.navCalendar, selected: _index == 1, onTap: () => setState(() => _index = 1)),
            _barItem(icon: Icons.edit_outlined, activeIcon: Icons.edit, label: l10n.navLogging, selected: _index == 2, onTap: () => setState(() => _index = 2)),
            _barItem(icon: Icons.bar_chart_outlined, activeIcon: Icons.bar_chart, label: l10n.navInsights, selected: _index == 3, onTap: () => setState(() => _index = 3)),
            _barItem(icon: Icons.auto_awesome_outlined, activeIcon: Icons.auto_awesome, label: l10n.navAccount, selected: _index == 4, onTap: () => setState(() => _index = 4)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: _index == 4 ? null : AppBar(automaticallyImplyLeading: false, centerTitle: true, title: Text(_titleFor(l10n)), actions: _index == 0 ? [IconButton(tooltip: 'Alerts', icon: const Icon(Icons.notifications_none_outlined), onPressed: () => Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const AlertsScreen())))] : null),
      body: AppContentColumn(child: IndexedStack(index: _index, children: _tabs)),
      bottomNavigationBar: _bottomBar(l10n),
    );
  }
}
