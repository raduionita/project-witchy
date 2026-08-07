import 'package:flutter/material.dart';

import '../features/calendar/calendar_screen.dart';
import '../features/content/content_library_screen.dart';
import '../features/home/home_screen.dart';
import '../features/insights/insights_screen.dart';
import '../features/logging/logging_screen.dart';
import '../features/settings/settings_screen.dart';
import '../l10n/app_localizations.dart';
import '../utils/app_theme.dart';

/// The primary app shell with a floating pill bottom navigation.
///
/// An [IndexedStack] preserves each tab's state across switches. The active
/// tab's title is shown centered in the app bar.
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
    const ContentLibraryScreen(),
  ];

  void _openSettings(BuildContext context) {
    Navigator.of(context).push(MaterialPageRoute<void>(builder: (_) => const SettingsScreen()));
  }

  String _titleFor(AppLocalizations l10n) {
    return switch (_index) {
      0 => l10n.navHome,
      1 => l10n.navCalendar,
      2 => l10n.navLogging,
      3 => l10n.navInsights,
      _ => l10n.navMagic,
    };
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        centerTitle: true,
        title: Text(_titleFor(l10n)),
        actions: <Widget>[IconButton(icon: const Icon(Icons.settings_outlined), tooltip: l10n.navSettings, onPressed: () => _openSettings(context))],
      ),
      body: IndexedStack(index: _index, children: _tabs),
      bottomNavigationBar: _navConainer(l10n),
    );
  }

  Widget _navConainer(AppLocalizations l10n) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.kMd, left: AppSpacing.kMd, right: AppSpacing.kMd),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.onPrimaryContainer,
          borderRadius: BorderRadius.circular(AppSpacing.kRadiusXl),
          boxShadow: [BoxShadow(color: scheme.primary, blurRadius: AppSpacing.kRadiusSm)],
          border: Border.all(color: scheme.onPrimary.withAlpha(140), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.kXs),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _navButton(index: 0, unselectedIcon: Icons.home_outlined, selectedIcon: Icons.home, tooltip: l10n.navHome),
              _navButton(index: 1, unselectedIcon: Icons.calendar_month_outlined, selectedIcon: Icons.calendar_month, tooltip: l10n.navCalendar),
              _navButton(index: 2, unselectedIcon: Icons.add_outlined, selectedIcon: Icons.add, tooltip: l10n.navLogging, iconsScale: 1.4),
              _navButton(index: 3, unselectedIcon: Icons.insights_outlined, selectedIcon: Icons.insights, tooltip: l10n.navInsights),
              _navButton(index: 4, unselectedIcon: Icons.auto_fix_high_outlined, selectedIcon: Icons.auto_fix_high, tooltip: l10n.navMagic),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navButton({required int index, required IconData unselectedIcon, IconData? selectedIcon, double iconsScale = 1.0, double shiftY = 0.0, required String tooltip}) {
    final bool selected = _index == index;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: () => setState(() => _index = index),
          borderRadius: BorderRadius.circular(32),
          child: Container(
            width: AppSizing.kXl8 * iconsScale,
            height: AppSizing.kXl8 * iconsScale,
            decoration: BoxDecoration(shape: BoxShape.circle), //  border: shiftY != 0.0 ? Border.all(color: Colors.white) : null),
            alignment: Alignment.center,
            transformAlignment: AlignmentDirectional.center,
            transform: Matrix4.translationValues(0, shiftY, 0),
            child: Icon(selected ? (selectedIcon ?? unselectedIcon) : unselectedIcon, size: selected ? iconsScale * 30 : iconsScale * 22, color: selected ? scheme.secondary : scheme.onPrimary),
          ),
        ),
      ),
    );
  }
}
