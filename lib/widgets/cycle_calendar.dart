import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../common/date_format.dart';
import '../models/calendar_day_cell.dart';
import '../models/month_cells.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class CycleCalendar extends StatefulWidget {
  final MonthCells cells;
  final ValueChanged<int>? onDayTap;

  const CycleCalendar({super.key, required this.cells, this.onDayTap});

  @override
  State<CycleCalendar> createState() => _CycleCalendarState();
}

class _CycleCalendarState extends State<CycleCalendar> {
  static const _glyphPeriod = 'assets/svgs/moon-period.svg';
  static const _glyphPeriodPredicted = 'assets/svgs/moon-period-predicted.svg';
  static const _glyphFertile = 'assets/svgs/moon-fertile.svg';
  static const _glyphOvulation = 'assets/svgs/moon-ovulation.svg';

  String _semanticLabel(CalendarDayCell cell) {
    final first = widget.cells.month;
    final leading = first.weekday - 1;
    final index = widget.cells.cells.indexOf(cell);
    final date = DateTime(first.year, first.month, 1 + index - leading);
    final parts = [AppDate.weekdayLong(date)];
    if (!cell.inMonth) return '${parts.first}, outside this month';
    if (cell.isFuture) parts.add('future date');
    if (cell.isToday) parts.add('today');
    if (cell.isSelected) parts.add('selected');
    if (cell.isLoggedBleed) {
      parts.add('period logged');
    } else if (cell.isPredictedPeriod) {
      parts.add('predicted period');
    }
    if (cell.isOvulation) {
      parts.add('ovulation day');
    } else if (cell.isFertile) {
      parts.add('fertile window');
    }
    if (cell.isEstimatedStart) parts.add('estimated period start');
    if (cell.isLogged && !cell.isLoggedBleed) parts.add('entries logged');
    parts.add('cycle day ${cell.cycleDay}');
    return parts.join(', ');
  }

  String? _glyph(CalendarDayCell cell) {
    if (cell.isLoggedBleed) return _glyphPeriod;
    if (cell.isPredictedPeriod) return _glyphPeriodPredicted;
    if (cell.isOvulation) return _glyphOvulation;
    if (cell.isFertile) return _glyphFertile;
    return null;
  }

  Widget _buildRing(Color color, double width) => Container(width: 44, height: 44, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: color, width: width)));

  Widget _buildAdjacentCell(CalendarDayCell cell) {
    return SizedBox(height: 54, child: Center(child: Semantics(label: _semanticLabel(cell), child: Text('${cell.day}', style: AppText.sans(15, c: AppColors.placeholder)))));
  }

  Widget _buildDayCell(CalendarDayCell cell) {
    final tappable = widget.onDayTap != null && !cell.isFuture;
    final glyph = _glyph(cell);
    // Moon glyphs carry light fills; dark-mode ink would vanish on them.
    final onGlyph = glyph != null;
    final today = cell.isToday;
    final dayColor = cell.isFuture ? AppColors.placeholder : onGlyph ? const Color(0xFF2A0A3C) : AppColors.ink;
    final subColor = cell.isFuture ? AppColors.placeholder : onGlyph ? const Color(0xFF5D4A70) : AppColors.muted;
    return SizedBox(
      height: 54,
      child: Semantics(
        label: _semanticLabel(cell),
        button: tappable,
        selected: cell.isSelected,
        child: MouseRegion(
          cursor: tappable ? SystemMouseCursors.click : SystemMouseCursors.basic,
          child: GestureDetector(
            onTap: tappable ? () => widget.onDayTap!(cell.day) : null,
            child: SizedBox(
              width: double.infinity,
              height: 54,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final surface = constraints.maxWidth < 54 ? constraints.maxWidth : 54.0;
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      if (today)
                        Container(
                          key: const Key('calendar-today-cell'),
                          width: surface,
                          height: surface,
                          decoration: BoxDecoration(
                            color: AppColors.dark ? AppColors.lav2 : AppColors.plum,
                            borderRadius: BorderRadius.circular(16),
                          ),
                        ),
                      if (today)
                        Container(
                          key: const Key('calendar-today-inner'),
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.lav),
                        ),
                      if (glyph != null) SvgPicture.asset(glyph, width: 44, height: 44, excludeFromSemantics: true),
                      if (today && !cell.isSelected) _buildRing(AppColors.gold, 1.5),
                      if (cell.isSelected) _buildRing(today ? Colors.white : AppColors.pur, 2),
                      Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text('${cell.day}', style: AppText.sans(15, w: today || cell.isSelected ? FontWeight.w700 : FontWeight.w500, c: dayColor)),
                          Text('${cell.cycleDay}', style: AppText.sans(9, w: FontWeight.w500, c: subColor)),
                        ],
                      ),
                      Positioned(
                        bottom: 0,
                        left: 0,
                        right: 0,
                        child: Center(
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              if (cell.isEstimatedStart) Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.gold)),
                              if (cell.isEstimatedStart && (cell.isOvulation || cell.isLogged)) const SizedBox(width: 3),
                              if (cell.isOvulation) Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.teal)),
                              if (cell.isOvulation && cell.isLogged) const SizedBox(width: 3),
                              if (cell.isLogged) Container(width: 8, height: 8, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.blue)),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWeekRow(List<CalendarDayCell> week, bool isLast) {
    return Padding(padding: EdgeInsets.only(bottom: isLast ? 0 : 4), child: Row(children: [for (final cell in week) Expanded(child: cell.inMonth ? _buildDayCell(cell) : _buildAdjacentCell(cell))]));
  }

  @override
  Widget build(BuildContext context) {
    final all = widget.cells.cells;
    // Hide a trailing week that is entirely next-month padding.
    var end = all.length;
    if (end >= 14) {
      final lastWeek = all.sublist(end - 7);
      if (lastWeek.every((c) => !c.inMonth)) end -= 7;
    }
    final rows = <Widget>[];
    for (var i = 0; i < end; i += 7) {
      final chunk = all.sublist(i, (i + 7).clamp(0, end));
      rows.add(_buildWeekRow(chunk, i + 7 >= end));
    }
    return Column(
      children: [
        Row(
          children: [
            for (final d in ['M', 'T', 'W', 'T', 'F', 'S', 'S']) Expanded(child: Center(child: Text(d, style: AppText.sans(12, w: FontWeight.w500, c: AppColors.muted)))),
          ],
        ),
        const SizedBox(height: 4),
        ...rows,
      ],
    );
  }
}
