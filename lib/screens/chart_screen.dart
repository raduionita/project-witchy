import 'package:flutter/material.dart';

import '../theme/app_text_styles.dart';
import '../widgets/cycle_widgets.dart';
import '../widgets/witchy_widgets.dart';

class ChartScreen extends StatelessWidget {
  const ChartScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const WitchyAppBar(title: 'BBT Chart'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
        children: [
          WitchyCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [Text('Biphasic Temperature Shift', style: AppText.secIn), const SizedBox(height: 10), const TrendBars()],
            ),
          ),
          const Row(children: [
            Expanded(child: StatCard(label: '', value: '36.4°', sub: 'Pre-shift average')),
            SizedBox(width: 12),
            Expanded(child: StatCard(label: '', value: '+0.4°', sub: 'Post-shift rise')),
          ]),
          WitchyCard(
            dark: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('How to read this', style: AppText.serif(13.5, c: Colors.white)),
                const SizedBox(height: 8),
                Text('A sustained rise across three mornings confirms ovulation. Log your waking temperature daily for a clear biphasic pattern.',
                    style: AppText.sans(11.5, c: const Color(0xFFE9D9F5), h: 1.55)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
