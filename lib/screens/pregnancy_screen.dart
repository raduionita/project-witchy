import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/pregnancy_tracker.dart';
import '../providers/pregnancy_provider.dart';

class PregnancyScreen extends StatelessWidget {
  const PregnancyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<PregnancyProvider>(
      builder: (context, pregnancyProvider, _) {
        final tracker = pregnancyProvider.tracker;

        return Scaffold(
          appBar: AppBar(
            title: const Text('Pregnancy Tracker'),
            backgroundColor: const Color(0xFF9C27B0),
            foregroundColor: Colors.white,
          ),
          body: tracker == null
              ? _buildNotTracking(context)
              : _buildTrackingView(tracker),
        );
      },
    );
  }

  Widget _buildNotTracking(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.pregnant_woman,
              size: 80,
              color: const Color(0xFF9C27B0),
            ),
            const SizedBox(height: 24),
            const Text(
              'Not Tracking Pregnancy',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Start tracking your pregnancy to get weekly updates about your baby\'s development.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF9C27B0),
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 12,
                ),
              ),
              onPressed: () => _startTracking(context),
              child: const Text(
                'Start Tracking',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackingView(PregnancyTracker tracker) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildPregnancyHeader(tracker),
          const SizedBox(height: 24),
          _buildWeekInfo(tracker),
          const SizedBox(height: 24),
          _buildTrimesterProgress(tracker),
          const SizedBox(height: 24),
          _buildDueDateCard(tracker),
        ],
      ),
    );
  }

  Widget _buildPregnancyHeader(PregnancyTracker tracker) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF9C27B0), Color(0xFFE91E63)],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            'You are',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${tracker.gestationalWeek} weeks and ${tracker.gestationalDay} days',
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Trimester ${tracker.trimester == 'First' ? '1' : tracker.trimester == 'Second' ? '2' : '3'}',
            style: const TextStyle(
              fontSize: 16,
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekInfo(PregnancyTracker tracker) {
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
            'This Week',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            'Your baby is growing! Each week brings new developments.',
            style: TextStyle(
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(Icons.baby_changing_station, color: Color(0xFF9C27B0)),
              const SizedBox(width: 8),
              Text(
                'Baby size: ${_getBabySize(tracker.gestationalWeek)}',
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTrimesterProgress(PregnancyTracker tracker) {
    final progress = tracker.gestationalWeek / 40;

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
            'Pregnancy Progress',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress.clamp(0.0, 1.0),
              backgroundColor: Colors.grey[300],
              valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF9C27B0)),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${(progress * 100).toStringAsFixed(0)}% complete',
            style: const TextStyle(
              fontSize: 12,
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDueDateCard(PregnancyTracker tracker) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.event, color: Color(0xFF9C27B0)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Estimated Due Date',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  tracker.dueDate != null
                      ? '${tracker.dueDate!.day}/${tracker.dueDate!.month}/${tracker.dueDate!.year}'
                      : 'N/A',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
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

  void _startTracking(BuildContext context) {
    final now = DateTime.now();
    final lastPeriodDate = now.subtract(const Duration(days: 14));

    context.read<PregnancyProvider>().startPregnancyTracking(lastPeriodDate);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Pregnancy tracking started!'),
        backgroundColor: Color(0xFF4CAF50),
      ),
    );
  }

  String _getBabySize(int week) {
    if (week < 4) return 'Poppy seed';
    if (week < 6) return 'Lentil';
    if (week < 8) return 'Blueberry';
    if (week < 10) return 'Strawberry';
    if (week < 12) return 'Lime';
    if (week < 14) return 'Lemon';
    if (week < 16) return 'Avocado';
    if (week < 18) return 'Bell pepper';
    if (week < 20) return 'Banana';
    if (week < 22) return 'Papaya';
    if (week < 24) return 'Corn cob';
    if (week < 26) return 'Eggplant';
    if (week < 28) return 'Cauliflower';
    if (week < 30) return 'Coconut';
    if (week < 32) return 'Squash';
    if (week < 34) return 'Honeydew melon';
    if (week < 36) return 'Mango';
    if (week < 38) return 'Pumpkin';
    return 'Small watermelon';
  }
}