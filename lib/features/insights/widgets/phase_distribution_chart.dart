import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import '../../../models/cycle_phase.dart';
import '../../../models/symptom_insights.dart';

/// Donut chart showing how often a symptom appears in each cycle phase.
class PhaseDistributionChart extends StatelessWidget {
  const PhaseDistributionChart({super.key, required this.breakdown});

  final SymptomPhaseBreakdown breakdown;

  static const Map<CyclePhase, Color> kPhaseColors = <CyclePhase, Color>{
    CyclePhase.menstruation: Color(0xFFE74C3C),
    CyclePhase.follicular: Color(0xFFF39C12),
    CyclePhase.ovulatory: Color(0xFF27AE60),
    CyclePhase.luteal: Color(0xFF8E44AD),
  };

  @override
  Widget build(BuildContext context) {
    final List<CyclePhase> present = breakdown.byPhase.keys.toList();
    if (present.isEmpty) {
      return SizedBox(
        height: 180,
        child: Center(
          child: Text(
            'No phase data yet for this symptom.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.outline,
                ),
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 180,
            child: PieChart(
              PieChartData(
                centerSpaceRadius: 44,
                sectionsSpace: 3,
                sections: [
                  for (final CyclePhase phase in CyclePhase.values)
                    if ((breakdown.byPhase[phase] ?? 0) > 0)
                      PieChartSectionData(
                        value: breakdown.byPhase[phase]!.toDouble(),
                        color: kPhaseColors[phase],
                        radius: 52,
                        showTitle: false,
                      ),
                ],
              ),
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              for (final CyclePhase phase in CyclePhase.values)
                if ((breakdown.byPhase[phase] ?? 0) > 0) _legendRow(context, phase),
            ],
          ),
        ),
      ],
    );
  }

  Widget _legendRow(BuildContext context, CyclePhase phase) {
    final int count = breakdown.byPhase[phase] ?? 0;
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: kPhaseColors[phase],
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              _phaseLabel(phase),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          Text(
            '$count',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
          ),
        ],
      ),
    );
  }

  String _phaseLabel(CyclePhase phase) => switch (phase) {
        CyclePhase.menstruation => 'Menstrual',
        CyclePhase.follicular => 'Follicular',
        CyclePhase.ovulatory => 'Ovulation',
        CyclePhase.luteal => 'Luteal',
      };
}
