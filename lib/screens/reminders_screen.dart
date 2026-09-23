import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/app_providers.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/witchy_icons.dart';
import '../widgets/witchy_widgets.dart';

class RemindersScreen extends StatelessWidget {
  const RemindersScreen({super.key});
  @override
  Widget build(BuildContext context) {
    final rp = context.watch<RemindersProvider>();
    final active = rp.items.where((r) => r.enabled).length;
    return Scaffold(
      appBar: const WitchyAppBar(title: 'Amulet Reminders'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
        children: [
          Text('Calibrate mystical bells to warn you of upcoming tides.', style: AppText.sub),
          const SizedBox(height: 4),
          Text('$active of ${rp.items.length} bells active', style: AppText.sans(11, w: FontWeight.w600, c: AppColors.pur)),
          const SizedBox(height: 12),
          for (var i = 0; i < rp.items.length; i++) ...[
            WitchyCard(
              child: Column(
                children: [
                  Row(
                    children: [
                      IconBadge(icon: rp.items[i].icon, bg: rp.items[i].badgeBg, fg: rp.items[i].badgeFg),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [Text(rp.items[i].title, style: AppText.serif(12.5)), Text(rp.items[i].subtitle, style: AppText.sans(9.5, c: AppColors.muted))],
                        ),
                      ),
                      Switch(value: rp.items[i].enabled, activeColor: AppColors.pur, onChanged: (v) => context.read<RemindersProvider>().toggle(i, v)),
                    ],
                  ),
                  if (rp.items[i].enabled) ...[
                    const SizedBox(height: 11),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [InfoPill(icon: WitchyIcons.clock, label: rp.items[i].time), InfoPill(icon: WitchyIcons.spark, label: rp.items[i].freq)],
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
          ],
        ],
      ),
    );
  }
}
