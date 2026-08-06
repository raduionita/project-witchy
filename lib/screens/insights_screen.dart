import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cycle_provider.dart';
import '../utils/cycle_calculator.dart';
import '../models/period_cycle.dart';

class InsightsScreen extends StatefulWidget {
  const InsightsScreen({super.key});

  @override
  State<InsightsScreen> createState() => _InsightsScreenState();
}

class _InsightsScreenState extends State<InsightsScreen> {
  @override
  Widget build(BuildContext context) {
    final cycles = context.watch<CycleProvider>().cycles;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Insights'),
      ),
      body: cycles.isEmpty
          ? _buildEmptyState()
          : RefreshIndicator(
              onRefresh: () => context.read<CycleProvider>().loadCycles(),
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _buildCycleSummary(cycles),
                  const SizedBox(height: 16),
                  _buildFertilityInsights(cycles),
                  const SizedBox(height: 16),
                  _buildPredictions(cycles),
                  const SizedBox(height: 16),
                  _buildSymptomPatterns(cycles),
                ],
              ),
            ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.insights, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'No Data Yet',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'Start tracking your cycles to see insights and predictions',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCycleSummary(List<PeriodCycle> cycles) {
    final avgCycleLength = CycleCalculator.calculateFertileWindowStart(cycles) + 14;
    final avgPeriodDuration = cycles.fold<double>(0, (sum, c) => sum + c.periodDuration) / cycles.length;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Cycle Summary',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildSummaryItem('Avg. Cycle', '${avgCycleLength.toInt()} days'),
                _buildSummaryItem('Avg. Period', '${avgPeriodDuration.toStringAsFixed(1)} days'),
                _buildSummaryItem('Cycles Tracked', '${cycles.length}'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.deepPurple)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey)),
      ],
    );
  }

  Widget _buildFertilityInsights(List<PeriodCycle> cycles) {
    final fertileStart = CycleCalculator.calculateFertileWindowStart(cycles);
    final fertileEnd = CycleCalculator.calculateFertileWindowEnd(cycles);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Fertility Window',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.pink.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Icon(Icons.female, color: Colors.pink),
                      Text(
                        'Days ${fertileStart.toInt()} - ${fertileEnd.toInt()}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Your most fertile days are typically around day 12-16 of your cycle',
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictions(List<PeriodCycle> cycles) {
    if (cycles.isEmpty) return const SizedBox.shrink();

    final lastCycle = cycles.last;
    final nextPeriod = CycleCalculator.calculateNextPeriodDate(lastCycle.startDate, lastCycle.cycleLength);
    final nextOvulation = CycleCalculator.calculateNextOvulationDate(lastCycle.startDate, lastCycle.cycleLength);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Predictions',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ListTile(
              leading: const Icon(Icons.calendar_today, color: Colors.deepPurple),
              title: const Text('Next Period'),
              subtitle: Text(nextPeriod?.toString().split(' ').first ?? 'N/A'),
              trailing: const Icon(Icons.chevron_right),
            ),
            const Divider(),
            ListTile(
              leading: const Icon(Icons.favorite, color: Colors.pink),
              title: const Text('Next Ovulation'),
              subtitle: Text(nextOvulation?.toString().split(' ').first ?? 'N/A'),
              trailing: const Icon(Icons.chevron_right),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSymptomPatterns(List<PeriodCycle> cycles) {
    final symptomCounts = <String, int>{};
    for (final cycle in cycles) {
      for (final symptom in cycle.symptoms) {
        symptomCounts[symptom.name] = (symptomCounts[symptom.name] ?? 0) + 1;
      }
    }

    if (symptomCounts.isEmpty) {
      return Card(
        elevation: 2,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Symptom Patterns',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              const Text(
                'Log symptoms during your cycles to see patterns',
                style: TextStyle(color: Colors.grey),
              ),
            ],
          ),
        ),
      );
    }

    final sortedSymptoms = symptomCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Most Common Symptoms',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...sortedSymptoms.take(5).map((entry) {
              final percentage = (entry.value / cycles.length * 100).toInt();
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                      child: Text(entry.key),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$percentage%',
                        style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple),
                      ),
                    ),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}
