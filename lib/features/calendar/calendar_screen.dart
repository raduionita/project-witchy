import 'package:flutter/material.dart';

import '../../utils/app_theme.dart';
import 'cycle_calendar.dart';

/// The Calendar tab: full-screen interactive cycle calendar.
class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.kMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Expanded(child: CycleCalendar()),
          ],
        ),
      ),
    );
  }
}