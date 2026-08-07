import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../features/auth/auth_provider.dart';
import '../features/auth/auth_screen.dart';
import '../features/auth/models/auth_session.dart';
import '../features/calendar/calendar_screen.dart';
import '../features/content/content_library_screen.dart';
import '../features/couples/couples_screen.dart';
import '../features/home/home_screen.dart';
import '../features/insights/insights_screen.dart';
import '../features/logging/logging_screen.dart';
import '../features/reminders/reminders_screen.dart';
import '../features/settings/settings_screen.dart';
import '../l10n/app_localizations.dart';
import '../utils/app_theme.dart';

/// The primary app shell with a floating pill bottom navigation.
///
/// An [IndexedStack] preserves each tab's state across switches. The active
/// tab's title is shown centered in the app bar. The trailing account button
/// opens the right-side drawer with account, library and settings actions.
class MainShellScreen extends StatefulWidget {
  const MainShellScreen({super.key});

  @override
  State<MainShellScreen> createState() => _MainShellScreenState();
}

class _MainShellScreenState extends State<MainShellScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  int _index = 0;

  late final List<Widget> _tabs = <Widget>[
    const HomeScreen(),
    const CalendarScreen(),
    LoggingScreen(onOpenCalendar: () => setState(() => _index = 1)),
    const InsightsScreen(),
  ];

  void _openSettings(BuildContext context) {
    Navigator.of(
      context,
    ).push(MaterialPageRoute<void>(builder: (_) => const SettingsScreen()));
  }

  void _openContentLibrary(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder:
            (_) => Scaffold(
              appBar: AppBar(title: Text(l10n.navMagic)),
              body: const ContentLibraryScreen(),
            ),
      ),
    );
  }

  String _titleFor(AppLocalizations l10n) {
    return switch (_index) {
      0 => l10n.navHome,
      1 => l10n.navCalendar,
      2 => l10n.navLogging,
      _ => l10n.navInsights,
    };
  }

  @override
  Widget build(BuildContext context) {
    final AppLocalizations l10n = AppLocalizations.of(context);
    return Scaffold(
      key: _scaffoldKey,
      extendBody: true,
      appBar: AppBar(
        automaticallyImplyLeading: false,
        actions: <Widget>[Container()],
        centerTitle: true,
        title: Text(_titleFor(l10n)),
      ),
      body: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          IndexedStack(index: _index, children: _tabs),
          _navConainer(l10n),
        ],
      ),
      endDrawer: _endDrawer(context, l10n),
    );
  }

  Widget _endDrawer(BuildContext context, AppLocalizations l10n) {
    final AuthProvider auth = context.watch<AuthProvider>();
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _accountHeader(context, l10n, auth),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.auto_fix_high_outlined),
              title: Text(l10n.navMagic),
              onTap: () {
                Navigator.of(context).pop();
                _openContentLibrary(context);
              },
            ),
            ListTile(
              leading: const Icon(Icons.alarm_add_outlined),
              title: Text(l10n.settingsRemindersTitle),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const RemindersScreen(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.favorite_outline),
              title: Text(l10n.settingsCouplesTitle),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => const CouplesScreen(),
                  ),
                );
              },
            ),
            const Spacer(),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.settings_outlined),
              title: Text(l10n.navSettings),
              onTap: () {
                Navigator.of(context).pop();
                _openSettings(context);
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _accountHeader(
    BuildContext context,
    AppLocalizations l10n,
    AuthProvider auth,
  ) {
    final AuthSession? session = auth.session;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    if (session != null) {
      return Container(
        color: scheme.primaryContainer,
        padding: const EdgeInsets.all(AppSpacing.kMd),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: scheme.primary,
              foregroundColor: scheme.onPrimary,
              child: Text(
                session.displayName.isEmpty
                    ? '?'
                    : session.displayName.substring(0, 1).toUpperCase(),
              ),
            ),
            const SizedBox(width: AppSpacing.kMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    session.displayName,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  if (session.email case final String email)
                    Text(email, style: Theme.of(context).textTheme.bodySmall),
                ],
              ),
            ),
          ],
        ),
      );
    }
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.kMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.account_circle_outlined, size: 48, color: scheme.primary),
          const SizedBox(height: AppSpacing.kSm),
          Text(
            l10n.settingsAccountTitle,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: AppSpacing.kXs),
          Text(
            l10n.settingsAccountSubtitle,
            style: Theme.of(context).textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.kSm),
          FilledButton.tonal(
            onPressed: () {
              Navigator.of(context).pop();
              Navigator.of(context).push(
                MaterialPageRoute<void>(builder: (_) => const AuthScreen()),
              );
            },
            child: Text(l10n.authGoogleSignIn),
          ),
        ],
      ),
    );
  }

  Widget _navConainer(AppLocalizations l10n) {
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(
        bottom: AppSpacing.kMd,
        left: AppSpacing.kMd,
        right: AppSpacing.kMd,
      ),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: scheme.onPrimaryContainer,
          borderRadius: BorderRadius.circular(AppSpacing.kRadiusXl),
          boxShadow: [
            BoxShadow(color: scheme.primary, blurRadius: AppSpacing.kRadiusSm),
          ],
          border: Border.all(color: scheme.onPrimary.withAlpha(140), width: 1),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.kXs),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _navButton(
                index: 0,
                unselectedIcon: FontAwesomeIcons.moon,
                selectedIcon: FontAwesomeIcons.moon,
                tooltip: l10n.navHome,
              ),
              _navButton(
                index: 1,
                unselectedIcon: Icons.calendar_month_outlined,
                selectedIcon: Icons.calendar_month,
                tooltip: l10n.navCalendar,
              ),
              _navButton(
                index: 2,
                unselectedIcon: Icons.add_outlined,
                selectedIcon: Icons.add,
                tooltip: l10n.navLogging,
                iconsScale: 1.4,
              ),
              _navButton(
                index: 3,
                unselectedIcon: Icons.insights_outlined,
                selectedIcon: Icons.insights,
                tooltip: l10n.navInsights,
              ),
              _navButton(
                index: 4,
                unselectedIcon: Icons.account_circle_outlined,
                selectedIcon: Icons.account_circle,
                tooltip: l10n.navAccount,
                onTap: () => _scaffoldKey.currentState?.openEndDrawer(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _navButton({
    required int index,
    required IconData unselectedIcon,
    IconData? selectedIcon,
    double iconsScale = 1.0,
    double shiftY = 0.0,
    required String tooltip,
    VoidCallback? onTap,
  }) {
    final bool selected = onTap == null && _index == index;
    final ColorScheme scheme = Theme.of(context).colorScheme;
    return Expanded(
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: onTap ?? () => setState(() => _index = index),
          borderRadius: BorderRadius.circular(32),
          child: Container(
            width: AppSizing.kXl8 * iconsScale,
            height: AppSizing.kXl8 * iconsScale,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
            ), //  border: shiftY != 0.0 ? Border.all(color: Colors.white) : null),
            alignment: Alignment.center,
            transformAlignment: AlignmentDirectional.center,
            transform: Matrix4.translationValues(0, shiftY, 0),
            child: Icon(
              selected ? (selectedIcon ?? unselectedIcon) : unselectedIcon,
              size: selected ? iconsScale * 30 : iconsScale * 22,
              color: selected ? scheme.secondary : scheme.onPrimary,
            ),
          ),
        ),
      ),
    );
  }
}
