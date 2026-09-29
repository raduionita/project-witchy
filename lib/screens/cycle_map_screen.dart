import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../navigation/app_nav.dart';
import '../providers/cycle_provider.dart';
import '../providers/logging_provider.dart';
import '../services/calendar_fetcher.dart';
import '../services/cycle_calculator.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';
import '../utils/app_icons.dart';
import '../widgets/log_bottom_sheet.dart';
import '../widgets/cycle_calendar.dart';
import '../widgets/app_card.dart';
import '../widgets/app_tag.dart';

class CycleMapScreen extends StatefulWidget {
  const CycleMapScreen({super.key});
  @override
  State<CycleMapScreen> createState() => _CycleMapScreenState();
}

class _CycleMapScreenState extends State<CycleMapScreen> {
  late DateTime _month = DateTime.now();
  late int _selectedDay = DateTime.now().day;

  void _shiftMonth(int delta) {
    setState(() {
      _month = DateTime(_month.year, _month.month + delta, 1);
      _selectedDay = 1;
    });
  }

  void _selectDay(int day) {
    setState(() => _selectedDay = day);
    showLogSheet(context, DateTime(_month.year, _month.month, day));
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
                      onTap: () => context.go('/chart'),
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
              Row(
                children: [
                  const FaIcon(AppIcons.drop, size: AppIconSize.row, color: AppColors.pink),
                  const SizedBox(width: 8),
                  Text(entry == null ? 'No flow logged yet' : '${entry.flow} bleed flow intensity', style: AppText.sans(11.5, c: AppColors.chipText)),
                ],
              ),
              const SizedBox(height: 5),
              Row(
                children: [
                  const FaIcon(AppIcons.heart, size: AppIconSize.row, color: AppColors.pur),
                  const SizedBox(width: 8),
                  Text(entry == null || entry.moods.isEmpty ? 'No mood logged yet' : '${entry.moods.first} mood', style: AppText.sans(11.5, c: AppColors.chipText)),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}
