import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../common/date_format.dart';
import '../common/log_data.dart';
import '../common/log_summary.dart';
import '../models/cycle_phase.dart';
import '../models/fertility_status.dart';
import '../navigation/app_nav.dart';
import '../providers/cycle_provider.dart';
import '../providers/logging_provider.dart';
import '../services/cycle_calculator.dart';
import '../theme/app_colors.dart';
import '../theme/app_dims.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_icons.dart';
import '../widgets/log_bottom_sheet.dart';
import '../widgets/quick_action.dart';
import '../widgets/stat_card.dart';
import '../widgets/app_card.dart';
import '../widgets/app_tag.dart';
import '../widgets/cycle_orb.dart';
import '../widgets/disclaimer_text.dart';
import '../widgets/icon_badge.dart';

class TodayScreen extends StatelessWidget {
  const TodayScreen({super.key});

  static const _glyphPeriod = 'assets/svgs/moon-period.svg';
  static const _glyphPeriodPredicted = 'assets/svgs/moon-period-predicted.svg';
  static const _glyphFertile = 'assets/svgs/moon-fertile.svg';
  static const _glyphOvulation = 'assets/svgs/moon-ovulation.svg';
  static const _glyphWaxing = 'assets/svgs/moon-waxing.svg';
  static const _glyphWaning = 'assets/svgs/moon-waning.svg';

  String _glyph(CyclePhase phase, {required bool predictedPeriod}) {
    switch (phase) {
      case CyclePhase.menstrual:
        return predictedPeriod ? _glyphPeriodPredicted : _glyphPeriod;
      case CyclePhase.ovulatory:
        return _glyphOvulation;
      case CyclePhase.fertile:
        return _glyphFertile;
      case CyclePhase.follicular:
        return _glyphWaxing;
      case CyclePhase.luteal:
        return _glyphWaning;
    }
  }

  /// Stat-card copy for the fertility window, derived from the ovulation date so
  /// the card never claims "ovulation nears" once the peak has passed.
  (String, String) _fertilityCopy(CycleProvider cycle, DateTime now) {
    final next = AppDate.short(cycle.nextOvulationDate(today: now));
    final opens = AppDate.short(cycle.ovulationDateThisCycle(today: now).subtract(const Duration(days: 5)));
    return switch (cycle.fertilityStatus(today: now)) {
      FertilityStatus.peakToday => ('Peak Today', 'High chance'),
      FertilityStatus.windowOpen => ('Window Open', 'Ovulation nears'),
      FertilityStatus.windowClosing => ('Window Closing', 'Ovulation passed'),
      FertilityStatus.passed => ('Peak Passed', 'next peak $next'),
      FertilityStatus.beforeWindow => ('In ${cycle.daysUntilOvulation(today: now)} Days', '$opens · window opens'),
    };
  }

  /// Bleeding-countdown + fertility-window stat duo.
  /// Perimenopause swaps the single-day countdown for an earliest/latest window.
  Widget _buildStatsRow(BuildContext context) {
    final cycle = context.watch<CycleProvider>();
    final now = DateTime.now();
    final DateTime? nextStart = cycle.nextPeriodStart(today: now);
    final daysUntil = cycle.daysUntilPeriod(today: now);
    final (value, sub) = _fertilityCopy(cycle, now);
    String bleedValue;
    String bleedSub;
    // Null once the projection has stopped: nudge a fresh log instead of
    // showing a stale countdown.
    final range = cycle.predictedRange(today: now);
    final late = cycle.daysLate(today: now);
    if (nextStart == null || range == null) {
      bleedValue = 'Log to update';
      bleedSub = 'cycle running long - log to re-anchor';
    } else if (late > 0) {
      bleedValue = '$late ${late == 1 ? 'Day' : 'Days'} Late';
      bleedSub = 'log your period to re-anchor';
    } else if (cycle.showPeriodRange) {
      final todayDate = DateTime(now.year, now.month, now.day);
      final dMin = CycleCalculator.daysBetween(todayDate, range.earliest);
      final dMax = CycleCalculator.daysBetween(todayDate, range.latest);
      bleedValue = dMin == dMax ? '$dMin Days' : '$dMin–$dMax Days';
      bleedSub = '${AppDate.range(range.earliest, range.latest)} · range';
    } else {
      bleedValue = '$daysUntil Days';
      bleedSub = '${AppDate.short(nextStart)} · predicted';
    }
    // Pregnancy states repurpose the countdown card: active suppresses the
    // period countdown (links the tracker instead), gap state nudges setup.
    VoidCallback bleedTap = () => context.go('/bleed-history');
    if (cycle.pregnancyActive) {
      bleedValue = 'Pregnancy';
      bleedSub = 'open Pregnancy Tracker';
      bleedTap = () => context.go('/pregnancy');
    } else if (cycle.pregnancyModeOn) {
      bleedValue = 'Set up tracker';
      bleedSub = 'add dates in Pregnancy Tracker';
      bleedTap = () => context.go('/pregnancy');
    }
    return Row(
      children: [
        Expanded(child: StatCard(label: 'Bleeding In', value: bleedValue, sub: bleedSub, onTap: bleedTap)),
        if (cycle.showFertilityPredictions) ...[
          const SizedBox(width: 12),
          Expanded(child: StatCard(label: 'Fertility Window', value: value, sub: sub, valueColor: AppColors.pink, onTap: () => context.go('/fertility'))),
        ],
      ],
    );
  }

