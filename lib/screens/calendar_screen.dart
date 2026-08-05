import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/cycle_provider.dart';
import '../models/cycle_model.dart';

/// Displays the menstrual cycle calendar with predictions and symptoms.
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _currentMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final cycleProvider = context.watch<CycleProvider>();
    final cycles = cycleProvider.allCycles;
    final today = DateTime.now();

    return Scaffold(
      appBar: AppBar(
        title: Text(
          DateFormat.yMMMM().format(_currentMonth),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.today),
            onPressed: () {
              setState(() {
                _currentMonth = DateTime.now();
              });
            },
          ),
        ],
      ),
      body: Column(
        children: [
          _buildMonthNavigation(),
          const SizedBox(height: 16),
          _buildCalendarHeader(),
          Expanded(child: _buildCalendarGrid(cycles, today)),
          _buildLegend(),
        ],
      ),
    );
  }

  Widget _buildMonthNavigation() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.chevron_left),
          onPressed: () {
            setState(() {
              _currentMonth = DateTime(
                _currentMonth.year,
                _currentMonth.month - 1,
              );
            });
          },
        ),
        Text(
          DateFormat.yMMMM().format(_currentMonth),
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        IconButton(
          icon: const Icon(Icons.chevron_right),
          onPressed: () {
            setState(() {
              _currentMonth = DateTime(
                _currentMonth.year,
                _currentMonth.month + 1,
              );
            });
          },
        ),
      ],
    );
  }

  Widget _buildCalendarHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        children: ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'].map(
          (day) => Expanded(
            child: Center(
              child: Text(
                day,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 12,
                ),
              ),
            ),
          ),
        ).toList(),
      ),
    );
  }

  Widget _buildCalendarGrid(List<CycleModel> cycles, DateTime today) {
    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month);
    final lastDayOfMonth = DateTime(
      _currentMonth.year,
      _currentMonth.month + 1,
    );
    final startDayOfWeek = firstDayOfMonth.weekday % 7;
    final daysInMonth = lastDayOfMonth
          .difference(firstDayOfMonth)
          .inDays;

    final cells = <Widget>[];

    // Empty cells for days before the first of the month
    for (var i = 0; i < startDayOfWeek; i++) {
      cells.add(const SizedBox.shrink());
    }

    // Day cells
    for (var day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, day);
      final isToday = DateFormat.yMd().format(date) ==
          DateFormat.yMd().format(today);

      final cycleInfo = _getCycleInfoForDate(cycles, date);

      cells.add(
        Padding(
          padding: const EdgeInsets.all(4),
          child: _buildDayCell(
            date: date,
            isToday: isToday,
            cycleInfo: cycleInfo,
          ),
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(8),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
        childAspectRatio: 1,
      ),
      itemCount: cells.length,
      itemBuilder: (context, index) => cells[index],
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
    );
  }

  Widget _buildDayCell({
    required DateTime date,
    required bool isToday,
    required CycleInfo? cycleInfo,
  }) {
    return Container(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: isToday
            ? const Color(0xFF6A0572)
            : cycleInfo?.isPeriod == true
                ? Colors.red.shade100
                : cycleInfo?.isFertile == true
                    ? Colors.green.shade100
                    : Colors.transparent,
        border: isToday
            ? Border.all(color: Colors.white, width: 2)
            : null,
      ),
      child: Center(
        child: Text(
          '${date.day}',
          style: TextStyle(
            color: isToday
                ? Colors.white
                : cycleInfo?.isPeriod == true
                    ? Colors.red.shade800
                    : cycleInfo?.isFertile == true
                        ? Colors.green.shade800
                        : Colors.black87,
            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  CycleInfo? _getCycleInfoForDate(List<CycleModel> cycles, DateTime date) {
    for (final cycle in cycles) {
      if (cycle.isPeriodDay(date)) {
        return const CycleInfo(isPeriod: true, isFertile: false);
      }
      if (cycle.isFertile(date)) {
        return const CycleInfo(isPeriod: false, isFertile: true);
      }
    }
    return null;
  }

  Widget _buildLegend() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _legendItem(color: Colors.red.shade100, label: 'Period'),
          const SizedBox(width: 16),
          _legendItem(color: Colors.green.shade100, label: 'Fertile'),
          const SizedBox(width: 16),
          _legendItem(
            color: const Color(0xFF6A0572),
            label: 'Today',
          ),
        ],
      ),
    );
  }

  Widget _legendItem({required Color color, required String label}) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}

/// Helper class to hold cycle information for a date.
class CycleInfo {
  final bool isPeriod;
  final bool isFertile;
  const CycleInfo({required this.isPeriod, required this.isFertile});
}