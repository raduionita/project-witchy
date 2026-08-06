import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/period_cycle.dart';
import '../providers/period_provider.dart';
import '../providers/fertility_provider.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<PeriodProvider, FertilityProvider>(
      builder: (context, periodProvider, fertilityProvider, _) {
        final cycles = periodProvider.cycles;
        final now = DateTime.now();
        final currentMonth = DateTime(now.year, now.month);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Calendar'),
            backgroundColor: const Color(0xFF9C27B0),
            foregroundColor: Colors.white,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildMonthNavigation(currentMonth),
                const SizedBox(height: 16),
                _buildCalendarGrid(context, currentMonth, cycles),
                const SizedBox(height: 24),
                _buildLegend(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildMonthNavigation(DateTime month) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            // Navigate to previous month
          },
        ),
        Text(
          '${_getMonthName(month.month)} ${month.year}',
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () {
            // Navigate to next month
          },
        ),
      ],
    );
  }

  Widget _buildCalendarGrid(BuildContext context, DateTime month, List<PeriodCycle> cycles) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);
    final firstWeekday = firstDayOfMonth.weekday % 7;
    final daysInMonth = lastDayOfMonth.day;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Row(
              children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat']
                  .map((day) => Expanded(
                        child: Center(
                          child: Text(
                            day,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ))
                  .toList(),
            ),
            const SizedBox(height: 8),
            _buildCalendarDays(context, firstWeekday, daysInMonth, cycles),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarDays(BuildContext context, int firstWeekday, int daysInMonth, List<PeriodCycle> cycles) {
    final now = DateTime.now();
    final rows = <Widget>[];

    for (int week = 0; week < 6; week++) {
      final rowChildren = <Widget>[];

      for (int day = 0; day < 7; day++) {
        final dayNumber = week * 7 + day - firstWeekday + 1;

        if (dayNumber >= 1 && dayNumber <= daysInMonth) {
          final date = DateTime(now.year, now.month, dayNumber);
          final isToday = _isSameDay(date, now);
          final isPeriodDay = _isPeriodDay(date, cycles);
          final isFertile = _isFertileDay(date, cycles);

          rowChildren.add(
            Expanded(
              child: GestureDetector(
                onTap: () => _showDayDetails(context, date, cycles),
                child: Container(
                  margin: const EdgeInsets.all(2),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: isPeriodDay
                        ? const Color(0xFFE91E63)
                        : isFertile
                            ? Colors.green.withValues(alpha: 0.3)
                            : isToday
                                ? const Color(0xFF9C27B0)
                                : Colors.transparent,
                  ),
                  child: Center(
                    child: Text(
                      '$dayNumber',
                      style: TextStyle(
                        color: isPeriodDay
                            ? Colors.white
                            : isFertile
                                ? Colors.green
                                : isToday
                                    ? Colors.white
                                    : Colors.black87,
                        fontWeight: isToday || isPeriodDay
                            ? FontWeight.bold
                            : FontWeight.normal,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        } else {
          rowChildren.add(const Expanded(child: SizedBox()));
        }
      }

      rows.add(Row(children: rowChildren));
    }

    return Column(children: rows);
  }

  Widget _buildLegend() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _LegendItem(
            color: const Color(0xFFE91E63),
            label: 'Period',
          ),
          _LegendItem(
            color: Colors.green,
            label: 'Fertile',
          ),
          _LegendItem(
            color: const Color(0xFF9C27B0),
            label: 'Today',
          ),
        ],
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  bool _isPeriodDay(DateTime date, List<PeriodCycle> cycles) {
    return cycles.any((cycle) {
      return date.isAfter(cycle.startDate.subtract(const Duration(days: 1))) &&
          (cycle.endDate == null
              ? date.isAtSameMomentAs(cycle.startDate)
              : date.isBefore(cycle.endDate!.add(const Duration(days: 1))));
    });
  }

  bool _isFertileDay(DateTime date, List<PeriodCycle> cycles) {
    if (cycles.isEmpty) return false;

    final latestCycle = cycles.reduce((a, b) =>
        b.startDate.isAfter(a.startDate) ? b : a);

    final fertileStart = latestCycle.startDate.add(Duration(days: latestCycle.cycleLength - 12));
    final fertileEnd = latestCycle.startDate.add(Duration(days: latestCycle.cycleLength - 6));

    return date.isAfter(fertileStart.subtract(const Duration(days: 1))) &&
        date.isBefore(fertileEnd.add(const Duration(days: 1)));
  }

  void _showDayDetails(BuildContext context, DateTime date, List<PeriodCycle> cycles) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('${date.day}/${date.month}/${date.year}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_isPeriodDay(date, cycles))
              const Text(
                'This day is marked as a period day.',
                style: TextStyle(color: Color(0xFFE91E63)),
              ),
            if (_isFertileDay(date, cycles))
              const Text(
                'This day is in the fertile window.',
                style: TextStyle(color: Colors.green),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  String _getMonthName(int month) {
    const months = [
      'January', 'February', 'March', 'April', 'May', 'June',
      'July', 'August', 'September', 'October', 'November', 'December'
    ];
    return months[month - 1];
  }
}

class _LegendItem extends StatelessWidget {
  final Color color;
  final String label;

  const _LegendItem({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 12),
        ),
      ],
    );
  }
}