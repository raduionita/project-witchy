import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/period_provider.dart';
import '../providers/fertility_provider.dart';
import '../providers/pregnancy_provider.dart';
import '../models/period_cycle.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer3<PeriodProvider, FertilityProvider, PregnancyProvider>(
      builder: (context, periodProvider, fertilityProvider, pregnancyProvider, _) {
        final profile = context.read<PeriodProvider>();
        final cycles = profile.cycles;
        final currentCycle = profile.currentCycle;

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                floating: false,
                pinned: true,
                backgroundColor: const Color(0xFF9C27B0),
                flexibleSpace: FlexibleSpaceBar(
                  title: const Text(
                    'Witchy',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  titlePadding: const EdgeInsets.only(left: 16, bottom: 16),
                  centerTitle: false,
                ),
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCycleInfoCard(cycles, currentCycle),
                      const SizedBox(height: 16),
                      _buildQuickActions(context),
                      const SizedBox(height: 16),
                      _buildCycleCalendar(cycles),
                      const SizedBox(height: 16),
                      _buildInsightsSection(fertilityProvider),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildCycleInfoCard(List cycles, currentCycle) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF9C27B0), Color(0xFFE91E63)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Your Cycle',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          if (currentCycle != null)
            Text(
              'Day ${_getCycleDay(currentCycle)} of ${currentCycle.cycleLength}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            )
          else
            const Text(
              'No active cycle',
              style: TextStyle(
                fontSize: 18,
                color: Colors.white70,
              ),
            ),
          const SizedBox(height: 8),
          Text(
            _getCyclePhase(currentCycle),
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        _QuickActionTile(
          icon: Icons.add_circle,
          label: 'Log Period',
          color: const Color(0xFFE91E63),
          onTap: () => Navigator.of(context).pushNamed('/log-period'),
        ),
        const SizedBox(width: 12),
        _QuickActionTile(
          icon: Icons.heart_broken,
          label: 'Log Symptom',
          color: const Color(0xFF9C27B0),
          onTap: () => Navigator.of(context).pushNamed('/log-symptom'),
        ),
        const SizedBox(width: 12),
        _QuickActionTile(
              icon: Icons.favorite,
              label: 'Log Mood',
          color: const Color(0xFF673AB7),
          onTap: () => Navigator.of(context).pushNamed('/log-mood'),
        ),
      ],
    );
  }

  Widget _buildCycleCalendar(List cycles) {
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
            'Recent Cycles',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          if (cycles.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 8),
              child: Text(
                'No cycles recorded yet. Start tracking by logging your first period.',
                style: TextStyle(color: Colors.grey),
              ),
            )
          else
            ...cycles.take(5).map((cycle) => _CycleRow(cycle: cycle)),
        ],
      ),
    );
  }

  Widget _buildInsightsSection(FertilityProvider fertilityProvider) {
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
            'Insights',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          if (fertilityProvider.isCurrentlyFertile())
            _InsightTile(
              icon: Icons.star,
              title: 'Fertile Window',
              subtitle: 'You are currently in your fertile window',
              color: const Color(0xFF4CAF50),
            )
          else if (fertilityProvider.isCurrentlyOvulating())
            _InsightTile(
              icon: Icons.bolt,
              title: 'Ovulation',
              subtitle: 'You may be ovulating right now',
              color: const Color(0xFFFF9800),
            )
          else
            _InsightTile(
              icon: Icons.info,
              title: 'Next fertile window',
              subtitle: 'Check your fertility predictions for upcoming dates',
              color: Colors.grey[600]!,
            ),
        ],
      ),
    );
  }

  int _getCycleDay(PeriodCycle cycle) {
    final now = DateTime.now();
    return now.difference(cycle.startDate).inDays + 1;
  }

  String _getCyclePhase(PeriodCycle cycle) {
    final day = _getCycleDay(cycle);
    if (day <= cycle.cycleLengthDays * 0.2) return 'Menstruation Phase';
    if (day <= cycle.cycleLengthDays * 0.5) return 'Follicular Phase';
    if (day <= cycle.cycleLengthDays * 0.7) return 'Ovulation Phase';
    return 'Luteal Phase';
  }
}

class _QuickActionTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionTile({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CycleRow extends StatelessWidget {
  final PeriodCycle cycle;

  const _CycleRow({required this.cycle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 40,
            decoration: BoxDecoration(
              color: const Color(0xFFE91E63),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Cycle ${cycle.cycleLength} days',
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                Text(
                  '${_formatDate(cycle.startDate)} - ${_formatDate(cycle.endDate ?? cycle.startDate)}',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Icon(
            Icons.chevron_right,
            color: Colors.grey[400],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

class _InsightTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;

  const _InsightTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 24),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
              Text(
                subtitle,
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
              ),
            ],
          ),
        ),
      ],
    );
  }
}