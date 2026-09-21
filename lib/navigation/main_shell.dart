import 'package:flutter/material.dart';
import '../screens/primary_screens.dart';
import '../screens/secondary_screens.dart';
import '../widgets/witchy_widgets.dart';

class MainShell extends StatefulWidget {
  final int initialIndex;
  const MainShell({super.key, this.initialIndex = 0});
  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  late int index = widget.initialIndex;
  static const titles = ['Sanctuary', 'Lunar Cycle Map', 'Apothecary Log', 'Lunar Records', 'Coven Sanctum'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: WitchyAppBar(
        title: titles[index],
        leading: Icons.person_outline,
        onLeading: () => Navigator.pushNamed(context, '/profile'),
        action: Icons.notifications_outlined,
        onAction: () {
          final name = ModalRoute.of(context)?.settings.name;
          if (name != '/alerts') Navigator.pushNamed(context, '/alerts');
        },
      ),
      body: IndexedStack(
        index: index,
        children: const [SanctuaryScreen(), CycleMapScreen(), LogScreen(), RecordsScreen(), CovenScreen()],
      ),
      bottomNavigationBar: WitchyBottomNav(index: index, onTap: (i) => setState(() => index = i)),
    );
  }
}
