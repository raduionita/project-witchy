/// Calendar screen for Witchy.
/// Displays a full month calendar with colored dots indicating periods, fertile window, and ovulation.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tracking_provider.dart';

/// Calendar screen showing a month grid with period/fertile window coloring.
class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  late DateTime _currentMonth;
  late int _selectedDay;

  static const List<String> kWeekdayLabels = [
    'Mon',
    'Tue',
    'Wed',
    'Thu',
    'Fri',
    'Sat',
    'Sun',
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _currentMonth = DateTime(now.year, now.month, 1);
    _selectedDay = now.day;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              // Month navigation.
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: _previousMonth,
                  ),
                  Text(
                    '${_currentMonth.month}/${_currentMonth.year}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: _nextMonth,
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Legend.
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildLegendItem(Theme.of(context).colorScheme.error, 'Period'),
                  _buildLegendItem(const Color(0xFF9C27B0), 'Fertile'),
                  _buildLegendItem(const Color(0xFFFFC107), 'Ovulation'),
                ],
              ),

              const SizedBox(height: 16),

              // Weekday headers.
              Row(
                children: kWeekdayLabels.map((label) {
                  return Expanded(
                    child: Center(
                      child: Text(
                        label,
                        style: Theme.of(context).textTheme.labelMedium,
                      ),
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 8),

              // Calendar grid.
              Expanded(
                child: Consumer<TrackingProvider>(
                  builder: (context, provider, child) {
                    return _buildCalendarGrid(context, provider);
                  },
                ),
              ),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendItem(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 8, height: 8, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 4),
        Text(label, style: Theme.of(context).textTheme.bodyMedium),
      ],
    );
  }

  Widget _buildCalendarGrid(BuildContext context, TrackingProvider provider) {
    final firstDayOfMonth = DateTime(_currentMonth.year, _currentMonth.month, 1);
    final daysInMonth = _getDaysInMonth(_currentMonth.year, _currentMonth.month);

    // Day of week for the first day (Monday = 0, Sunday = 6).
    final firstDayOfWeek = ((firstDayOfMonth.weekday - 1 + 7) % 7);

    // Generate all cells: empty padding + days.
    final List<Widget> cells = [];

    // Empty cells for padding before the 1st.
    for (int i = 0; i < firstDayOfWeek; i++) {
      cells.add(const SizedBox.shrink());
    }

    // Day cells.
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_currentMonth.year, _currentMonth.month, day);

      final isInPeriod = provider.isDateInPeriod(date);
      final isFertile = provider.isDateFertile(date);
      final isOvulation = provider.isDateOvulation(date);

      cells.add(
        Padding(
          padding: const EdgeInsets.all(2),
          child: _DayCell(
            day: day,
            isInPeriod: isInPeriod,
            isFertile: isFertile,
            isOvulation: isOvulation,
            isToday: date.day == DateTime.now().day &&
                date.month == DateTime.now().month &&
                date.year == DateTime.now().year,
            isSelected: day == _selectedDay &&
                _currentMonth.month == DateTime.now().month,
            onTap: () => setState(() => _selectedDay = day),
          ),
        ),
      );
    }

    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 7,
      ),
      itemCount: cells.length,
      itemBuilder: (context, index) => cells[index],
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
    );
  }

  int _getDaysInMonth(int year, int month) {
    return DateTime(year, month + 1, 0).day;
  }

  void _previousMonth() {
    setState(() {
      if (_currentMonth.month == 1) {
        _currentMonth = DateTime(_currentMonth.year - 1, 12);
      } else {
        _currentMonth = DateTime(_currentMonth.year, _currentMonth.month - 1);
      }
    });
  }

  void _nextMonth() {
    setState(() {
      if (_currentMonth.month == 12) {
        _currentMonth = DateTime(_currentMonth.year + 1, 1);
      } else {
        _currentMonth = DateTime(_currentMonth.year, _currentMonth.month + 1);
      }
    });
  }
}

/// Single day cell in the calendar grid.
class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.isInPeriod,
    required this.isFertile,
    required this.isOvulation,
    required this.isToday,
    required this.isSelected,
    required this.onTap,
  });

  final int day;
  final bool isInPeriod;
  final bool isFertile;
  final bool isOvulation;
  final bool isToday;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Determine the dot color based on priority: ovulation > period > fertile.
    Color? dotColor;
    if (isOvulation) {
      dotColor = const Color(0xFFFFC107);
    } else if (isInPeriod) {
      dotColor = Theme.of(context).colorScheme.error;
    } else if (isFertile) {
      dotColor = const Color(0xFF9C27B0);
    }

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          decoration: BoxDecoration(
            border: isSelected ? Border.all(color: Theme.of(context).colorScheme.primary, width: 2) : null,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Stack(
            alignment: Alignment.center,
            children: [
              Text(
                day.toString(),
                style: TextStyle(
                  color: isToday ? Theme.of(context).colorScheme.primary : null,
                  fontWeight: isToday ? FontWeight.bold : null,
                ),
              ),
              if (dotColor != null)
                Positioned(
                  bottom: 4,
                  child: Container(width: 6, height: 6, decoration: BoxDecoration(color: dotColor, shape: BoxShape.circle)),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
