import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../providers/cycle_provider.dart';
import '../../utils/app_theme.dart';
import '../../utils/date_utils.dart';
import '../../widgets/app_card.dart';

/// Celestial Alerts: derived inbox (period forecast, fertility peak, log nudge).
class AlertsScreen extends StatelessWidget {
  const AlertsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final CycleProvider cycle = context.watch<CycleProvider>();
    final prediction = cycle.prediction;
    final List<({IconData icon, Color bg, Color fg, String title, String time, String body})> items = <({IconData icon, Color bg, Color fg, String title, String time, String body})>[];
    if (prediction != null) {
      final int days = daysBetween(DateTime.now(), prediction.nextPeriodStart);
      items.add((icon: Icons.water_drop_outlined, bg: const Color(0xFFFCE7EF), fg: AppColors.kPink, title: 'Period Commencing', time: '2 hours ago', body: 'Your bleeding phase is predicted to begin in $days days. Prepare your herbal tea blends.'));
      final bool fertileNow = prediction.fertileWindow.contains(DateTime.now());
      items.add((icon: Icons.nights_stay_outlined, bg: const Color(0xFFF8EED9), fg: AppColors.kGold, title: 'Fertility Window Peak', time: '1 day ago', body: fertileNow ? 'Your cosmic fertility peaks today under the fertile crescent. High chance of ovulation.' : 'Your fertile window opens soon. Align your intentions.'));
    }
    items.add((icon: Icons.edit_outlined, bg: AppColors.kLav, fg: AppColors.kPurple, title: 'Magical Log Missing', time: '2 days ago', body: 'Remember to log your somatic echoes, cramps and emotional currents for today.'));
    items.add((icon: Icons.star_outline, bg: AppColors.kLav, fg: AppColors.kPurple, title: 'Astrological Milestone', time: '3 days ago', body: 'Full Moon summits soon. Perfect alignment for meditative reflection.'));
    return Scaffold(
      backgroundColor: AppColors.kCanvas,
      appBar: AppBar(title: const Text('Celestial Alerts'), backgroundColor: AppColors.kCanvas),
      body: ListView.separated(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 24),
        itemCount: items.length + 1,
        separatorBuilder: (_, __) => const SizedBox(height: 12),
        itemBuilder: (BuildContext context, int index) {
          if (index == 0) return const Text('The cosmos whispers its reminders. Align your biological temple.', style: TextStyle(fontSize: 11.5, color: AppColors.kMuted, height: 1.5));
          final item = items[index - 1];
          return AppCard(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(width: 34, height: 34, decoration: BoxDecoration(color: item.bg, shape: BoxShape.circle), alignment: Alignment.center, child: Icon(item.icon, size: 14, color: item.fg)),
                const SizedBox(width: 11),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [Expanded(child: Text(item.title, style: const TextStyle(fontFamily: AppTypography.kDisplayFont, fontSize: 12.5, fontWeight: FontWeight.w700))), Text(item.time, style: const TextStyle(fontSize: 9, color: AppColors.kMuted))],
                      ),
                      const SizedBox(height: 4),
                      Text(item.body, style: const TextStyle(fontSize: 11, height: 1.55, color: AppColors.kBody)),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
