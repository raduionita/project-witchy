import 'package:flutter/material.dart';
import '../screens/primary_screens.dart';
import '../widgets/witchy_widgets.dart';

class MainShell extends StatefulWidget {
  const MainShell({super.key});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int index = 0;
  static const titles = ['Sanctuary', 'Lunar Cycle Map', 'Apothecary Log', 'Lunar Records', 'Witch Profile'];
  static const actions = [Icons.auto_awesome, Icons.tune, Icons.check, Icons.auto_awesome, Icons.settings_outlined];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WitchyAppBar(
        title: titles[index],
        action: actions[index],
        onAction: index == 0 ? () => Navigator.pushNamed(context, '/alerts') : null,
      ),
      body: IndexedStack(
        index: index,
        children: const [SanctuaryScreen(), CycleMapScreen(), LogScreen(), RecordsScreen(), ProfileScreen()],
      ),
      bottomNavigationBar: WitchyBottomNav(index: index, onTap: (i) => setState(() => index = i)),
    );
  }
}
