/// Period entry card widget for Witchy.
/// Displays a single logged period entry with symptoms and mood info.
library;

import 'package:flutter/material.dart';
import '../models/period_entry.dart';

/// Card displaying a single logged period entry.
class PeriodEntryCardWidget extends StatelessWidget {
  const PeriodEntryCardWidget({super.key, required this.entry});

  /// The period entry to display.
  final PeriodEntry entry;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Date and flow.
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Started ${entry.startDate.day}/${entry.startDate.month}',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                Chip(
                  label: Text(entry.flowLabel),
                  avatar: Icon(_getFlowIcon(entry.flow)),
                ),
              ],
            ),

            if (entry.endDate != null) ...[
              const SizedBox(height: 4),
              Text(
                'Duration: ${entry.durationDays} days',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],

            // Symptoms.
            if (entry.symptoms.isNotEmpty) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 4,
                runSpacing: 4,
                children: entry.symptoms.map((symptom) {
                  return Chip(
                    label: Text(symptom),
                    visualDensity: VisualDensity.compact,
                  );
                }).toList(),
              ),
            ],

            // Mood.
            if (entry.mood != Mood.neutral) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(Icons.sentiment_satisfied_alt, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    'Mood: ${entry.mood.name}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
            ],

            // Delete button.
            const SizedBox(height: 12),
            Align(
              alignment: Alignment.bottomRight,
              child: TextButton.icon(
                onPressed: () {
                  // Delete callback placeholder.
                },
                icon: const Icon(Icons.delete_outline, size: 16),
                label: const Text('Delete'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getFlowIcon(FlowIntensity flow) {
    switch (flow) {
      case FlowIntensity.light:
        return Icons.water_drop;
      case FlowIntensity.moderate:
        return Icons.water;
      case FlowIntensity.heavy:
        return Icons.water;
      case FlowIntensity.spotting:
        return Icons.near_me;
    }
  }
}
