import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../common/date_format.dart';
import '../models/cycle_goal.dart';
import '../models/fertility_status.dart';
import '../providers/cycle_provider.dart';
import '../providers/settings_provider.dart';
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

  /// Placeholder while a dated pregnancy suppresses predictions; the route
  /// stays reachable so deep links and the Today card never break.
  Widget _buildPausedCard(BuildContext context) {
    return AppCard(
      dark: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Predictions paused', style: AppText.serif(13.5, c: Colors.white)),
          const SizedBox(height: 8),
          Text(
            'Pregnancy tracking is active, so fertility predictions are paused. They resume automatically once pregnancy mode is off.',
            style: AppText.sans(11.5, c: AppColors.insightText, h: 1.55),
          ),
          const SizedBox(height: 12),
          AppButton(label: 'Open Pregnancy Tracker', onTap: () => context.go('/pregnancy')),
        ],
      ),
    );
  }

  /// Orb caption: names this cycle's peak, including when it has already passed.
  static String _orbPhase(FertilityStatus status, int daysToOvu) => switch (status) {
        FertilityStatus.peakToday => 'Peak Day',
        FertilityStatus.windowOpen || FertilityStatus.beforeWindow => 'Peak in $daysToOvu Days',
        FertilityStatus.windowClosing || FertilityStatus.passed => 'Peak passed',
      };

  /// Chances read like Flo's low / high / peak scale rather than a status.
  static String _chanceValue(FertilityStatus status) => switch (status) {
        FertilityStatus.peakToday => 'Peak',
        FertilityStatus.windowOpen => 'High',
        FertilityStatus.windowClosing => 'Medium',
        FertilityStatus.passed || FertilityStatus.beforeWindow => 'Low',
      };

  static String _tipsTitle(CycleGoal goal) => switch (goal) {
        CycleGoal.conceive => 'TTC Tips',
        CycleGoal.avoid => 'Fertility notes',
        CycleGoal.track => 'Cycle notes',
      };

  /// Copy depends on where today sits in the cycle and on the stated goal:
  /// `avoid` never reads as conception advice, and always repeats the caveat.
  static String _tipsFor(CycleGoal goal, FertilityStatus status, int windowStart, String peakLabel) {
    switch (goal) {
      case CycleGoal.conceive:
        return switch (status) {
          FertilityStatus.peakToday => 'Your fertile window peaks today. Track cervical fluid and LH surge alongside temperature for the clearest conception signal.',
          FertilityStatus.windowOpen => 'Your fertile window is open. Cervical fluid and LH surge add confidence to the temperature signal.',
          FertilityStatus.windowClosing => 'Ovulation ($peakLabel) has passed, so today is the last fertile day of this cycle.',
          FertilityStatus.passed => "This cycle's fertile window has closed. The next one opens around cycle day $windowStart.",
          FertilityStatus.beforeWindow => 'The fertile window opens on cycle day $windowStart. Track cervical fluid and LH surge alongside temperature for the clearest conception signal.',
        };
      case CycleGoal.avoid:
        return switch (status) {
          FertilityStatus.peakToday => 'Today is the estimated peak of your fertile window, so conception is more likely right now.',
          FertilityStatus.windowOpen => 'You are inside the estimated fertile window, so conception is more likely this week.',
          FertilityStatus.windowClosing => 'The estimated peak has passed; the chance of conception drops quickly from tomorrow.',
          FertilityStatus.passed => 'Estimated chance of conception is low until the next fertile window.',
          FertilityStatus.beforeWindow => 'Estimated chance of conception is low until the fertile window opens on cycle day $windowStart.',
        };
      case CycleGoal.track:
        return switch (status) {
          FertilityStatus.peakToday => 'Estimated ovulation today - the midpoint of your fertile window.',
          FertilityStatus.windowOpen => 'Your estimated fertile window is open.',
          FertilityStatus.windowClosing => 'Estimated ovulation was yesterday, so the window is closing.',
          FertilityStatus.passed => "This cycle's estimated peak has passed. The next window opens around cycle day $windowStart.",
          FertilityStatus.beforeWindow => 'Your estimated fertile window opens on cycle day $windowStart.',
        };
    }
  }

  @override
  Widget build(BuildContext context) {
    final cycle = context.watch<CycleProvider>();
    final goal = context.watch<SettingsProvider>().goal;
    if (cycle.pregnancyActive) {
      return Scaffold(
        appBar: const AppTopBar(title: 'Fertility Window'),
        body: ListView(padding: const EdgeInsets.fromLTRB(16, 6, 16, 14), children: [const SizedBox(height: 8), _buildPausedCard(context)]),
      );
    }
    final now = DateTime.now();
    final cycleDay = cycle.cycleDay(today: now);
    final status = cycle.fertilityStatus(today: now);
    final daysToOvu = cycle.daysUntilOvulation(today: now);
    final peakLabel = AppDate.short(cycle.ovulationDateThisCycle(today: now));
    final nextPeakLabel = AppDate.short(cycle.nextOvulationDate(today: now));
    final windowOpensLabel = AppDate.short(cycle.ovulationDateThisCycle(today: now).subtract(const Duration(days: 5)));
    final ovuCycleDay = cycle.ovulationCycleDay;
    final windowStart = cycle.fertileStartCycleDay;
    final windowEnd = cycle.fertileEndCycleDay;
    final windowDays = windowEnd - windowStart + 1;
    final pad = cycle.uncertaintyPad;
    final chanceValue = _chanceValue(status);
    final chanceSub = switch (status) {
      FertilityStatus.peakToday => 'Ovulation today ($peakLabel)',
      FertilityStatus.windowOpen => 'Ovulation $peakLabel',
      FertilityStatus.windowClosing => 'Ovulation was $peakLabel',
      FertilityStatus.passed => 'Peak was $peakLabel · next $nextPeakLabel',
      FertilityStatus.beforeWindow => 'Peak $peakLabel',
    };
    final tips = _tipsFor(goal, status, windowStart, peakLabel);
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
            bleedLength: cycle.meanBleedLength?.round() ?? cycle.bleedLength,
            fertileStartDay: windowStart,
            fertileEndDay: windowEnd,
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(child: StatCard(label: 'Conception chance', value: chanceValue, sub: chanceSub, valueColor: AppColors.pink)),
              const SizedBox(width: 12),
              Expanded(child: StatCard(label: 'Window', value: '$windowDays Days', sub: 'Day $windowStart – Day $windowEnd')),
            ],
          ),
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
                Text(_tipsTitle(goal), style: AppText.serif(13.5, c: Colors.white)),
                const SizedBox(height: 8),
                Text(tips, style: AppText.sans(11.5, c: AppColors.insightText, h: 1.55)),
                if (goal == CycleGoal.avoid) ...[
                  const SizedBox(height: 8),
                  Text(
                    'Predictions are estimates only and are not a contraceptive method - use protection if you do not want to conceive.',
                    style: AppText.sans(10, c: AppColors.insightText, h: 1.5),
                  ),
                ],
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
