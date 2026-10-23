import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

import '../common/date_format.dart';
import '../common/log_data.dart';
import '../common/log_summary.dart';
import '../models/cycle_phase.dart';
import '../models/day_log.dart';
import '../providers/cycle_provider.dart';
import '../providers/logging_provider.dart';
import '../services/calendar_fetcher.dart';
import '../theme/app_colors.dart';
import '../theme/app_dims.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_icons.dart';
import '../widgets/log_bottom_sheet.dart';
import '../widgets/calendar_legend.dart';
import '../widgets/cycle_calendar.dart';
import '../widgets/icon_badge.dart';
import '../widgets/month_picker_sheet.dart';
import '../widgets/app_card.dart';
import '../widgets/app_tag.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});
  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  static const _glyphPeriod = 'assets/svgs/moon-period.svg';
  static const _glyphPeriodPredicted = 'assets/svgs/moon-period-predicted.svg';
  static const _glyphFertile = 'assets/svgs/moon-fertile.svg';
  static const _glyphOvulation = 'assets/svgs/moon-ovulation.svg';
  static const _glyphWaxing = 'assets/svgs/moon-waxing.svg';
  static const _glyphWaning = 'assets/svgs/moon-waning.svg';

  late DateTime _month = DateTime(DateTime.now().year, DateTime.now().month, 1);
  late int _selectedDay = DateTime.now().day;
  DateTime? _selectedEntry;

  bool get _isCurrentMonth {
    final now = DateTime.now();
    return now.year == _month.year && now.month == _month.month;
  }

  void _setMonth(DateTime month) {
    final now = DateTime.now();
    setState(() {
      _month = DateTime(month.year, month.month, 1);
      if (now.year == month.year && now.month == month.month) {
        _selectedDay = now.day;
      } else {
        // Preserve the selected day across month navigation, clamped to the new month length.
        final lastDay = DateTime(month.year, month.month + 1, 0).day;
        _selectedDay = _selectedDay.clamp(1, lastDay);
      }
    });
  }

  void _shiftMonth(int delta) => _setMonth(DateTime(_month.year, _month.month + delta, 1));

  void _selectDay(int day) {
    setState(() => _selectedDay = day);
    showLogSheet(context, DateTime(_month.year, _month.month, day));
  }

  Future<void> _pickMonth() async {
    final picked = await showMonthPicker(context, _month);
    if (picked != null && mounted) _setMonth(picked);
  }

  Future<void> _confirmClear(DateTime date) async {
    final ok = await showDialog<bool>(
      context: context,
      builder:
          (ctx) => AlertDialog(
            title: const Text('Clear this day?'),
            content: const Text('Removes flow, moods, symptoms, pain, and notes for this day.'),
            actions: [
              TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
              TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text('Clear', style: TextStyle(color: AppColors.pink))),
            ],
          ),
    );
    if (ok == true && mounted) {
      context.read<LoggingProvider>().deleteDay(date);
      setState(() => _selectedEntry = null);
    }
  }

  /// Month nav, calendar grid, legend, late/today tags.
  Widget _buildCalendarCard() {
    final cycle = context.watch<CycleProvider>();
    final logging = context.watch<LoggingProvider>();
    final range = cycle.showPeriodRange ? cycle.predictedRange() : null;
    final fertile = cycle.fertileWindow();
    final cells = CalendarFetcher.forMonth(
      month: _month,
      lastStart: cycle.effectiveLastStart,
      cycleLength: cycle.effectiveCycleLength,
      bleedLength: cycle.bleedLength,
      logs: logging.snapshot(),
      estimatedStarts: cycle.estimatedPeriodStarts,
      selectedDay: _selectedDay,
      showFertility: cycle.showFertilityPredictions,
      predictedStart: range?.earliest,
      predictedEnd: range?.latest,
      fertileStart: fertile?.start,
      fertileEnd: fertile?.end,
      effectiveOvulation: fertile?.peak,
      lutealLength: cycle.lutealLength,
      predictionsConfident: cycle.predictionsConfident(),
    );
    final daysLate = cycle.daysLate();
    final showStatusRow = daysLate > 0 || !_isCurrentMonth;
    return AppCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(onTap: () => _shiftMonth(-1), child: Icon(AppIcons.left, size: AppIconSize.head, color: AppColors.muted)),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: _pickMonth,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(AppDate.monthYear(_month), style: AppText.serif(13.5)),
                      const SizedBox(width: 6),
                      Icon(Icons.calendar_month, size: AppIconSize.xs, color: AppColors.muted),
                    ],
                  ),
                ),
              ),
              GestureDetector(onTap: () => _shiftMonth(1), child: Icon(AppIcons.right, size: AppIconSize.head, color: AppColors.muted)),
            ],
          ),
          const SizedBox(height: 12),
          CycleCalendar(cells: cells, onDayTap: _selectDay),
          const SizedBox(height: 12),
          const CalendarLegend(),
          if (!cycle.pregnancyModeOn) ...[
            const SizedBox(height: 6),
            Text(cycle.predictionBasis, style: AppText.sans(9.5, c: AppColors.muted)),
          ],
          if (showStatusRow) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (daysLate > 0) AppTag.gold(daysLate == 1 ? '1 Day Late' : '$daysLate Days Late'),
                if (daysLate > 0 && !_isCurrentMonth) const SizedBox(width: 8),
                if (!_isCurrentMonth) MouseRegion(cursor: SystemMouseCursors.click, child: GestureDetector(onTap: () => _setMonth(DateTime.now()), child: AppTag('Today'))),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// The selected day on its own. History belongs in Insights, not under the
  /// calendar, where it read as if every recent bleed happened on the selection.
  Widget _buildLoggedCard() {
    final cycle = context.watch<CycleProvider>();
    final selectedDate = DateTime(_month.year, _month.month, _selectedDay);
    final entry = context.watch<LoggingProvider>().peekDay(selectedDate);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Selected day', style: AppText.sec),
        const SizedBox(height: 8),
        if (entry == null) ...[
          Text(AppDate.long(selectedDate), style: AppText.sans(11, c: AppColors.muted)),
          const SizedBox(height: 6),
          if (cycle.estimatedPeriodStarts.contains(selectedDate)) ...[
            AppTag.gold('Estimated start'),
            const SizedBox(height: 6),
            Text('From your onboarding history. Log flow to confirm.', style: AppText.sans(12, c: AppColors.muted)),
          ] else
            Text('No entry for this day', style: AppText.sans(12, c: AppColors.muted)),
          const SizedBox(height: 4),
          TextButton(onPressed: () => showLogSheet(context, selectedDate), child: const Text('Log this day')),
        ] else
          _buildEntryCard(cycle, selectedDate, entry),
      ],
    );
  }

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

  /// Circle decoration mirroring IconBadge, wrapping the moon glyph.
  Widget _buildMoonCircle(String glyph) => Container(
    width: 34,
    height: 34,
    decoration: const BoxDecoration(shape: BoxShape.circle, color: Colors.white),
    alignment: Alignment.center,
    child: SvgPicture.asset(glyph, width: 20, height: 20, excludeFromSemantics: true),
  );

  /// One log entry per purple card: moon glyph, date + period tag, flow/mood rows, clear when tapped.
  Widget _buildEntryCard(CycleProvider cycle, DateTime date, DayLog entry) {
    final phase = cycle.phaseAt(date);
    final periodDay = cycle.isPeriodDay(date);
    final loggedPeriod = cycle.hasLoggedPeriodBleedOn(date);
    final bleedDay = loggedPeriod ? cycle.bleedDayOf(date) : 0;
    final selected = _selectedEntry == date;
    return AppCard(
      dark: true,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: () {
            setState(() => _selectedEntry = date);
            showLogSheet(context, date);
          },
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _buildMoonCircle(_glyph(phase, predictedPeriod: periodDay && entry.flow.isEmpty)),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(AppDate.long(date), style: AppText.serif(13.5, c: Colors.white)),
                        const SizedBox(height: 2),
                        Text(phase.phaseName, style: AppText.sans(12, c: Colors.white70)),
                      ],
                    ),
                  ),
                  loggedPeriod ? AppTag.pink('Period Day $bleedDay') : AppTag.pink(entry.flow.isEmpty ? 'Logged' : 'Flow Logged'),
                ],
              ),
              const SizedBox(height: 14),
              _buildEntryRow(AppIcons.drop, entry.flow.isEmpty ? 'No flow logged yet' : '${entry.flow.join(', ')} bleed flow intensity'),
              const SizedBox(height: 8),
              _buildEntryRow(AppIcons.heart, entry.moods.isEmpty ? 'No mood logged yet' : '${summarizeLogSet(entry.moods)} mood'),
              const SizedBox(height: 8),
              _buildEntryRow(LogData.painSymptoms.icon ?? AppIcons.pulse, entry.symptoms.isEmpty ? 'No symptoms logged yet' : summarizeLogSet(entry.symptoms)),
              const SizedBox(height: 8),
              _buildEntryRow(LogData.sleep.icon ?? AppIcons.moon, entry.sleep.isEmpty ? 'No sleep logged yet' : summarizeLogSet(entry.sleep)),
              if (selected) ...[
                const SizedBox(height: 10),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(onTap: () => _confirmClear(date), child: Text("Clear this day's log", style: AppText.sans(11, w: FontWeight.w600, c: AppColors.pink))),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Filled-tile style row: white icon badge with pur glyph + white label.
  Widget _buildEntryRow(FaIconData icon, String text) {
    return Row(
      children: [
        IconBadge(icon: icon, bg: Colors.white, fg: AppColors.pur),
        const SizedBox(width: 12),
        Expanded(child: Text(text, style: AppText.sans(12.5, c: Colors.white))),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, AppDims.fabClearance),
      children: [_buildCalendarCard(), const SizedBox(height: 12), _buildLoggedCard()],
    );
  }
}
