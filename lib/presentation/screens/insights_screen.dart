import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:witchy/presentation/providers/period_cycle_provider.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cycleProvider = context.watch<PeriodCycleProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Your Insights')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cycle Prediction',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildPredictionCard(context, cycleProvider.predictedNextStartDate),
            const SizedBox(height: 24),
            const Text(
              'Symptom Trends',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            _buildSymptomTrends(),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionCard(BuildContext context, DateTime? nextStartDate) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Your next cycle is predicted to start on:'),
            Text(
              nextStartDate != null
                  ? '${nextStartDate.day}/${nextStartDate.month}/${nextStartDate.year}'
                  : 'Not enough data for prediction',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSymptomTrends() {
    // This is a placeholder for the actual implementation.
    // In a real app, we would use context.watch<DailyLogProvider>().frequentSymptoms
    return const Card(
      child: Padding(
        padding: EdgeInsets.all(16.0),
        child: Text('Symptom trend visualization coming soon.'),
      ),
    );
  }
}
