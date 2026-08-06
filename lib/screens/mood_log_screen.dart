import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/mood.dart';
import '../providers/period_provider.dart';

class MoodLogScreen extends StatefulWidget {
  const MoodLogScreen({super.key});

  @override
  State<MoodLogScreen> createState() => _MoodLogScreenState();
}

class _MoodLogScreenState extends State<MoodLogScreen> {
  DateTime _selectedDate = DateTime.now();
  MoodType _selectedMood = MoodType.neutral;
  String? _notes;

  final List<MoodType> _moods = [
    MoodType.happy,
    MoodType.energetic,
    MoodType.calm,
    MoodType.neutral,
    MoodType.stressed,
    MoodType.anxious,
    MoodType.sad,
    MoodType.irritable,
    MoodType.tired,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Mood'),
        backgroundColor: const Color(0xFF9C27B0),
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateSection(),
            const SizedBox(height: 24),
            _buildMoodSelection(),
            const SizedBox(height: 24),
            _buildNotesSection(),
            const SizedBox(height: 24),
            _buildSaveButton(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.calendar_today, color: Color(0xFF9C27B0)),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Date',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  '${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          TextButton(
            onPressed: _selectDate,
            child: const Text('Change'),
          ),
        ],
      ),
    );
  }

  Widget _buildMoodSelection() {
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
            'How are you feeling?',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 16),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.2,
            ),
            itemCount: _moods.length,
            itemBuilder: (context, index) {
              final mood = _moods[index];
              final isSelected = _selectedMood == mood;
              return InkWell(
                onTap: () {
                  setState(() {
                    _selectedMood = mood;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? _getMoodColor(mood)
                        : Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? _getMoodColor(mood)
                          : Colors.grey[300]!,
                      width: 2,
                    ),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _getMoodIcon(mood),
                        color: isSelected ? Colors.white : _getMoodColor(mood),
                        size: 32,
                      ),
                      const SizedBox(height: 8),
                  Text(
                    _getMoodDisplayName(mood),
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: isSelected ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildNotesSection() {
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
            'Notes',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            maxLines: 3,
            decoration: const InputDecoration(
              hintText: 'Add any notes about your mood...',
              border: OutlineInputBorder(),
            ),
            onChanged: (value) {
              _notes = value;
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSaveButton(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF9C27B0),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(28),
          ),
        ),
        onPressed: () => _saveMood(context),
        child: const Text(
          'Save Mood',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  void _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  void _saveMood(BuildContext context) {
    final moodEntry = MoodEntry(
      id: const Uuid().v4(),
      type: _selectedMood,
      date: _selectedDate,
      notes: _notes,
    );

    context.read<PeriodProvider>().addMood(moodEntry);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Mood logged successfully!'),
        backgroundColor: Color(0xFF4CAF50),
      ),
    );

    Navigator.of(context).pop();
  }

  Color _getMoodColor(MoodType mood) {
    switch (mood) {
      case MoodType.happy:
        return Colors.amber;
      case MoodType.energetic:
        return Colors.orange;
      case MoodType.calm:
        return Colors.teal;
      case MoodType.neutral:
        return Colors.grey;
      case MoodType.stressed:
        return Colors.red;
      case MoodType.anxious:
        return Colors.purple;
      case MoodType.sad:
        return Colors.blue;
      case MoodType.irritable:
        return Colors.deepOrange;
      case MoodType.tired:
        return Colors.brown;
    }
  }

  String _getMoodDisplayName(MoodType mood) {
    switch (mood) {
      case MoodType.happy:
        return 'Happy';
      case MoodType.energetic:
        return 'Energetic';
      case MoodType.calm:
        return 'Calm';
      case MoodType.neutral:
        return 'Neutral';
      case MoodType.stressed:
        return 'Stressed';
      case MoodType.anxious:
        return 'Anxious';
      case MoodType.sad:
        return 'Sad';
      case MoodType.irritable:
        return 'Irritable';
      case MoodType.tired:
        return 'Tired';
    }
  }

  IconData _getMoodIcon(MoodType mood) {
    switch (mood) {
      case MoodType.happy:
        return Icons.sentiment_very_satisfied;
      case MoodType.energetic:
        return Icons.bolt;
      case MoodType.calm:
        return Icons.pets;
      case MoodType.neutral:
        return Icons.sentiment_neutral;
      case MoodType.stressed:
        return Icons.flash_on;
      case MoodType.anxious:
        return Icons.psychology;
      case MoodType.sad:
        return Icons.sentiment_dissatisfied;
      case MoodType.irritable:
        return Icons.warning;
      case MoodType.tired:
        return Icons.battery_4_bar;
    }
  }
}