// Pregnancy tracker screen - manage pregnancy information

import 'package:flutter/material.dart';
import '../models/cycle_models.dart';
import '../providers/cycle_tracker_provider.dart';

class PregnancyScreen extends StatelessWidget {
  const PregnancyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tracker = Provider.of<CycleTrackerProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Pregnancy Tracker'), backgroundColor: AppColors.secondary),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildPregnancyStatus(context, tracker),
            const SizedBox(height: 24),
            _buildFertilityWindow(context, tracker),
          ],
        ),
      ),
    );
  }

  Widget _buildPregnancyStatus(BuildContext context, CycleTrackerProvider tracker) {
    if (!tracker.hasPregnancyInfo) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Icon(Icons.pregnancy, size: 48),
              const SizedBox(height: 16),
              Text('No pregnancy tracked', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.primary)),
              const SizedBox(height: 8),
              Text('Tap below to start tracking your pregnancy journey', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _addPregnancy(context, tracker),
                child: const Text('Start Tracking'),
              ),
            ],
          ),
        ),
      );
    }

    final pregnancy = tracker.pregnancyInfo!;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('Week ${pregnancy.currentWeek}', style: Theme.of(context).textTheme.headlineSmall?.copyWith(color: AppColors.primary)),
                Text(pregnancy.trimester, style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.secondary)),
              ],
            ),
            const SizedBox(height: 16),
            _buildPregnancyDetails(pregnancy),
          ],
        ),
      ),
    );
  }

  Widget _buildFertilityWindow(BuildContext context, CycleTrackerProvider tracker) {
    if (!tracker.hasPregnancyInfo) return const SizedBox();

    final predictions = tracker.predictions;
    if (predictions == null) return const SizedBox();

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Fertility Window', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.secondary)),
            const SizedBox(height: 8),
            if (predictions.isFertileNow)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.secondaryLight, borderRadius: BorderRadius.circular(AppTheme.radiusMedium)),
                child: Text('You are currently fertile! 🌸', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.secondary)),
              ) else
              Text('Fertile window: ${predictions.nextOvulation} days from now', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.secondary)),
          ],
        ),
      ),
    );
  }

  void _addPregnancy(BuildContext context, CycleTrackerProvider tracker) {
    final lastPeriod = DateTime.now().subtract(const Duration(days: 15)); // Mock last period
    final dueDate = DateTime.now().add(const Duration(days: 280)); // ~40 weeks
    final currentWeek = 1;

    tracker.setPregnancyInfo(PregnancyInfo(
      lastMenstrualPeriod: lastPeriod,
      dueDate: dueDate,
      currentWeek: currentWeek,
    ));

    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Pregnancy tracking started!')));
  }

}
