import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/cycle_widgets.dart';
import '../widgets/witchy_widgets.dart';

class FertilityScreen extends StatelessWidget {
  const FertilityScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const WitchyAppBar(title: 'Fertility Window'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
        children: [
          const SizedBox(height: 8),
          const CycleOrb(day: '14', phase: 'Peak Day'),
          const SizedBox(height: 12),
          const Row(children: [
            Expanded(child: StatCard(label: 'Conception chance', value: 'Peak Today', sub: 'Ovulation likely', valueColor: AppColors.pink)),
            SizedBox(width: 12),
            Expanded(child: StatCard(label: 'Window', value: '5 Days', sub: 'Day 12 – Day 16')),
          ]),
          const SizedBox(height: 12),
          WitchyCard(
            dark: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('TTC Tips', style: AppText.serif(13.5, c: Colors.white)),
                const SizedBox(height: 8),
                Text('The fertile crescent peaks today. Track cervical fluid and LH surge alongside temperature for the clearest conception signal.',
                    style: AppText.sans(11.5, c: AppColors.insightText, h: 1.55)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
