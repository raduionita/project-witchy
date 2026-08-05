/// Home dashboard screen for Witchy.
/// Shows current cycle day, countdown to next period, and quick actions.
library;

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/tracking_provider.dart';

/// Home dashboard screen showing cycle status and quick actions.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header.
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Witchy',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  Consumer<TrackingProvider>(
                    builder: (context, provider, child) {
                      return IconButton(
                        icon: Icon(provider.userProfile.notificationsEnabled
                            ? Icons.notifications
                            : Icons.notifications_off),
                        onPressed: () {
                          // Toggle notifications placeholder.
                        },
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 32),

              // Cycle day indicator (calls tracking provider).
              Center(
                child: Consumer<TrackingProvider>(
                  builder: (context, provider, child) {
                    final cycleDay = provider.getCurrentCycleDay();

                    if (cycleDay == null) {
                      return Column(
                        children: [
                          const Icon(Icons.self_improvement, size: 80),
                          const SizedBox(height: 16),
                          Text(
                            'Log your first period',
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Track your cycle to get started',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      );
                    }

                    return Column(
                      children: [
                        // Large cycle day number.
                        Text(
                          'Day $cycleDay',
                          style: Theme.of(context).textTheme.displayLarge,
                        ),
                        Text(
                          'of ${provider.userProfile.cycleLengthDays}',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                      ],
                    );
                  },
                ),
              ),

              const SizedBox(height: 8),

              // Countdown to next period.
              Center(
                child: Consumer<TrackingProvider>(
                  builder: (context, provider, child) {
                    final daysUntil = provider.getDaysUntilNextPeriod();

                    if (daysUntil == null) {
                      return Text(
                        'Your period may have started',
                        style: Theme.of(context).textTheme.bodyMedium,
                      );
                    }

                    return Text(
                      'Next period in ~$daysUntil days',
                      style: Theme.of(context).textTheme.bodyMedium,
                    );
                  },
                ),
              ),

              const Spacer(),

              // Quick action buttons.
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        // Navigate to log period.
                      },
                      icon: const Icon(Icons.fiber_manual_record),
                      label: const Text('Log Period'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        // Navigate to calendar.
                        _navigateToCalendar(context);
                      },
                      icon: const Icon(Icons.calendar_today),
                      label: const Text('Calendar'),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToCalendar(BuildContext context) {
    Navigator.of(context).pushNamed('/calendar');
  }
}
