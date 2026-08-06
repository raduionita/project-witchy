import 'package:flutter/material.dart';
import '../utils/cycle_calculator.dart';

class PregnancyTrackerScreen extends StatefulWidget {
  const PregnancyTrackerScreen({super.key});

  @override
  State<PregnancyTrackerScreen> createState() => _PregnancyTrackerScreenState();
}

class _PregnancyTrackerScreenState extends State<PregnancyTrackerScreen> {
  DateTime? _lastPeriodDate;
  double _cycleLength = 28.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pregnancy Tracker'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLastPeriodInput(),
            const SizedBox(height: 16),
            if (_lastPeriodDate != null) ...[
              _buildPregnancyInfo(),
              const SizedBox(height: 16),
              _buildWeekByWeekDetails(),
              const SizedBox(height: 16),
              _buildTrimesterInfo(),
            ] else
              _buildEmptyState(),
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
            Icon(Icons.child_care, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text(
              'Enter your last period date',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 8),
            Text(
              'We will calculate your pregnancy progress and show you week-by-week details',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLastPeriodInput() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Last Period Date',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            InkWell(
              onTap: _selectDate,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _lastPeriodDate != null
                          ? '${_lastPeriodDate!.year}-${_lastPeriodDate!.month.toString().padLeft(2, '0')}-${_lastPeriodDate!.day.toString().padLeft(2, '0')}'
                          : 'Select date',
                      style: TextStyle(
                        color: _lastPeriodDate != null ? Colors.black : Colors.grey,
                      ),
                    ),
                    const Icon(Icons.calendar_today),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Cycle Length',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            Slider(
              value: _cycleLength,
              min: 20,
              max: 40,
              divisions: 20,
              label: '${_cycleLength.toInt()} days',
              onChanged: (value) {
                setState(() {
                  _cycleLength = value;
                });
              },
            ),
            Center(
              child: Text(
                '${_cycleLength.toInt()} days',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPregnancyInfo() {
    final weeks = CycleCalculator.calculatePregnancyWeeks(_lastPeriodDate!);
    final trimester = CycleCalculator.getTrimesterLabel(weeks);
    final dueDate = _lastPeriodDate!.add(const Duration(days: 280));

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Your Pregnancy Info',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.pink.shade50,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                children: [
                  Text(
                    '${weeks.toStringAsFixed(1)} weeks',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.deepPurple,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    trimester,
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildInfoItem('Due Date', dueDate.toString().split(' ').first),
                      _buildInfoItem('Days Left', '${(dueDate.difference(DateTime.now()).inDays).clamp(0, 9999)}'),
                      _buildInfoItem('Conception', (_lastPeriodDate!.add(Duration(days: _cycleLength.toInt() ~/ 2))).toString().split(' ').first),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoItem(String label, String value) {
    return Column(
      children: [
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }

  Widget _buildWeekByWeekDetails() {
    final weeks = CycleCalculator.calculatePregnancyWeeks(_lastPeriodDate!);
    final week = weeks.toInt();

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'This Week',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              'You are ${weeks.toStringAsFixed(1)} weeks pregnant',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              _getWeekDescription(week),
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Baby Size',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            Text(_getBabySize(week)),
            const SizedBox(height: 8),
            const Text(
              'Development Highlights',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            Text(_getDevelopmentHighlights(week)),
          ],
        ),
      ),
    );
  }

  Widget _buildTrimesterInfo() {
    final weeks = CycleCalculator.calculatePregnancyWeeks(_lastPeriodDate!);
    final trimester = CycleCalculator.getTrimesterLabel(weeks);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              trimester,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Text(
              _getTrimesterAdvice(weeks),
              style: const TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  String _getWeekDescription(int week) {
    if (week < 4) return 'Your embryo is tiny, about the size of a poppy seed.';
    if (week < 8) return 'Your embryo is now a fetus, growing rapidly.';
    if (week < 13) return 'First trimester ending soon. Your baby is developing organs.';
    if (week < 17) return 'Second trimester. Your baby can hear sounds now.';
    if (week < 27) return 'Your baby is practicing breathing movements.';
    if (week < 37) return 'Third trimester. Your baby is gaining weight rapidly.';
    return 'Your due date is approaching. Your baby is full-term soon!';
  }

  String _getBabySize(int week) {
    if (week < 4) return 'Poppy seed';
    if (week < 6) return 'Apple seed';
    if (week < 8) return 'Blueberry';
    if (week < 10) return 'Strawberry';
    if (week < 12) return 'Lime';
    if (week < 14) return 'Lemon';
    if (week < 16) return 'Avocado';
    if (week < 18) return 'Banana';
    if (week < 20) return 'Bell pepper';
    if (week < 22) return 'Corn';
    if (week < 24) return 'Eggplant';
    if (week < 26) return 'Papaya';
    if (week < 28) return 'Cauliflower';
    if (week < 30) return 'Coconut';
    if (week < 32) return 'Mango';
    if (week < 34) return 'Pineapple';
    if (week < 36) return 'Watermelon';
    return 'Full-term baby!';
  }

  String _getDevelopmentHighlights(int week) {
    if (week < 8) return 'Organ formation begins. Heart is beating!';
    if (week < 12) return 'Fingers and toes forming. Baby can make fists.';
    if (week < 16) return 'Bones hardening. You might feel movement soon.';
    if (week < 20) return 'Senses developing. Baby can hear your voice.';
    if (week < 24) return 'Lungs developing. Brain growing rapidly.';
    if (week < 28) return 'Eyes opening. Baby has sleep cycles.';
    if (week < 32) return 'Brain developing rapidly. Gaining weight.';
    if (week < 36) return 'Baby is full-term soon. Practicing breathing.';
    return 'Your baby is ready to be born!';
  }

  String _getTrimesterAdvice(double weeks) {
    if (weeks <= 13) {
      return 'First trimester tips: Rest when needed, eat small frequent meals, stay hydrated, and take prenatal vitamins.';
    } else if (weeks <= 27) {
      return 'Second trimester tips: You may have more energy. Start thinking about birth classes and begin tracking kicks.';
    } else {
      return 'Third trimester tips: Prepare your nursery, pack your hospital bag, and attend your final prenatal visits.';
    }
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _lastPeriodDate = picked;
      });
    }
  }
}