  /// Quick-action tiles; each opens the log sheet focused on its category.
  /// Tiles whose category already has entries logged today render solid purple
  /// and report the logged value underneath the label.
  Widget _buildTodaysMagicSection(BuildContext context) {
    final entry = context.watch<LoggingProvider>().peekDay(DateTime.now());
    Widget tile(LogCategory category, String label, Set<String> values) => Expanded(
      child: QuickAction(
        icon: category.icon ?? AppIcons.drop,
        label: label,
        value: summarizeLogSet(values),
        filled: values.isNotEmpty,
        onTap: () => showLogSheet(context, DateTime.now(), scrollTo: category),
      ),
    );
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Today's Log", style: AppText.sec),
        const SizedBox(height: 8),
        Row(
          children: [
            tile(LogData.flows, 'Flow', entry?.flow ?? const <String>{}),
            const SizedBox(width: 10),
            tile(LogData.moods, 'Mood', entry?.moods ?? const <String>{}),
            const SizedBox(width: 10),
            tile(LogData.painSymptoms, 'Pain', entry?.symptoms ?? const <String>{}),
            const SizedBox(width: 10),
            tile(LogData.sleep, 'Sleep', entry?.sleep ?? const <String>{}),
          ],
        ),
      ],
    );
  }

  /// Circle decoration mirroring IconBadge, wrapping the moon glyph.
  Widget _buildMoonCircle(String glyph) => Container(
    width: 34,
    height: 34,
    decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
    alignment: Alignment.center,
    child: SvgPicture.asset(glyph, width: 20, height: 20, excludeFromSemantics: true),
  );

  /// Filled-tile style row: white icon badge with pur glyph + white label.
  Widget _buildInsightRow(FaIconData icon, String text, VoidCallback onTap) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: onTap,
        child: Row(children: [IconBadge(icon: icon, bg: Colors.white, fg: AppColors.pur), const SizedBox(width: 12), Expanded(child: Text(text, style: AppText.sans(12.5, c: Colors.white)))]),
      ),
    );
  }

  /// Today's entry card: cycle-day tag, moon glyph, calendar-relative phase, log rows.
  Widget _buildAstralInsightCard(BuildContext context) {
    final cycle = context.watch<CycleProvider>();
    final log = context.watch<LoggingProvider>();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final phase = cycle.phaseAt(today);
    final cycleDay = cycle.cycleDay(today: now);
    final periodDay = cycle.isPeriodDay(now);
    final entry = log.peekDay(now);
    final flow = entry?.flow ?? const <String>{};
    final moods = entry?.moods ?? const <String>{};
    final symptoms = entry?.symptoms ?? const <String>{};
    final sleep = entry?.sleep ?? const <String>{};
    final logged = flow.isNotEmpty;
    final bleedDay = periodDay ? cycle.bleedDayOf(today) : 0;
    final daysUntil = cycle.daysUntilPeriod(today: now);
    // Softened wording in perimenopause where timing is less predictable.
    final soonNote = cycle.isPerimenopause ? (daysUntil == 1 || daysUntil == 2) : daysUntil == 1;
    final soonText = cycle.isPerimenopause ? 'Period may start any day now' : 'Period may start tomorrow';
    return AppCard(
      dark: true,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () => showLogSheet(context, now),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildMoonCircle(_glyph(phase, predictedPeriod: periodDay && !logged)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppDate.long(today), style: AppText.serif(13.5, c: Colors.white)),
                        const SizedBox(height: 2),
                        Text(phase.phaseName, style: AppText.sans(12, c: Colors.white70)),
                        if (soonNote) ...[const SizedBox(height: 2), Text(soonText, style: AppText.sans(12, w: FontWeight.w700, c: AppColors.pinkDark))],
                      ],
                    ),
                  ),
                  periodDay ? AppTag.pink('Period Day $bleedDay') : AppTag.pink('Cycle Day $cycleDay'),
                ],
              ),
              const SizedBox(height: 14),
              _buildInsightRow(AppIcons.drop, logged ? '${flow.join(', ')} bleed flow intensity' : 'No flow logged yet', () => showLogSheet(context, now, scrollTo: LogData.flows)),
              const SizedBox(height: 8),
              _buildInsightRow(AppIcons.heart, moods.isEmpty ? 'No mood logged yet' : '${summarizeLogSet(moods)} mood', () => showLogSheet(context, now, scrollTo: LogData.moods)),
              const SizedBox(height: 8),
              _buildInsightRow(
                LogData.painSymptoms.icon ?? AppIcons.pulse,
                symptoms.isEmpty ? 'No symptoms logged yet' : summarizeLogSet(symptoms),
                () => showLogSheet(context, now, scrollTo: LogData.painSymptoms),
              ),
              const SizedBox(height: 8),
              _buildInsightRow(
                LogData.sleep.icon ?? AppIcons.moon,
                sleep.isEmpty ? 'No sleep logged yet' : summarizeLogSet(sleep),
                () => showLogSheet(context, now, scrollTo: LogData.sleep),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cycle = context.watch<CycleProvider>();
    final now = DateTime.now();
    final dayNum = cycle.cycleDay(today: now);
    final bleedDays = cycle.meanBleedLength?.round() ?? cycle.bleedLength;
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, AppDims.fabClearance),
      children: [
        const SizedBox(height: 8),
        CycleOrb(
          day: '$dayNum',
          phase: cycle.phase(today: now).label,
          progress: dayNum / cycle.effectiveCycleLength,
          cycleLength: cycle.effectiveCycleLength,
          bleedLength: bleedDays,
          fertileStartDay: cycle.fertileStartCycleDay,
          fertileEndDay: cycle.fertileEndCycleDay,
        ),
        const SizedBox(height: 12),
        _buildStatsRow(context),
        const SizedBox(height: 12),
        _buildTodaysMagicSection(context),
        const SizedBox(height: 12),
        _buildAstralInsightCard(context),
        const SizedBox(height: 16),
        const DisclaimerText(),
      ],
    );
  }
}
