import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../navigation/app_nav.dart';
import '../providers/cycle_provider.dart';
import '../providers/settings_provider.dart';
import '../services/notification_service.dart';
import '../theme/app_text_styles.dart';
import '../widgets/settings_row.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/app_card.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<SettingsProvider>();
    return Scaffold(
      appBar: AppTopBar(
        title: 'Settings',
        onLeading: () => context.backOr('/profile'),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
        children: [
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Lunar Alignments', style: AppText.secIn),
                SettingsRow(
                  label: 'Receive Lunar Notifications',
                  trailing: Switch(
                    value: s.lunarNotifications,
                    activeThumbColor: const Color(0xFF7B2CBF),
                    onChanged: (v) {
                      context.read<SettingsProvider>().setLunar(v);
                      final cycle = context.read<CycleProvider>();
                      NotificationService.syncPeriodPrediction(
                        enabled: v,
                        predictedStart: cycle.nextPeriodStart(),
                      );
                    },
                  ),
                  first: true,
                ),
                SettingsRow(label: 'Dark Magic Mode', trailing: Switch(value: s.darkMode, activeThumbColor: const Color(0xFF7B2CBF), onChanged: (v) => context.read<SettingsProvider>().setDark(v))),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
