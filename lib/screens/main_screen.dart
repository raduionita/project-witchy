import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../navigation/app_nav.dart';
import '../providers/alert_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_icons.dart';
import '../widgets/log_bottom_sheet.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/app_bottom_nav.dart';
import 'coven_screen.dart';
import 'cycle_screen.dart';
import 'records_screen.dart';
import 'sanctuary_screen.dart';

class MainScreen extends StatefulWidget {
  final int initialIndex;
  const MainScreen({super.key, this.initialIndex = 0});
  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  late int index = widget.initialIndex;
  static const titles = ['Sanctuary', 'Lunar Cycle Map', 'Lunar Records', 'Coven Sanctum'];

  @override
  Widget build(BuildContext context) {
    final unread = context.watch<AlertProvider>().unreadCount > 0;
    return Scaffold(
      appBar: AppTopBar(title: titles[index], leading: AppIcons.user, onLeading: () => context.go('/profile'), action: AppIcons.alerts, onAction: () => context.go('/alerts'), badge: unread),
      body: IndexedStack(index: index, children: const [SanctuaryScreen(), CycleScreen(), RecordsScreen(), CovenScreen()]),
      floatingActionButton:
          index == 3
              ? null
              : FloatingActionButton(
                heroTag: 'main_log_fab',
                onPressed: () => showLogSheet(context, DateTime.now()),
                backgroundColor: Colors.transparent,
                hoverColor: AppColors.plum2,
                focusElevation: 0,
                hoverElevation: 0,
                highlightElevation: 0,
                elevation: 0,
                child: Container(
                  width: 50,
                  height: 50,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppColors.plumGradient, border: Border.fromBorderSide(BorderSide(color: AppColors.gold, width: 1.5)), boxShadow: [AppColors.primaryShadow]),
                  child: const FaIcon(AppIcons.quill, size: AppIconSize.base, color: AppColors.gold),
                ),
              ),
      bottomNavigationBar: AppBottomNav(index: index, onTap: (i) => setState(() => index = i)),
    );
  }
}
