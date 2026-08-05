/// Cycle indicator widget for Witchy.
/// Displays a circular progress ring showing the current cycle day.
library;

import 'package:flutter/material.dart';

/// Circular progress widget showing the current cycle day.
class CycleIndicatorWidget extends StatelessWidget {
  const CycleIndicatorWidget({super.key, required this.cycleDay, required this.totalDays});

  /// The current cycle day number.
  final int cycleDay;

  /// The total length of the cycle in days.
  final int totalDays;

  @override
  Widget build(BuildContext context) {
    final progress = (cycleDay / totalDays).clamp(0.0, 1.0);

    return SizedBox(
      width: 200,
      height: 200,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background circle.
          SizedBox(
            width: 200,
            height: 200,
            child: CircularProgressIndicator(
              value: 1.0,
              strokeWidth: 8,
              backgroundColor: Theme.of(context).colorScheme.surfaceContainerHighest,
            ),
          ),

          // Progress circle.
          SizedBox(
            width: 200,
            height: 200,
            child: CircularProgressIndicator(
              value: progress,
              strokeWidth: 8,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),

          // Center text.
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                '$cycleDay',
                style: Theme.of(context).textTheme.displayLarge,
              ),
              Text(
                'of $totalDays',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
