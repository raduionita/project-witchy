import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import '../providers/cycle_provider.dart';
import '../providers/logging_provider.dart';
import '../services/cycle_calculator.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_icons.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/app_card.dart';
import '../widgets/app_chip.dart';
import '../widgets/app_slider_row.dart';

class BloodScreen extends StatelessWidget {
  const BloodScreen({super.key});
  static const volumes = ['Spotting', 'Light', 'Medium', 'Heavy'];
  @override
  Widget build(BuildContext context) {
    final log = context.watch<LoggingProvider>();
    final cycle = context.watch<CycleProvider>();
    final today = DateTime.now();
    final entry = log.peekDay(today);
    final bleedDay = CycleCalculator.bleedDay(cycle.effectiveLastStart, today, cycle.effectiveCycleLength, cycle.bleedLength);
    final shedding = bleedDay > 0;
    return Scaffold(
      appBar: const AppTopBar(title: 'Sovereign Blood'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
        children: [
          AppCard(
            dark: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(shedding ? 'SHEDDING PHASE' : 'RESTING PHASE', style: AppText.sans(9, w: FontWeight.w700, c: AppColors.gold).copyWith(letterSpacing: 1.2)),
                const SizedBox(height: 6),
                Text(shedding ? 'Day $bleedDay of ${cycle.bleedLength}' : 'Awaiting the next tide', style: AppText.serif(23, c: Colors.white)),
                const SizedBox(height: 8),
                if (shedding)
                  Row(
                    children: [
                      for (var i = 0; i < bleedDay; i++) ...[
                        if (i > 0) const SizedBox(width: 5),
                        const FaIcon(AppIcons.drop, size: AppIconSize.sm, color: AppColors.gold),
                      ],
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
                Text('Bleeding Volume', style: AppText.secIn),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [for (final v in volumes) AppChip(label: v, selected: entry?.flow == v, onTap: () => context.read<LoggingProvider>().setFlow(DateTime.now(), v))],
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            child: AppSliderRow(
              label: 'Uterine Contraction Pain',
              value: 'Level ${(entry?.pain ?? 6).round()}',
              min: 0,
              max: 10,
              current: entry?.pain ?? 6,
              onChanged: (v) => context.read<LoggingProvider>().setPain(DateTime.now(), v),
            ),
          ),
          const SizedBox(height: 12),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Grimoire Scribbles', style: AppText.secIn),
                const SizedBox(height: 8),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(color: AppColors.fieldBg, borderRadius: BorderRadius.circular(12), border: Border.all(color: AppColors.line)),
                  child: Text(
                    entry?.notes ?? 'The grimoire awaits your first scribble…',
                    style: AppText.sans(11.5, c: entry?.notes == null || entry!.notes.isEmpty ? AppColors.placeholder : AppColors.chipText, h: 1.55),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
