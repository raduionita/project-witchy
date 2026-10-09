import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';

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
    final parts = [DateFormat('EEEE, MMMM d').format(date)];
    if (!cell.inMonth) return '${parts.first}, outside this month';
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

  Widget _ring(Color color, double width) =>
      Container(width: 44, height: 44, decoration: BoxDecoration(shape: BoxShape.circle, border: Border.all(color: color, width: width)));

  Widget _adjacentCell(CalendarDayCell cell) {
    return SizedBox(
      height: 54,
      child: Center(child: Semantics(label: _semanticLabel(cell), child: Text('${cell.day}', style: AppText.sans(15, c: AppColors.placeholder)))),
    );
  }

  Widget _dayCell(CalendarDayCell cell) {
    final tappable = widget.onDayTap != null;
    final glyph = _glyph(cell);
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
            child: Stack(
              alignment: Alignment.center,
              children: [
                if (cell.isToday)
                  const SizedBox(width: 44, height: 44, child: DecoratedBox(decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.lav))),
                if (glyph != null) SvgPicture.asset(glyph, width: 44, height: 44, excludeFromSemantics: true),
                if (cell.isToday) _ring(AppColors.pur, 1.5),
                if (cell.isSelected) _ring(AppColors.ink, 2),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${cell.day}',
                      style: AppText.sans(15, w: cell.isToday ? FontWeight.w700 : FontWeight.w500, c: AppColors.ink),
                    ),
                    Text('${cell.cycleDay}', style: AppText.sans(11, w: FontWeight.w500, c: AppColors.muted)),
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
                        if (cell.isOvulation) Container(width: 6, height: 6, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.pink)),
                        if (cell.isOvulation && cell.isLogged) const SizedBox(width: 3),
                        if (cell.isLogged) Container(width: 6, height: 6, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.blue)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _weekRow(List<CalendarDayCell> week, bool isLast) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 4),
      child: Row(children: [for (final cell in week) Expanded(child: cell.inMonth ? _dayCell(cell) : _adjacentCell(cell))]),
    );
  }

  @override
  Widget build(BuildContext context) {
    final all = widget.cells.cells;
    final rows = <Widget>[];
    for (var i = 0; i < all.length; i += 7) {
      rows.add(_weekRow(all.sublist(i, (i + 7).clamp(0, all.length)), i + 7 >= all.length));
    }
    return Column(
      children: [
        Row(
          children: [
            for (final d in ['M', 'T', 'W', 'T', 'F', 'S', 'S'])
              Expanded(child: Center(child: Text(d, style: AppText.sans(12, w: FontWeight.w500, c: AppColors.muted)))),
          ],
        ),
        const SizedBox(height: 4),
        ...rows,
      ],
    );
  }
}
