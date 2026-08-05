import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cycle_provider.dart';
import '../providers/symptom_provider.dart';
import '../services/cycle_service.dart';
import '../models/cycle_model.dart';

/// The main home screen showing cycle overview, fertility status, and quick actions.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final cycleProvider = context.watch<CycleProvider>();
    final symptomProvider = context.watch<SymptomProvider>();

    final activeCycle = cycleProvider.activeCycle;
    final today = DateTime.now();

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                activeCycle != null
                    ? 'Cycle ${today.difference(activeCycle.startDate).inDays + 1}'
                    : 'Welcome to Witchy',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF6A0572),
                      Color(0xFFAB1D6B),
                      Color(0xFFE94057),
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    Positioned(
                      top: 40,
                      left: 20,
                      child: Text(
                        activeCycle != null
                            ? _getPhaseText(
                                CycleService.getPhase(
                                  activeCycle,
                                  today,
                                ),
                              )
                            : 'Track your cycle',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    if (activeCycle != null)
                      Positioned(
                        bottom: 20,
                        left: 20,
                        right: 20,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildStatusChip(
                              icon: Icons.cake,
                              label: 'Period',
                              value: '${_getPeriodDay(activeCycle, today)}d',
                            ),
                            _buildStatusChip(
                              icon: Icons.favorite,
                              label: 'Fertile',
                              value: activeCycle.isFertile(today)
                                  ? 'Yes'
                                  : 'No',
                            ),
                            _buildStatusChip(
                              icon: Icons.auto_awesome,
                              label: 'Ovulation',
                              value: activeCycle.isOvulationDay(today)
                                  ? 'Today!'
                                  : '${_daysUntilOvulation(activeCycle, today)}d',
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildQuickActions(context),
                  const SizedBox(height: 24),
                  _buildSymptomSummary(symptomProvider),
                  const SizedBox(height: 24),
                  _buildUpcomingInfo(cycleProvider),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusChip({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Column(
      children: [
        Icon(icon, color: Colors.white, size: 28),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Row(
      children: [
        _quickActionButton(
          icon: Icons.calendar_today,
          label: 'Log Period',
          color: const Color(0xFFE94057),
          onTap: () => _showPeriodLogDialog(context),
        ),
        const SizedBox(width: 12),
        _quickActionButton(
          icon: Icons.favorite,
          label: 'Log Symptom',
          color: const Color(0xFFAB1D6B),
          onTap: () => _showSymptomLogDialog(context),
        ),
        const SizedBox(width: 12),
        _quickActionButton(
          icon: Icons.pregnant_woman,
          label: 'Pregnancy',
          color: const Color(0xFF6A0572),
          onTap: () => Navigator.pushNamed(context, '/pregnancy'),
        ),
      ],
    );
  }

  Widget _quickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: Material(
        color: color,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Icon(icon, color: Colors.white, size: 32),
                const SizedBox(height: 8),
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSymptomSummary(SymptomProvider symptomProvider) {
    final frequency = symptomProvider.getSymptomFrequency();
    if (frequency.isEmpty) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'No symptoms logged yet. Start tracking to see patterns!',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    final topSymptoms = frequency.entries
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Recent Symptoms',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ...topSymptoms.take(5).map(
                  (e) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(_symptomTypeName(e.key)),
                        ),
                        Container(
                          width: 100,
                          height: 8,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade200,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: FractionallySizedBox(
                            alignment: Alignment.centerLeft,
                            widthFactor: e.value / 10.0,
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFAB1D6B),
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
          ],
        ),
      ),
    );
  }

  Widget _buildUpcomingInfo(CycleProvider cycleProvider) {
    final activeCycle = cycleProvider.activeCycle;
    if (activeCycle == null) {
      return const Card(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text(
            'No active cycle. Record your first period to get started!',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    final nextPeriod = activeCycle.nextCycleStart;
    final daysUntil = nextPeriod.difference(DateTime.now()).inDays;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Next Period',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              daysUntil > 0
                  ? 'Expected in $daysUntil days'
                  : 'Expected today',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'Based on your average ${cycleProvider.averageCycleLength}-day cycle',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getPhaseText(CyclePhase phase) {
    switch (phase) {
      case CyclePhase.menstruation:
        return 'Menstruation';
      case CyclePhase.follicular:
        return 'Follicular Phase';
      case CyclePhase.ovulation:
        return 'Ovulation';
      case CyclePhase.luteal:
        return 'Luteal Phase';
      case CyclePhase.preCycle:
        return 'Pre-Cycle';
    }
  }

  int _getPeriodDay(CycleModel cycle, DateTime date) {
    return date.difference(cycle.startDate).inDays + 1;
  }

  int _daysUntilOvulation(CycleModel cycle, DateTime date) {
    return cycle.ovulationDay.difference(date).inDays;
  }

  void _showPeriodLogDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Period'),
        content: const Text('Period logging feature coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSymptomLogDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Log Symptom'),
        content: const Text('Symptom logging feature coming soon!'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  String _symptomTypeName(SymptomType type) {
    switch (type) {
      case SymptomType.cramps:
        return 'Cramps';
      case SymptomType.headache:
        return 'Headache';
      case SymptomType.bloating:
        return 'Bloating';
      case SymptomType.breastTenderness:
        return 'Breast Tenderness';
      case SymptomType.fatigue:
        return 'Fatigue';
      case SymptomType.moodSwings:
        return 'Mood Swings';
      case SymptomType.acne:
        return 'Acne';
      case SymptomType.backache:
        return 'Backache';
      case SymptomType.nausea:
        return 'Nausea';
      case SymptomType.heavyFlow:
        return 'Heavy Flow';
      case SymptomType.lightFlow:
        return 'Light Flow';
      case SymptomType.spotting:
        return 'Spotting';
      case SymptomType.ovulationPain:
        return 'Ovulation Pain';
      case SymptomType.libido:
        return 'Libido Changes';
      case SymptomType.temperature:
        return 'Temperature';
      case SymptomType.cervicalMucus:
        return 'Cervical Mucus';
    }
  }
}