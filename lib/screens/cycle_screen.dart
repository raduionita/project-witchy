import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../models/cycle_phase.dart';
import '../models/day_log.dart';
import '../providers/cycle_provider.dart';
import '../providers/logging_provider.dart';
import '../services/calendar_fetcher.dart';
import '../services/cycle_calculator.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../theme/app_icons.dart';
import '../widgets/log_bottom_sheet.dart';
import '../widgets/calendar_legend.dart';
import '../widgets/cycle_calendar.dart';
import '../widgets/icon_badge.dart';
import '../widgets/month_picker_sheet.dart';
import '../widgets/app_card.dart';
import '../widgets/app_tag.dart';

class CycleScreen extends StatefulWidget {
  const CycleScreen({super.key});
  @override
  State<CycleScreen> createState() => _CycleScreenState();
}

class _CycleScreenState extends State<CycleScreen> {
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
      _selectedDay = now.year == month.year && now.month == month.month ? now.day : 1;
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
    final range = cycle.isPerimenopause ? cycle.predictedRange() : null;
    final cells = CalendarFetcher.forMonth(
      month: _month,
      lastStart: cycle.effectiveLastStart,
      cycleLength: cycle.effectiveCycleLength,
      bleedLength: cycle.bleedLength,
      logs: logging.snapshot(),
      selectedDay: _selectedDay,
      showFertility: cycle.showFertilityPredictions,
      predictedStart: range?.earliest,
      predictedEnd: range?.latest,
    );
    final daysLate = cycle.daysLate();
    final showStatusRow = daysLate > 0 || !_isCurrentMonth;
    return AppCard(
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              GestureDetector(onTap: () => _shiftMonth(-1), child: const FaIcon(AppIcons.left, size: AppIconSize.head, color: AppColors.muted)),
              MouseRegion(
                cursor: SystemMouseCursors.click,
                child: GestureDetector(
                  onTap: _pickMonth,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(DateFormat('MMMM yyyy').format(_month), style: AppText.serif(13.5)),
                      const SizedBox(width: 6),
                      const FaIcon(AppIcons.right, size: AppIconSize.xs, color: AppColors.muted),
                    ],
                  ),
                ),
              ),
              GestureDetector(onTap: () => _shiftMonth(1), child: const FaIcon(AppIcons.right, size: AppIconSize.head, color: AppColors.muted)),
            ],
          ),
          const SizedBox(height: 12),
          CycleCalendar(cells: cells, onDayTap: _selectDay),
          const SizedBox(height: 12),
          const CalendarLegend(),
          if (showStatusRow) ...[
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (daysLate > 0) AppTag.gold(daysLate == 1 ? '1 Day Late' : '$daysLate Days Late'),
                if (daysLate > 0 && !_isCurrentMonth) const SizedBox(width: 8),
                if (!_isCurrentMonth) MouseRegion(cursor: SystemMouseCursors.click, child: GestureDetector(onTap: () => _setMonth(DateTime.now()), child: const AppTag('Today'))),
              ],
            ),
          ],
        ],
      ),
    );
  }

  /// Header mirroring Sanctuary's "Today's magic" + up to 10 newest flow-logged days.
  Widget _buildLoggedCard() {
    final cycle = context.watch<CycleProvider>();
    final recent =
        context
            .watch<LoggingProvider>()
            .snapshot()
            .entries
            .where((e) => e.value.flow.isNotEmpty)
            .toList()
          ..sort((a, b) => b.key.compareTo(a.key));
    final top = recent.take(10).toList();
    final children = <Widget>[
      Text('Period logged', style: AppText.sec),
      const SizedBox(height: 8),
    ];
    if (top.isEmpty) {
      children.add(Text('No period logged yet', style: AppText.sans(12, c: AppColors.muted)));
    }
    for (var i = 0; i < top.length; i++) {
      if (i > 0) children.add(const SizedBox(height: 10));
      children.add(_buildEntryCard(cycle, top[i].key, top[i].value));
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: children);
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
    final bleedDay = periodDay ? CycleCalculator.bleedDay(cycle.effectiveLastStart, date, cycle.effectiveCycleLength, cycle.bleedLength) : 0;
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
                        Text(DateFormat('MMMM d, yyyy').format(date), style: AppText.serif(13.5, c: Colors.white)),
                        const SizedBox(height: 2),
                        Text(phase.phaseName, style: AppText.sans(12, c: Colors.white70)),
                      ],
                    ),
                  ),
                  periodDay ? AppTag.pink('Period Day $bleedDay') : AppTag.pink('Period Logged'),
                ],
              ),
              const SizedBox(height: 14),
              _buildEntryRow(AppIcons.drop, entry.flow.isEmpty ? 'No flow logged yet' : '${entry.flow.join(', ')} bleed flow intensity'),
              const SizedBox(height: 8),
              _buildEntryRow(AppIcons.heart, entry.moods.isEmpty ? 'No mood logged yet' : '${entry.moods.first} mood'),
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
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
      children: [_buildCalendarCard(), const SizedBox(height: 12), _buildLoggedCard()],
    );
  }
}
