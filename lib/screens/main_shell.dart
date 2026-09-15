import 'package:flutter/material.dart';

import '../features/calendar/calendar_screen.dart';
import '../features/home/home_screen.dart';
import '../features/insights/insights_screen.dart';
import '../features/logging/logging_screen.dart';
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

  late final List<Widget> _tabs = <Widget>[
    const HomeScreen(),
    const CalendarScreen(),
    LoggingScreen(onOpenCalendar: () => setState(() => _index = 1)),
    const InsightsScreen(),
    const SettingsScreen(),
  ];

  String _titleFor(AppLocalizations l10n) {
    return switch (_index) {
      0 => l10n.homeToday,
      1 => l10n.navCalendar,
      2 => l10n.navLogging,
      3 => l10n.navInsights,
      _ => l10n.navSettings,
    };
  }

  Widget _centerLogButton(AppLocalizations l10n) {
    final bool selected = _index == 2;
    return Semantics(
      button: true,
      selected: selected,
      label: l10n.navLogging,
      child: InkWell(
        onTap: () => setState(() => _index = 2),
        customBorder: const CircleBorder(),
        child: Container(
          width: 56,
          height: 56,
          decoration: BoxDecoration(
            color: AppColors.kPrimary,
            shape: BoxShape.circle,
            boxShadow: AppShadows.kHero,
            border: selected ? Border.all(color: AppColors.kCoral, width: 3) : null,
          ),
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  Widget _barItem({required IconData icon, required String label, required bool selected, required VoidCallback onTap}) {
    final Color color = selected ? AppColors.kPrimary : AppColors.kTextSecondary;
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
                Icon(icon, size: 24, color: color),
                const SizedBox(height: 2),
                Text(label, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: AppTypography.kNavLabel, color: color)),
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
        height: AppSizing.kNavHeight,
        padding: const EdgeInsets.only(bottom: 8),
        decoration: const BoxDecoration(color: AppColors.kSurfaceBase, border: Border(top: BorderSide(color: AppColors.kBorder))),
        child: Row(
          children: [
            _barItem(icon: _index == 0 ? Icons.home : Icons.home_outlined, label: l10n.navHome, selected: _index == 0, onTap: () => setState(() => _index = 0)),
            _barItem(icon: _index == 1 ? Icons.calendar_month : Icons.calendar_month_outlined, label: l10n.navCalendar, selected: _index == 1, onTap: () => setState(() => _index = 1)),
            Expanded(child: Center(child: _centerLogButton(l10n))),
            _barItem(icon: _index == 3 ? Icons.bar_chart : Icons.bar_chart_outlined, label: l10n.navInsights, selected: _index == 3, onTap: () => setState(() => _index = 3)),
            _barItem(icon: _index == 4 ? Icons.person : Icons.person_outline, label: l10n.navAccount, selected: _index == 4, onTap: () => setState(() => _index = 4)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Scaffold(
      appBar: _index == 4 ? null : AppBar(automaticallyImplyLeading: false, centerTitle: true, title: Text(_titleFor(l10n))),
      body: AppContentColumn(child: IndexedStack(index: _index, children: _tabs)),
      bottomNavigationBar: _bottomBar(l10n),
    );
  }
}
