import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cycle_provider.dart';
import '../providers/settings_provider.dart';
import '../utils/theme_colors.dart';
import '../widgets/cycle_info_card.dart';
import '../widgets/fertility_indicator.dart';
import '../widgets/quick_log_button.dart';
import 'period_entry_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          _buildAppBar(context),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildCycleInfo(context),
                  const SizedBox(height: 24),
                  _buildQuickActions(context),
                  const SizedBox(height: 24),
                  _buildFertilitySection(context),
                  const SizedBox(height: 24),
                  _buildUpcomingPredictions(context),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return SliverSafeArea(
      sliver: SliverAppBar(
        expandedHeight: 200,
        floating: false,
        pinned: true,
        backgroundColor: WitchyColors.primary,
        flexibleSpace: FlexibleSpaceBar(
          title: const Text(
            'Witchy',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 24,
            ),
          ),
          titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
          centerTitle: false,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined, color: Colors.white),
            onPressed: () {
              Navigator.pushNamed(context, '/profile');
            },
          ),
        ],
      ),
    );
  }

  Widget _buildCycleInfo(BuildContext context) {
    return Consumer<CycleProvider>(
      builder: (context, provider, child) {
        final activePeriod = provider.activePeriod;
        final avgCycleLength = provider.getAverageCycleLength();

        if (activePeriod != null) {
          final daysIntoPeriod = DateTime.now().difference(activePeriod.startDate).inDays + 1;
          return CycleInfoCard(
            phase: 'Period',
            dayNumber: daysIntoPeriod,
            totalDays: activePeriod.duration,
            isActive: true,
            flowIntensity: activePeriod.flowIntensity,
          );
        }

        final prediction = provider.predictNextCycle(settings: context.read<SettingsProvider>().settings);
        final daysUntilNext = prediction.predictedStartDate.difference(DateTime.now()).inDays;

        return CycleInfoCard(
          phase: 'Follicular Phase',
          dayNumber: avgCycleLength.toInt() - daysUntilNext,
          totalDays: avgCycleLength.toInt(),
          isActive: false,
          daysUntilNextPeriod: daysUntilNext,
        );
      },
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Quick Log',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: QuickLogButton(
                icon: Icons.local_hospital,
                label: 'Period',
                color: WitchyColors.periodColor,
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const PeriodEntryScreen()),
                  );
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: QuickLogButton(
                icon: Icons.favorite,
                label: 'Symptoms',
                color: WitchyColors.primary,
                onTap: () {
                  _showSymptomDialog(context);
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildFertilitySection(BuildContext context) {
    return Consumer<CycleProvider>(
      builder: (context, provider, child) {
        final isFertile = provider.isCurrentlyFertile;
        final daysUntilOvulation = provider.getDaysUntilOvulation(
          settings: context.read<SettingsProvider>().settings,
        );

        return FertilityIndicator(
          isFertile: isFertile,
          daysUntilOvulation: daysUntilOvulation,
        );
      },
    );
  }

  Widget _buildUpcomingPredictions(BuildContext context) {
    return Consumer<CycleProvider>(
      builder: (context, provider, child) {
        final prediction = provider.predictNextCycle(
          settings: context.read<SettingsProvider>().settings,
        );

        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Upcoming Predictions',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Expanded(
                      child: _buildPredictionItem(
                        context,
                        'Next Period',
                        '${prediction.predictedStartDate.month}/${prediction.predictedStartDate.day}',
                        WitchyColors.periodColor,
                      ),
                    ),
                    Expanded(
                      child: _buildPredictionItem(
                        context,
                        'Ovulation',
                        prediction.nextOvulationDate != null
                            ? '${prediction.nextOvulationDate!.month}/${prediction.nextOvulationDate!.day}'
                            : 'N/A',
                        WitchyColors.ovulationColor,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: prediction.predictionConfidence,
                  minHeight: 4,
                  backgroundColor: WitchyColors.borderColor,
                  valueColor: AlwaysStoppedAnimation(WitchyColors.primary),
                ),
                const SizedBox(height: 4),
                Text(
                  'Prediction confidence: ${(prediction.predictionConfidence * 100).toStringAsFixed(0)}%',
                  style: TextStyle(fontSize: 12, color: WitchyColors.lightText),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildPredictionItem(BuildContext context, String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: WitchyColors.lightText),
        ),
        const SizedBox(height: 4),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            value,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ),
      ],
    );
  }

  void _showSymptomDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Symptoms'),
        content: const Text('Symptom logging feature coming soon.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
