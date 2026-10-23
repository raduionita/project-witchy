import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../common/date_format.dart';
import '../models/fertility_status.dart';
import '../providers/cycle_provider.dart';
import '../navigation/app_nav.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../widgets/app_button.dart';
import '../widgets/cycle_orb.dart';
import '../widgets/disclaimer_text.dart';
import '../widgets/stat_card.dart';
import '../widgets/app_top_bar.dart';
import '../widgets/app_card.dart';

class FertilityScreen extends StatelessWidget {
  const FertilityScreen({super.key});

  /// Placeholder while pregnancy or a suppressing condition keeps fertility
  /// predictions off. The route stays reachable so deep links and the Today
  /// card never break.
  Widget _buildPausedCard(BuildContext context, CycleProvider cycle) {
    final pregnancy = cycle.pregnancyActive;
    final message = pregnancy
        ? 'Pregnancy tracking is active, so fertility predictions are paused. They resume automatically once pregnancy mode is off.'
        : 'A cycle condition is active, so fertility predictions are paused. Use Cycle Conditions in Profile when this changes.';
    return AppCard(
      dark: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Predictions paused', style: AppText.serif(13.5, c: Colors.white)),
          const SizedBox(height: 8),
          Text(message, style: AppText.sans(11.5, c: AppColors.insightText, h: 1.55)),
          const SizedBox(height: 12),
          AppButton(
            label: pregnancy ? 'Open Pregnancy Tracker' : 'Open Profile',
            onTap: () => context.go(pregnancy ? '/pregnancy' : '/profile'),
          ),
        ],
      ),
    );
  }

  /// Shown when the cycle runs past its latest plausible due date. Fertility
  /// predictions stay paused until a new period re-anchors the cycle.
  Widget _buildOverdueCard(BuildContext context) {
    return AppCard(
      dark: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Predictions paused', style: AppText.serif(13.5, c: Colors.white)),
          const SizedBox(height: 8),
          Text(
            'This cycle is running longer than your recent range. Fertility predictions stay paused until you log your next period. If pregnancy is possible, consider a test.',
            style: AppText.sans(11.5, c: AppColors.insightText, h: 1.55),
          ),
          const SizedBox(height: 12),
          AppButton(label: 'Log your period', onTap: () => context.go('/bleed-history')),
        ],
      ),
    );
  }

  /// Orb caption: names this cycle's peak, including when it has already passed.
  static String _orbPhase(FertilityStatus status, int daysToOvu) => switch (status) {
        FertilityStatus.peakToday => 'Peak Day',
        FertilityStatus.windowOpen || FertilityStatus.beforeWindow => 'Peak in $daysToOvu Days',
        FertilityStatus.windowClosing || FertilityStatus.passed => 'Peak passed',
        FertilityStatus.overdue => 'Predictions paused',
      };

  /// Chances read like Flo's low / high / peak scale rather than a status.
  static String _chanceValue(FertilityStatus status) => switch (status) {
        FertilityStatus.peakToday => 'Peak',
        FertilityStatus.windowOpen => 'High',
        FertilityStatus.windowClosing => 'Medium',
        FertilityStatus.passed || FertilityStatus.beforeWindow => 'Low',
        FertilityStatus.overdue => 'Paused',
      };

  static const String _tipsTitle = 'Cycle notes';

  /// Neutral copy that describes the estimate without assuming a goal.
  static String _tipsFor(FertilityStatus status, int windowStart) {
    return switch (status) {
      FertilityStatus.peakToday => 'Estimated ovulation today - the midpoint of your fertile window.',
      FertilityStatus.windowOpen => 'Your estimated fertile window is open.',
      FertilityStatus.windowClosing => 'Estimated ovulation was yesterday, so the window is closing.',
      FertilityStatus.passed => "This cycle's estimated peak has passed. The next window opens around cycle day $windowStart.",
      FertilityStatus.beforeWindow => 'Your estimated fertile window opens on cycle day $windowStart.',
      FertilityStatus.overdue => 'Fertility predictions are paused while this cycle runs long. Log your next period to restart them.',
    };
  }

  @override
  Widget build(BuildContext context) {
    final cycle = context.watch<CycleProvider>();
    if (cycle.pregnancyActive) {
      return Scaffold(
        appBar: const AppTopBar(title: 'Fertility Window'),
        body: ListView(padding: const EdgeInsets.fromLTRB(16, 6, 16, 14), children: [const SizedBox(height: 8), _buildPausedCard(context, cycle)]),
      );
    }
    if (cycle.conditionPausesFertility) {
      return Scaffold(
        appBar: const AppTopBar(title: 'Fertility Window'),
        body: ListView(padding: const EdgeInsets.fromLTRB(16, 6, 16, 14), children: [const SizedBox(height: 8), _buildPausedCard(context, cycle)]),
      );
    }
    final now = DateTime.now();
    if (cycle.showFertilityPredictions && !cycle.predictionsConfident(today: now)) {
      return Scaffold(
        appBar: const AppTopBar(title: 'Fertility Window'),
        body: ListView(padding: const EdgeInsets.fromLTRB(16, 6, 16, 14), children: [const SizedBox(height: 8), _buildOverdueCard(context)]),
      );
    }
    final cycleDay = cycle.elapsedCycleDay(today: now);
    final status = cycle.fertilityStatus(today: now);
    final daysToOvu = cycle.daysUntilOvulation(today: now);
    final window = cycle.fertileWindow(today: now);
    final peakLabel = AppDate.short(window?.peak ?? cycle.ovulationDateThisCycle(today: now));
    final nextPeakLabel = AppDate.short(cycle.nextOvulationDate(today: now));
    final windowOpensLabel = AppDate.short(window?.start ?? cycle.ovulationDateThisCycle(today: now).subtract(const Duration(days: 5)));
    final ovuCycleDay = cycle.ovulationCycleDay;
    final windowStart = cycle.fertileStartCycleDay;
    final windowEnd = cycle.fertileEndCycleDay;
    final windowDays = window?.length ?? (windowEnd - windowStart + 1);
    final pad = cycle.fertileWindowPad;
    final chanceValue = _chanceValue(status);
    final chanceSub = switch (status) {
      FertilityStatus.peakToday => 'Ovulation today ($peakLabel)',
      FertilityStatus.windowOpen => 'Ovulation $peakLabel',
      FertilityStatus.windowClosing => 'Ovulation was $peakLabel',
      FertilityStatus.passed => 'Peak was $peakLabel · next $nextPeakLabel',
      FertilityStatus.beforeWindow => 'Peak $peakLabel',
      FertilityStatus.overdue => 'Log your next period to restart',
    };
    final tips = _tipsFor(status, windowStart);
    final peakPassed = status == FertilityStatus.windowClosing || status == FertilityStatus.passed;

    return Scaffold(
      appBar: const AppTopBar(title: 'Fertility Window'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
        children: [
          const SizedBox(height: 8),
          CycleOrb(
            day: '$cycleDay',
            phase: _orbPhase(status, daysToOvu),
            progress: cycleDay / cycle.effectiveCycleLength,
            cycleLength: cycle.effectiveCycleLength,
            bleedLength: cycle.bleedLength,
            fertileStartDay: windowStart,
            fertileEndDay: windowEnd,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: StatCard(
                  label: 'Fertility',
                  value: chanceValue,
                  sub: chanceSub,
                  valueColor: AppColors.pink,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(child: StatCard(label: 'Window', value: '$windowDays Days', sub: 'Day $windowStart – Day $windowEnd')),
            ],
          ),
          const SizedBox(height: 6),
          Text(cycle.predictionBasis, style: AppText.sans(9.5, c: AppColors.muted)),
          if (pad > 0) ...[
            const SizedBox(height: 8),
            Text('Timing is estimated and may shift by up to $pad ${pad == 1 ? 'day' : 'days'}.', style: AppText.sans(10, c: AppColors.muted)),
          ],
          const SizedBox(height: 12),
          AppCard(
            dark: true,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(_tipsTitle, style: AppText.serif(13.5, c: Colors.white)),
                const SizedBox(height: 8),
                Text(tips, style: AppText.sans(11.5, c: AppColors.insightText, h: 1.55)),
              ],
            ),
          ),
          if (peakPassed || status == FertilityStatus.beforeWindow) ...[
            const SizedBox(height: 12),
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Next Peak', style: AppText.secIn),
                  const SizedBox(height: 8),
                  Text(
                    status == FertilityStatus.beforeWindow
                        ? 'Ovulation is predicted for cycle day $ovuCycleDay ($peakLabel), $daysToOvu days from now. The window opens $windowOpensLabel.'
                        : 'This cycle\'s peak was $peakLabel (cycle day $ovuCycleDay). Next peak $nextPeakLabel, $daysToOvu days away.',
                    style: AppText.sans(11.5, c: AppColors.chipText, h: 1.55),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          const DisclaimerText(),
        ],
      ),
    );
  }
}
