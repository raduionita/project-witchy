import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/cycle_provider.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/cycle_orb.dart';
import '../widgets/stat_card.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/app_card.dart';

class FertilityScreen extends StatelessWidget {
  const FertilityScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final cycle = context.watch<CycleProvider>();
    final now = DateTime.now();
    final cycleDay = cycle.cycleDay(today: now);
    final ovuToday = cycle.ovulationToday;
    final fertileNow = cycle.fertileToday;
    final daysToOvu = cycle.daysUntilOvulation(today: now);
    final ovuCycleDay = cycle.ovulationCycleDay;
    final windowStart = cycle.fertileStartCycleDay;
    final windowEnd = cycle.fertileEndCycleDay;
    final windowDays = windowEnd - windowStart + 1;
    final ovuDate = cycle.ovulationDay(today: now);

    final chanceValue = ovuToday
        ? 'Peak Today'
        : fertileNow
        ? 'Window Open'
        : 'In $daysToOvu Days';
    final chanceSub = ovuToday
        ? 'Ovulation likely'
        : fertileNow
        ? 'Ovulation nears'
        : '${DateFormat('MMM d').format(ovuDate)} · predicted';
    final tips = ovuToday
        ? 'The fertile crescent peaks today. Track cervical fluid and LH surge alongside temperature for the clearest conception signal.'
        : 'The fertile window opens on cycle day $windowStart. Track cervical fluid and LH surge alongside temperature for the clearest conception signal.';

    return Scaffold(
      appBar: const AppTopBar(title: 'Fertility Window'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
        children: [
          const SizedBox(height: 8),
          CycleOrb(day: '$cycleDay', phase: ovuToday ? 'Peak Day' : 'Peak in $daysToOvu d'),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: StatCard(label: 'Conception chance', value: chanceValue, sub: chanceSub, valueColor: AppColors.pink)),
              const SizedBox(width: 12),
              Expanded(child: StatCard(label: 'Window', value: '$windowDays Days', sub: 'Day $windowStart – Day $windowEnd')),
            ],
          ),
          const SizedBox(height: 12),
          AppCard(
            dark: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('TTC Tips', style: AppText.serif(13.5, c: Colors.white)),
                const SizedBox(height: 8),
                Text(tips, style: AppText.sans(11.5, c: AppColors.insightText, h: 1.55)),
              ],
            ),
          ),
          if (!ovuToday && !fertileNow) ...[
            const SizedBox(height: 12),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Next Peak', style: AppText.secIn),
                  const SizedBox(height: 8),
                  Text(
                    'Ovulation is predicted for cycle day $ovuCycleDay (${DateFormat('MMMM d').format(ovuDate)}), $daysToOvu days from now.',
                    style: AppText.sans(11.5, c: AppColors.chipText, h: 1.55),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
