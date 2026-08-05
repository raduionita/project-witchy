// Calendar screen - visual calendar view of cycles

import 'package:flutter/material.dart';
import '../utils/constants.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cycle Calendar'), backgroundColor: AppColors.primary),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildMonthHeader(context),
            const SizedBox(height: 16),
            Expanded(
              child: _buildCalendarGrid(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthHeader(BuildContext context) {
    const monthText = 'July 2026';
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Icon(Iconschevron_left),
        SizedBox(width: 16),
        Text(monthText, style: Theme.of(context).textTheme.titleLarge?.copyWith(color: AppColors.primary)),
        SizedBox(width: 16),
        const Icon(Iconschevron_right),
      ],
    );
  }

  Widget _buildCalendarGrid(BuildContext context) {
    return GridView.builder(
      gridDelegate: const GridDataBuilder(
        crossAxisCount: 7, // Days of the week
        mainAxisSize: MainAxisSize.min,
        crossAxisMaximumExtent: 100,
      ),
      itemCount: 35, // 5 weeks
      itemBuilder: (context, index) {
        final isWeekStart = index % 7 == 0;
        final dayNumber = (index / 7).floor() + ((isWeekStart ? index : index - 6) % 7);
        final dateText = dayNumber.toString();

        return _buildCalendarCell(dateText, index);
      },
    );
  }

  Widget _buildCalendarCell(String day, int index) {
    bool isPeriod = false; // Mock data - would come from tracker service
    bool isFertile = false;

    return Padding(
      padding: const EdgeInsets.all(4.0),
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isPeriod ? AppColors.primary : AppColors.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMedium),
        ),
        child: Text(day, style: TextStyle(color: isPeriod ? Colors.white : AppColors.textPrimary)),
      ),
    );
  }

}
