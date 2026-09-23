import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'primary_screens.dart';
import 'secondary_screens.dart';
import '../theme/app_colors.dart';
import '../utils/witchy_icons.dart';
import '../widgets/log_bottom_sheet.dart';
import '../widgets/witchy_widgets.dart';

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
    return Scaffold(
      appBar: WitchyAppBar(
        title: titles[index],
        leading: WitchyIcons.user,
        onLeading: () => Navigator.pushNamed(context, '/profile'),
        action: WitchyIcons.bell,
        onAction: () {
          final name = ModalRoute.of(context)?.settings.name;
          if (name != '/alerts') Navigator.pushNamed(context, '/alerts');
        },
      ),
      body: IndexedStack(index: index, children: const [SanctuaryScreen(), CycleMapScreen(), RecordsScreen(), CovenScreen()]),
      floatingActionButton:
          index == 3
              ? null
              : FloatingActionButton(
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
                  decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppColors.plumGradient, boxShadow: [AppColors.primaryShadow]),
                  child: const FaIcon(WitchyIcons.quill, size: WitchyIconSize.base, color: AppColors.gold),
                ),
              ),
      bottomNavigationBar: WitchyBottomNav(index: index, onTap: (i) => setState(() => index = i)),
    );
  }
}
