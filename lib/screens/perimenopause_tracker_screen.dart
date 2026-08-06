import 'package:flutter/material.dart';

class PerimenopauseTrackerScreen extends StatefulWidget {
  const PerimenopauseTrackerScreen({super.key});

  @override
  State<PerimenopauseTrackerScreen> createState() => _PerimenopauseTrackerScreenState();
}

class _PerimenopauseTrackerScreenState extends State<PerimenopauseTrackerScreen> {
  final List<String> commonSymptoms = [
    'Hot flashes',
    'Night sweats',
    'Irregular periods',
    'Sleep problems',
    'Mood changes',
    'Vaginal dryness',
    'Weight gain',
    'Thinning hair',
    'Breast tenderness',
    'Headaches',
    'Palpitations',
    'Anxiety',
  ];

  final Map<String, int> selectedSymptoms = {};
  DateTime? _lastPeriodDate;
  double _cycleLength = 28.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Perimenopause Tracker'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildIntroCard(),
            const SizedBox(height: 16),
            _buildLastPeriodSection(),
            const SizedBox(height: 16),
            _buildSymptomTracker(),
            const SizedBox(height: 16),
            _buildCycleTracking(),
            const SizedBox(height: 16),
            _buildEducationSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildIntroCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Understanding Perimenopause',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Perimenopause is the transition phase before menopause when your body gradually stops producing estrogen. '
              'This can last 4-8 years. Tracking your symptoms helps you understand your body and prepare for changes.',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLastPeriodSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Last Period Date',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
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
          ],
        ),
      ),
    );
  }

  Widget _buildSymptomTracker() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Track Your Symptoms',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...commonSymptoms.map((symptom) {
              final isSelected = selectedSymptoms.containsKey(symptom);
              return CheckboxListTile(
                value: isSelected,
                onChanged: (bool? value) {
                  setState(() {
                    if (value == true) {
                      selectedSymptoms[symptom] = 3;
                    } else {
                      selectedSymptoms.remove(symptom);
                    }
                  });
                },
                title: Text(symptom),
                controlAffinity: ListTileControlAffinity.trailing,
                contentPadding: EdgeInsets.zero,
              );
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildCycleTracking() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Cycle Information',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            const Text(
              'Average Cycle Length',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            Slider(
              value: _cycleLength,
              min: 20,
              max: 45,
              divisions: 25,
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
            const SizedBox(height: 12),
            const Divider(),
            const SizedBox(height: 8),
            const Text(
              'Tips for Perimenopause',
              style: TextStyle(fontWeight: FontWeight.w500),
            ),
            const SizedBox(height: 8),
            const Text(
              '• Stay cool: Dress in layers and keep your bedroom cool\n'
              '• Exercise regularly: Helps with mood, sleep, and bone health\n'
              '• Eat calcium-rich foods: Protects against bone loss\n'
              '• Practice stress management: Yoga, meditation, deep breathing\n'
              '• Stay hydrated: Drink plenty of water throughout the day\n'
              '• Get regular check-ups: Monitor your health with your doctor',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEducationSection() {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'What to Expect',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildTimelineItem('Early Perimenopause', 'Ages 40-44', 'Cycle changes begin. You may notice slightly shorter cycles.'),
            const Divider(),
            _buildTimelineItem('Late Perimenopause', 'Ages 45-49', 'More noticeable symptoms. Cycles become irregular.'),
            const Divider(),
            _buildTimelineItem('Transition to Menopause', 'Ages 50+', '12 months without a period marks menopause.'),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(String stage, String ageRange, String description) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 8,
            height: 8,
            margin: const EdgeInsets.only(top: 4, right: 12),
            decoration: const BoxDecoration(
              color: Colors.deepPurple,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$stage ($ageRange)',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(description, style: const TextStyle(color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        _lastPeriodDate = picked;
      });
    }
  }
}
