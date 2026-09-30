import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../providers/cycle_provider.dart';
import '../providers/logging_provider.dart';
import '../services/calendar_fetcher.dart';
import '../services/cycle_calculator.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/app_icons.dart';
import '../widgets/log_bottom_sheet.dart';
import '../widgets/calendar_legend.dart';
import '../widgets/cycle_calendar.dart';
import '../widgets/month_picker_sheet.dart';
import '../widgets/app_card.dart';
import '../widgets/app_tag.dart';

class CycleMapScreen extends StatefulWidget {
  const CycleMapScreen({super.key});
  @override
  State<CycleMapScreen> createState() => _CycleMapScreenState();
}

class _CycleMapScreenState extends State<CycleMapScreen> {
  late DateTime _month = DateTime(DateTime.now().year, DateTime.now().month, 1);
  late int _selectedDay = DateTime.now().day;

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

  Widget _entryRow(FaIconData icon, Color color, String text, DateTime date) {
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () => showLogSheet(context, date),
        child: Row(
          children: [
            FaIcon(icon, size: AppIconSize.row, color: color),
            const SizedBox(width: 8),
            Text(text, style: AppText.sans(11.5, c: AppColors.chipText)),
          ],
        ),
      ),
    );
  }

  Future<void> _confirmClear(DateTime date) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear this day?'),
        content: const Text('Removes flow, moods, symptoms, pain, and notes for this day.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.of(ctx).pop(true), child: Text('Clear', style: TextStyle(color: AppColors.pink))),
        ],
      ),
    );
    if (ok == true && mounted) context.read<LoggingProvider>().deleteDay(date);
  }

  @override
  Widget build(BuildContext context) {
    final cycle = context.watch<CycleProvider>();
    final logging = context.watch<LoggingProvider>();
    final cells = CalendarFetcher.forMonth(
      month: _month,
      lastStart: cycle.effectiveLastStart,
      cycleLength: cycle.effectiveCycleLength,
      bleedLength: cycle.bleedLength,
      logs: logging.snapshot(),
      selectedDay: _selectedDay,
    );
    final selectedDate = DateTime(_month.year, _month.month, _selectedDay);
    final selectedCell = cells.cellFor(_selectedDay);
    final entry = logging.peekDay(selectedDate);
    final periodDay = selectedCell?.isPeriod ?? false;
    final fertile = selectedCell?.isFertile ?? false;
    final bleedDay = periodDay ? CycleCalculator.bleedDay(cycle.effectiveLastStart, selectedDate, cycle.effectiveCycleLength, cycle.bleedLength) : 0;
    final cycleDay = CycleCalculator.cycleDay(cycle.effectiveLastStart, selectedDate, cycle.effectiveCycleLength);
    final daysLate = cycle.daysLate();
    final showStatusRow = daysLate > 0 || !_isCurrentMonth;

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 14),
      children: [
        AppCard(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: () => _shiftMonth(-1),
                    child: const FaIcon(AppIcons.left, size: AppIconSize.head, color: AppColors.muted),
                  ),
                  MouseRegion(
                    cursor: SystemMouseCursors.click,
                    child: GestureDetector(
                      onTap: _pickMonth,
                      child: Row(mainAxisSize: MainAxisSize.min, children: [
                        Text(DateFormat('MMMM yyyy').format(_month), style: AppText.serif(13.5)),
                        const SizedBox(width: 6),
                        const FaIcon(AppIcons.right, size: AppIconSize.xs, color: AppColors.muted),
                      ]),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => _shiftMonth(1),
                    child: const FaIcon(AppIcons.right, size: AppIconSize.head, color: AppColors.muted),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              CycleCalendar(cells: cells, onDayTap: _selectDay, onSwipe: _shiftMonth),
              const SizedBox(height: 12),
              const CalendarLegend(),
              if (showStatusRow) ...[
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (daysLate > 0) AppTag.gold(daysLate == 1 ? '1 Day Late' : '$daysLate Days Late'),
                    if (daysLate > 0 && !_isCurrentMonth) const SizedBox(width: 8),
                    if (!_isCurrentMonth)
                      MouseRegion(
                        cursor: SystemMouseCursors.click,
                        child: GestureDetector(onTap: () => _setMonth(DateTime.now()), child: const AppTag('Today')),
                      ),
                  ],
                ),
              ],
            ],
          ),
        ),
        const SizedBox(height: 12),
        AppCard(
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(DateFormat('MMMM d, yyyy').format(selectedDate), style: AppText.serif(13.5)),
                  if (periodDay && bleedDay > 0)
                    AppTag.pink('Period Day $bleedDay')
                  else if (periodDay)
                    AppTag.pink('Period Logged')
                  else if (fertile)
                    const AppTag('Fertile Window')
                  else
                    AppTag('Cycle Day $cycleDay'),
                ],
              ),
              const SizedBox(height: 8),
              _entryRow(
                AppIcons.drop,
                AppColors.pink,
                entry == null ? 'No flow logged yet' : '${entry.flow} bleed flow intensity',
                selectedDate,
              ),
              const SizedBox(height: 6),
              _entryRow(
                AppIcons.heart,
                AppColors.pur,
                entry == null || entry.moods.isEmpty ? 'No mood logged yet' : '${entry.moods.first} mood',
                selectedDate,
              ),
              if (entry != null) ...[
                const SizedBox(height: 8),
                MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: () => _confirmClear(selectedDate),
                    child: Text("Clear this day's log", style: AppText.sans(11, w: FontWeight.w600, c: AppColors.pink)),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
