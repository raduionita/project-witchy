import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cycle_provider.dart';
import '../models/period_cycle.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _currentMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final cycles = context.watch<CycleProvider>().cycles;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '${_getMonthName(_currentMonth.month)} ${_currentMonth.year}',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
              });
            },
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
              });
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _buildWeekdayHeaders(),
            const SizedBox(height: 8),
            Expanded(child: _buildCalendarGrid(cycles)),
            const SizedBox(height: 16),
            _buildLegend(),
          ],
        ),
      ),
    );
  }

  Widget _buildWeekdayHeaders() {
    final weekdays = ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: weekdays.map((day) {
        return Container(
          width: 40,
          alignment: Alignment.center,
          child: Text(
            day,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.grey,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildCalendarGrid(List<PeriodCycle> cycles) {
    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final lastDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month + 1, 0);
    final startingWeekday = firstDayOfMonth.weekday % 7;
    final daysInMonth = lastDayOfMonth.day;

    final calendarDays = <DateTime>[];
    for (int i = 0; i < startingWeekday; i++) {
      calendarDays.add(DateTime(_currentMonth.year, _currentMonth.month, 1 - (startingWeekday - i)));
    }
    for (int i = 1; i <= daysInMonth; i++) {
      calendarDays.add(DateTime(_currentMonth.year, _currentMonth.month, i));
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        crossAxisSpacing: 4,
        mainAxisSpacing: 4,
      ),
      itemCount: calendarDays.length,
      itemBuilder: (context, index) {
        final day = calendarDays[index];
        final isCurrentMonth = day.month == _currentMonth.month;
        final isInPeriod = _isInPeriod(day, cycles);
        final isToday = _isSameDay(day, DateTime.now());

        return Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: isInPeriod ? Colors.pink.shade100 : null,
          ),
          child: Center(
            child: Text(
              '${day.day}',
              style: TextStyle(
                color: isCurrentMonth ? (isToday ? Colors.white : Colors.black) : Colors.grey,
                fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
        );
      },
    );
  }

  bool _isInPeriod(DateTime day, List<PeriodCycle> cycles) {
    for (final cycle in cycles) {
      final startDate = cycle.startDate;
      final endDate = cycle.endDate ?? startDate.add(Duration(days: cycle.periodDuration.toInt()));
      if (day.isAfter(startDate.subtract(const Duration(days: 1))) &&
          day.isBefore(endDate.add(const Duration(days: 1)))) {
        return true;
      }
    }
    return false;
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }

  Widget _buildLegend() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: Colors.pink.shade100,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        const Text('Period'),
        const SizedBox(width: 16),
        Container(
          width: 16,
          height: 16,
          decoration: const BoxDecoration(
            color: Colors.deepPurple,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        const Text('Today'),
      ],
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
