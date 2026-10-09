import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../common/log_data.dart';
import '../models/cycle_phase.dart';
import '../navigation/app_nav.dart';
import '../providers/cycle_provider.dart';
import '../providers/logging_provider.dart';
import '../services/cycle_calculator.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_icons.dart';
import '../widgets/log_bottom_sheet.dart';
import '../widgets/quick_action.dart';
import '../widgets/stat_card.dart';
import '../widgets/app_card.dart';
import '../widgets/app_tag.dart';
import '../widgets/cycle_orb.dart';
import '../widgets/icon_badge.dart';

class SanctuaryScreen extends StatelessWidget {
  const SanctuaryScreen({super.key});

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

  /// Bleeding-countdown + fertility-window stat duo.
  /// Perimenopause swaps the single-day countdown for an earliest/latest window.
  Widget _buildStatsRow(BuildContext context) {
    final cycle = context.watch<CycleProvider>();
    final now = DateTime.now();
    final nextStart = cycle.nextPeriodStart(today: now);
    final daysUntil = cycle.daysUntilPeriod(today: now);
    final ovuToday = cycle.ovulationToday;
    final fertileNow = cycle.fertileToday;
    final daysToOvu = cycle.daysUntilOvulation(today: now);
    final value =
        ovuToday
            ? 'Peak Today'
            : fertileNow
            ? 'Window Open'
            : 'In $daysToOvu Days';
    final sub =
        ovuToday
            ? 'High chance'
            : fertileNow
            ? 'Ovulation nears'
            : '${DateFormat('MMM d').format(cycle.ovulationDay(today: now))} · predicted';
    String bleedValue = '$daysUntil Days';
    String bleedSub = '${DateFormat('MMM d').format(nextStart)} · predicted';
    if (cycle.isPerimenopause) {
      final range = cycle.predictedRange(today: now);
      final todayDate = DateTime(now.year, now.month, now.day);
      final dMin = CycleCalculator.daysBetween(todayDate, range.earliest);
      final dMax = CycleCalculator.daysBetween(todayDate, range.latest);
      bleedValue = dMin == dMax ? '$dMin Days' : '$dMin–$dMax Days';
      bleedSub = '${DateFormat('MMM d').format(range.earliest)} – ${DateFormat('MMM d').format(range.latest)} · range';
    }
    return Row(
      children: [
        Expanded(child: StatCard(label: 'Bleeding In', value: bleedValue, sub: bleedSub)),
        if (cycle.showFertilityPredictions) ...[
          const SizedBox(width: 12),
          Expanded(child: GestureDetector(onTap: () => context.go('/fertility'), child: StatCard(label: 'Fertility Window', value: value, sub: sub, valueColor: AppColors.pink))),
        ],
      ],
    );
  }

  /// Quick-action tiles; each opens the log sheet focused on its category.
  /// Tiles whose category already has entries logged today render solid purple.
  Widget _buildTodaysMagicSection(BuildContext context) {
    final entry = context.watch<LoggingProvider>().peekDay(DateTime.now());
    Widget tile(LogCategory category, String label, bool hasEntry) =>
        Expanded(child: QuickAction(icon: category.icon ?? AppIcons.drop, label: label, filled: hasEntry, onTap: () => showLogSheet(context, DateTime.now(), scrollTo: category)));
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text("Today's magic", style: AppText.sec),
        const SizedBox(height: 8),
        Row(
          children: [
            tile(LogData.flows, 'Flow', entry?.flow.isNotEmpty ?? false),
            const SizedBox(width: 10),
            tile(LogData.moods, 'Mood', entry?.moods.isNotEmpty ?? false),
            const SizedBox(width: 10),
            tile(LogData.painSymptoms, 'Pain', entry?.symptoms.isNotEmpty ?? false),
            const SizedBox(width: 10),
            tile(LogData.sleep, 'Sleep', entry?.sleep.isNotEmpty ?? false),
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
    final logged = flow.isNotEmpty;
    final bleedDay = periodDay ? CycleCalculator.bleedDay(cycle.effectiveLastStart, today, cycle.effectiveCycleLength, cycle.bleedLength) : 0;
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
                        Text(DateFormat('MMMM d, yyyy').format(today), style: AppText.serif(13.5, c: Colors.white)),
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
              _buildInsightRow(AppIcons.heart, moods.isEmpty ? 'No mood logged yet' : '${moods.first} mood', () => showLogSheet(context, now, scrollTo: LogData.moods)),
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
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
      children: [
        const SizedBox(height: 8),
        CycleOrb(day: '${cycle.cycleDay(today: now)}', phase: cycle.phase(today: now).label),
        const SizedBox(height: 12),
        _buildStatsRow(context),
        const SizedBox(height: 12),
        _buildTodaysMagicSection(context),
        const SizedBox(height: 12),
        _buildAstralInsightCard(context),
      ],
    );
  }
}
