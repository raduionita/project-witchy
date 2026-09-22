import 'package:flutter/material.dart';
import 'primary_screens.dart';
import 'secondary_screens.dart';
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
        children: const [SanctuaryScreen(), CycleMapScreen(), RecordsScreen(), CovenScreen()],
      ),
      bottomNavigationBar: WitchyBottomNav(index: index, onTap: (i) => setState(() => index = i)),
    );
  }
}
