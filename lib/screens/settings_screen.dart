import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../providers/app_providers.dart';
import '../theme/app_text_styles.dart';
import '../widgets/witchy_widgets.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsProvider>();
    return Scaffold(
      appBar: WitchyAppBar(
        title: 'Settings',
        leading: Icons.arrow_back,
        onLeading: () {
          if (Navigator.canPop(context)) {
            Navigator.pop(context);
          } else {
            Navigator.pushNamed(context, '/profile');
          }
        },
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
        children: [
          WitchyCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Lunar Alignments', style: AppText.secIn),
                SettingsRow(label: 'Receive Lunar Notifications', trailing: Switch(value: s.lunarNotifications, activeColor: const Color(0xFF7B2CBF), onChanged: (v) => context.read<SettingsProvider>().setLunar(v)), first: true),
                SettingsRow(label: 'Dark Magic Mode', trailing: Switch(value: s.darkMode, activeColor: const Color(0xFF7B2CBF), onChanged: (v) => context.read<SettingsProvider>().setDark(v))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
