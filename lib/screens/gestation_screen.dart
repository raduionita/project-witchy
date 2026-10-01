import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_icons.dart';
import '../widgets/icon_badge.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/app_card.dart';
import '../widgets/app_tag.dart';

class GestationScreen extends StatelessWidget {
  const GestationScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppTopBar(title: 'Gestation Spells', action: AppIcons.heart),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
        children: [
          AppCard(
            dark: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('GESTATION SANCTUARY', style: AppText.sans(9, w: FontWeight.w700, c: AppColors.gold).copyWith(letterSpacing: 1.2)),
                const SizedBox(height: 6),
                Text('Week 12 (Day 4)', style: AppText.serif(21, c: Colors.white)),
                const SizedBox(height: 10),
                ClipRRect(
                  borderRadius: BorderRadius.circular(3),
                  child: LinearProgressIndicator(value: 0.30, minHeight: 6, backgroundColor: Colors.white.withValues(alpha: .22), valueColor: const AlwaysStoppedAnimation(AppColors.gold)),
                ),
                const SizedBox(height: 8),
                Text('196 days until arrival portal opens', style: AppText.sans(10.5, c: AppColors.orbSub)),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [Text('Spiritual Comparison', style: AppText.serif(12.5)), AppTag('Lime Size')]),
                const SizedBox(height: 10),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const IconBadge(icon: AppIcons.search),
                    const SizedBox(width: 10),
                    Expanded(child: Text('Your little spirit matches a ripe Lime. Organs are fully formed and commencing magical function.', style: AppText.sans(11.5, h: 1.55))),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Astral Gestation Tips', style: AppText.secIn),
                const SizedBox(height: 6),
                Text(
                  'First-trimester tiredness is shifting. Elevate your iron levels with organic spinach potions and continue speaking soft, loving mantras to your belly.',
                  style: AppText.sans(11.5, h: 1.55),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
