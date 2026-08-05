/// Health insights screen - display cycle predictions and health information

import 'package:flutter/material.dart';
import '../models/cycle_models.dart';
import '../providers/cycle_tracker_provider.dart';

class HealthInsightsScreen extends StatelessWidget {
  const HealthInsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tracker = Provider.of<CycleTrackerProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Health Insights'), backgroundColor: AppColors.primary),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildCyclePredictionCard(context, tracker),
            const SizedBox(height: 24),
            _buildCycleLengthCard(context, tracker),
          ],
        ),
      ),
    );
  }

  Widget _buildCyclePredictionCard(BuildContext context, CycleTrackerProvider tracker) {
    final predictions = tracker.predictions;
    if (predictions == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Icon(Icons.info, size: 48),
              const SizedBox(height: 16),
              Text('Track a few cycles for personalized predictions', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cycle Predictions', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.primary)),
            const SizedBox(height: 16),
            _buildPredictionItem('Next Period', 'Starts in ${predictions.nextPeriodStart} days'),
            _buildPredictionItem('Next Ovulation', 'Expected in ${predictions.nextOvulation} days'),
            if (predictions.isFertileNow)
              Container(
                margin: const EdgeInsets.only(top: 12),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(color: AppColors.secondaryLight, borderRadius: BorderRadius.circular(AppTheme.radiusMedium)),
                child: Text('🌸 You are currently fertile!', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.secondary)),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionItem(String title, String subtitle) {
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(color: AppColors.primary, shape: BoxShape.circle),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: Theme.of(context).textTheme.titleSmall?.copyWith(color: AppColors.primary)),
              Text(subtitle, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildCycleLengthCard(BuildContext context, CycleTrackerProvider tracker) {
    final summary = tracker.monthlySummary;
    if (summary == null || summary.averageLength == null) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              const Icon(Icons.auto_aviation, size: 48),
              const SizedBox(height: 16),
              Text('Track a few cycles for personalized insights', style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary)),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Cycle Length', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.primary)),
            const SizedBox(height: 16),
            Text('${summary.averageCycleLength} days (average)', style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.primary)),
            const SizedBox(height: 8),
            Text('Shortest: ${summary.shortestCycle} days', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 4),
            Text('Longest: ${summary.longestCycle} days', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary)),
            const SizedBox(height: 12),
            if (summary.isRegular)
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppColors.success, borderRadius: BorderRadius.circular(AppTheme.radiusMedium)),
                child: Text('✅ Your cycle appears to be regular', style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white)),
              ),
          ],
        ),
      ),
    );
  }

}
