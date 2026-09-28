import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/app_icons.dart';
import '../widgets/log_bottom_sheet.dart';
import '../widgets/quick_action.dart';
import '../widgets/stat_card.dart';
import '../widgets/app_card.dart';
import '../widgets/app_tag.dart';
import '../widgets/cycle_orb.dart';

class SanctuaryScreen extends StatelessWidget {
  const SanctuaryScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
      children: [
        const SizedBox(height: 8),
        const CycleOrb(),
        const SizedBox(height: 12),
        Row(children: [const Expanded(child: StatCard(label: 'Bleeding In', value: '14 Days', sub: 'Nov 10 · predicted')), const SizedBox(width: 12), Expanded(child: _FertilityPeakCard())]),
        const SizedBox(height: 12),
        Text("Log Today's Magic", style: AppText.sec),
        const SizedBox(height: 8),
        Row(
          children: [
            Expanded(child: QuickAction(icon: AppIcons.drop, label: 'Flow', onTap: () => Navigator.pushNamed(context, '/cycle'))),
            const SizedBox(width: 10),
            Expanded(child: QuickAction(icon: AppIcons.heart, label: 'Mood', onTap: () => showLogSheet(context, DateTime.now()))),
            const SizedBox(width: 10),
            Expanded(child: QuickAction(icon: AppIcons.pulse, label: 'Pain', onTap: () => showLogSheet(context, DateTime.now()))),
            const SizedBox(width: 10),
            Expanded(child: QuickAction(icon: AppIcons.note, label: 'Notes', onTap: () => showLogSheet(context, DateTime.now()))),
          ],
        ),
        const SizedBox(height: 12),
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, '/library'),
          child: AppCard(
            dark: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(children: [Text('Daily Astral Insight', style: AppText.serif(13.5, c: Colors.white)), const Spacer(), AppTag.gold('Scorpio Moon')]),
                const SizedBox(height: 8),
                Text(
                  'As your body summits this cycle peak, intuitive energies run deep. Ground your power with Mugwort tea, and honor your physical fatigue.',
                  style: AppText.sans(11.5, c: AppColors.insightText, h: 1.55),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _FertilityPeakCard extends StatelessWidget {
  const _FertilityPeakCard();
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, '/fertility'),
      child: const StatCard(label: 'Fertility Window', value: 'Peak Today', sub: 'High chance', valueColor: AppColors.pink),
    );
  }
}
