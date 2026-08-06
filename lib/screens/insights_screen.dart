import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/period_cycle.dart';
import '../providers/period_provider.dart';
import '../providers/fertility_provider.dart';

class InsightsScreen extends StatelessWidget {
  const InsightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer2<PeriodProvider, FertilityProvider>(
      builder: (context, periodProvider, fertilityProvider, _) {
        return Scaffold(
          appBar: AppBar(
            title: const Text('Insights'),
            backgroundColor: const Color(0xFF9C27B0),
            foregroundColor: Colors.white,
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCycleOverview(periodProvider),
                const SizedBox(height: 24),
                _buildFertilityInsights(fertilityProvider),
                const SizedBox(height: 24),
                _buildSymptomPatterns(periodProvider),
                const SizedBox(height: 24),
                _buildHealthTips(),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCycleOverview(PeriodProvider periodProvider) {
    final cycles = periodProvider.cycles;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Cycle Overview',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          if (cycles.isEmpty)
            const Text(
              'No cycle data available. Start logging your periods to see insights.',
              style: TextStyle(color: Colors.grey),
            )
          else
            Column(
              children: [
                _buildStatCard('Average Cycle', '${_getAverageCycleLength(cycles)} days'),
                _buildStatCard('Longest Cycle', '${_getLongestCycle(cycles)} days'),
                _buildStatCard('Shortest Cycle', '${_getShortestCycle(cycles)} days'),
                _buildStatCard('Total Cycles', '${cycles.length}'),
              ],
            ),
        ],
      ),
    );
  }

  Widget _buildFertilityInsights(FertilityProvider fertilityProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Fertility Insights',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          if (fertilityProvider.isCurrentlyFertile())
            _buildInsightCard(
              icon: Icons.star,
              title: 'Fertile Window',
              subtitle: 'You are currently in your most fertile days',
              color: Colors.green,
            )
          else if (fertilityProvider.isCurrentlyOvulating())
            _buildInsightCard(
              icon: Icons.bolt,
              title: 'Ovulation',
              subtitle: 'You may be ovulating right now',
              color: Colors.orange,
            )
          else
            _buildInsightCard(
              icon: Icons.schedule,
              title: 'Next Fertile Window',
              subtitle: 'Check your predictions for upcoming dates',
              color: Colors.grey,
            ),
        ],
      ),
    );
  }

  Widget _buildSymptomPatterns(PeriodProvider periodProvider) {
    final symptoms = periodProvider.symptoms;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Symptom Patterns',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          if (symptoms.isEmpty)
            const Text(
              'No symptoms logged yet. Start logging to see patterns.',
              style: TextStyle(color: Colors.grey),
            )
          else
            Column(
              children: _getMostCommonSymptoms(symptoms).take(5).map((symptom) {
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: Icon(Icons.circle, size: 12, color: const Color(0xFF9C27B0)),
                  title: Text(symptom.$1),
                  trailing: Text(
                    '${symptom.$2} times',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  ),
                );
              }).toList(),
            ),
        ],
      ),
    );
  }

  Widget _buildHealthTips() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Health Tips',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          const _HealthTip(
            title: 'Stay Hydrated',
            description: 'Drink at least 8 glasses of water daily, especially during your period.',
          ),
          const _HealthTip(
            title: 'Regular Exercise',
            description: 'Light exercise can help reduce cramps and improve mood.',
          ),
          const _HealthTip(
            title: 'Balanced Diet',
            description: 'Eat iron-rich foods to compensate for blood loss during menstruation.',
          ),
          const _HealthTip(
            title: 'Adequate Sleep',
            description: ' aim for 7-9 hours of quality sleep each night.',
          ),
        ],
      ),
    );
  }

  List<(String, int)> _getMostCommonSymptoms(List symptoms) {
    final Map<String, int> symptomCounts = {};
    for (final symptom in symptoms) {
      final name = symptom.type.toString().split('.').last;
      symptomCounts[name] = (symptomCounts[name] ?? 0) + 1;
    }
    return symptomCounts.entries
        .map((e) => (e.key, e.value))
        .toList()
      ..sort((a, b) => b.$2.compareTo(a.$2));
  }

  int _getAverageCycleLength(List<PeriodCycle> cycles) {
    if (cycles.isEmpty) return 28;
    int total = 0;
    int count = 0;
    for (final cycle in cycles) {
      if (cycle.endDate != null) {
        total += cycle.endDate!.difference(cycle.startDate).inDays;
        count++;
      }
    }
    return count > 0 ? (total / count).round() : 28;
  }

  int _getLongestCycle(List<PeriodCycle> cycles) {
    if (cycles.isEmpty) return 28;
    int max = 0;
    for (final cycle in cycles) {
      if (cycle.endDate != null) {
        final length = cycle.endDate!.difference(cycle.startDate).inDays;
        if (length > max) max = length;
      }
    }
    return max > 0 ? max : 28;
  }

  int _getShortestCycle(List<PeriodCycle> cycles) {
    if (cycles.isEmpty) return 28;
    int min = 999;
    for (final cycle in cycles) {
      if (cycle.endDate != null) {
        final length = cycle.endDate!.difference(cycle.startDate).inDays;
        if (length < min) min = length;
      }
    }
    return min < 999 ? min : 28;
  }

  Widget _buildStatCard(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(color: Colors.grey),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInsightCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
  }) {
    return Row(
      children: [
        Icon(icon, color: color, size: 32),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
              Text(
                subtitle,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _HealthTip extends StatelessWidget {
  final String title;
  final String description;

  const _HealthTip({required this.title, required this.description});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.lightbulb,
            color: Color(0xFF9C27B0),
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  description,
                  style: TextStyle(color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}