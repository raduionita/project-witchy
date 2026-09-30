import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../models/calendar_day_cell.dart';
import '../models/month_cells.dart';
import '../theme/app_colors.dart';
import '../theme/app_text_styles.dart';

class CycleCalendar extends StatefulWidget {
  final MonthCells cells;
  final ValueChanged<int>? onDayTap;
  final ValueChanged<int>? onSwipe;

  const CycleCalendar({super.key, required this.cells, this.onDayTap, this.onSwipe});

  @override
  State<CycleCalendar> createState() => _CycleCalendarState();
}

class _CycleCalendarState extends State<CycleCalendar> {
  static const _swipeThreshold = 48.0;
  double _dx = 0;

  void _onDragUpdate(DragUpdateDetails details) {
    if (widget.onSwipe == null) return;
    _dx += details.delta.dx;
    if (_dx.abs() >= _swipeThreshold) {
      final direction = _dx > 0 ? -1 : 1;
      _dx = 0;
      widget.onSwipe!(direction);
    }
  }

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

  Widget _adjacentCell(CalendarDayCell cell) {
    return Center(
      child: Semantics(
        label: _semanticLabel(cell),
        child: Text('${cell.day}', style: AppText.sans(10.5, c: AppColors.placeholder)),
      ),
    );
  }

  Widget _dayCell(CalendarDayCell cell) {
    final isLoggedBleed = cell.isLoggedBleed;
    final isPredicted = cell.isPredictedPeriod && !isLoggedBleed;
    final isFertile = cell.isFertile && !isLoggedBleed && !isPredicted;
    final Color? fill;
    Color? border;
    final Color textColor;
    if (isLoggedBleed) {
      fill = AppColors.pur;
      border = null;
      textColor = Colors.white;
    } else if (isPredicted) {
      fill = Colors.white;
      border = AppColors.pur;
      textColor = AppColors.pur;
    } else if (isFertile) {
      fill = AppColors.fertileBg;
      border = null;
      textColor = AppColors.fertileText;
    } else {
      fill = null;
      border = cell.isSelected ? AppColors.pur : null;
      textColor = AppColors.body;
    }
    if (cell.isToday && border == null) {
      border = fill == null ? AppColors.pur : Colors.white;
    }
    final strong = isLoggedBleed || isPredicted || isFertile || cell.isToday;
    final tappable = widget.onDayTap != null;
    return Center(
      child: Semantics(
        label: _semanticLabel(cell),
        button: tappable,
        selected: cell.isSelected,
        child: MouseRegion(
          cursor: tappable ? SystemMouseCursors.click : SystemMouseCursors.basic,
          child: GestureDetector(
            onTap: tappable ? () => widget.onDayTap!(cell.day) : null,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 34,
                  height: 34,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: fill,
                    border: border == null ? null : Border.all(color: border, width: 1.4),
                  ),
                  child: Text(
                    '${cell.day}',
                    style: AppText.sans(11, c: textColor, w: strong ? FontWeight.w600 : FontWeight.w400),
                  ),
                ),
                const SizedBox(height: 2),
                SizedBox(
                  height: 4,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (cell.isOvulation) ...[
                        Container(width: 4, height: 4, decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.pink)),
                        if (cell.isLogged) const SizedBox(width: 3),
                      ],
                      if (cell.isLogged) Container(width: 4, height: 4, decoration: BoxDecoration(shape: BoxShape.circle, color: isLoggedBleed ? Colors.white : AppColors.gold)),
                    ],
                  ),
                ),
                const SizedBox(height: 1),
                Text('${cell.cycleDay}', style: AppText.sans(8, c: AppColors.muted, w: FontWeight.w500)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: widget.onSwipe == null ? null : _onDragUpdate,
      onHorizontalDragEnd: widget.onSwipe == null ? null : (_) => _dx = 0,
      child: Column(
        children: [
          Row(
            children: [for (final d in ['M', 'T', 'W', 'T', 'F', 'S', 'S']) Expanded(child: Center(child: Text(d, style: AppText.sans(9, w: FontWeight.w600, c: AppColors.muted))))],
          ),
          const SizedBox(height: 4),
          GridView.count(
            crossAxisCount: 7,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            children: [for (final cell in widget.cells.cells) cell.inMonth ? _dayCell(cell) : _adjacentCell(cell)],
          ),
        ],
      ),
    );
  }
}
