import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../services/cycle_service.dart';

/// Screen for tracking pregnancy progress.
class PregnancyScreen extends StatefulWidget {
  const PregnancyScreen({super.key});

  @override
  State<PregnancyScreen> createState() => _PregnancyScreenState();
}

class _PregnancyScreenState extends State<PregnancyScreen> {
  DateTime? _lastPeriodStart;
  bool _isTracking = false;

  @override
  Widget build(BuildContext context) {
    if (!_isTracking || _lastPeriodStart == null) {
      return _buildSetupView();
    }

    final now = DateTime.now();
    final weeks = CycleService.pregnancyWeek(_lastPeriodStart!, now);
    final trimester = CycleService.pregnancyTrimester(_lastPeriodStart!, now);
    final dueDate = CycleService.estimateDueDate(_lastPeriodStart!);
    final daysRemaining = dueDate.difference(now).inDays;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pregnancy Tracker'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildPregnancyHeader(weeks, trimester),
          const SizedBox(height: 24),
          _buildWeekProgressCard(weeks),
          const SizedBox(height: 16),
          _buildDueDateCard(dueDate, daysRemaining),
          const SizedBox(height: 16),
          _buildTrimesterInfo(trimester),
          const SizedBox(height: 16),
          _buildBabySizeCard(weeks),
          const SizedBox(height: 24),
          Center(
            child: ElevatedButton(
              onPressed: () => setState(() => _isTracking = false),
              child: const Text('Stop Tracking'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSetupView() {
    DateTime? selectedDate;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pregnancy Tracker'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Track your pregnancy progress',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Enter the first day of your last period to get started.',
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 32),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Last Period Start Date',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    InkWell(
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate ?? DateTime.now(),
                          firstDate: DateTime(2020),
                          lastDate: DateTime.now(),
                        );
                        if (picked != null) {
                          setState(() => selectedDate = picked);
                        }
                      },
                      child: Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.grey),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today),
                            const SizedBox(width: 12),
                            Text(
                              DateFormat.yMMMMd().format(selectedDate!),
                              style: const TextStyle(fontSize: 16),
                            ),
                            const Spacer(),
                            const Icon(Icons.chevron_right),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: selectedDate != null
                          ? () {
                              setState(() {
                                _lastPeriodStart = selectedDate;
                                _isTracking = true;
                              });
                            }
                          : null,
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size(double.infinity, 50),
                      ),
                      child: const Text('Start Tracking'),
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

  Widget _buildPregnancyHeader(int weeks, int trimester) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF6A0572),
            Color(0xFFAB1D6B),
            Color(0xFFE94057),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Icon(
            Icons.pregnant_woman,
            color: Colors.white,
            size: 48,
          ),
          const SizedBox(height: 16),
          Text(
            'Week $weeks',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Trimester $trimester',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWeekProgressCard(int weeks) {
    final progress = (weeks / 40) * 100;

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Pregnancy Progress',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress / 100,
                backgroundColor: Colors.grey.shade200,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  Color(0xFFAB1D6B),
                ),
                minHeight: 12,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              '${progress.toStringAsFixed(1)}% complete',
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDueDateCard(DateTime dueDate, int daysRemaining) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Estimated Due Date',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              DateFormat.yMMMMd().format(dueDate),
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 4),
            Text(
              daysRemaining > 0
                  ? '$daysRemaining days remaining'
                  : 'Your baby is here!',
              style: TextStyle(
                color: daysRemaining > 0 ? Colors.grey.shade600 : Colors.green,
                fontSize: 14,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrimesterInfo(int trimester) {
    final info = _getTrimesterInfo(trimester);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Trimester $trimester',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              info,
              style: const TextStyle(fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBabySizeCard(int weeks) {
    final babySize = _getBabySize(weeks);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Baby Size',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              babySize,
              style: const TextStyle(fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  String _getTrimesterInfo(int trimester) {
    switch (trimester) {
      case 1:
        return 'Your baby is developing all major organs and systems. This is a critical time for development.';
      case 2:
        return 'Your baby is growing rapidly and you may start feeling movements. All organs are forming.';
      case 3:
        return 'Your baby is gaining weight and developing lungs. Ready for the outside world!';
      default:
        return '';
    }
  }

  String _getBabySize(int weeks) {
    if (weeks < 4) return 'Size of a poppy seed';
    if (weeks < 6) return 'Size of a pomegranate seed';
    if (weeks < 8) return 'Size of a lentil';
    if (weeks < 10) return 'Size of a raspberry';
    if (weeks < 12) return 'Size of a lime';
    if (weeks < 14) return 'Size of a plum';
    if (weeks < 16) return 'Size of an avocado';
    if (weeks < 18) return 'Size of a papaya';
    if (weeks < 20) return 'Size of a banana';
    if (weeks < 22) return 'Size of a carrot';
    if (weeks < 24) return 'Size of an ear of corn';
    if (weeks < 26) return 'Size of an eggplant';
    if (weeks < 28) return 'Size of an ear of corn';
    if (weeks < 30) return 'Size of a coconut';
    if (weeks < 32) return 'Size of a squash';
    if (weeks < 34) return 'Size of a papaya';
    if (weeks < 36) return 'Size of a honeydew melon';
    if (weeks < 38) return 'Size of a watermelon';
    if (weeks < 40) return 'Size of a pumpkin';
    return 'Your baby is here!';
  }
}