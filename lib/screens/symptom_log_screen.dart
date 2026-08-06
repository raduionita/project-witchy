import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';
import '../models/symptom.dart';
import '../providers/period_provider.dart';

class SymptomLogScreen extends StatefulWidget {
  const SymptomLogScreen({super.key});

  @override
  State<SymptomLogScreen> createState() => _SymptomLogScreenState();
}

class _SymptomLogScreenState extends State<SymptomLogScreen> {
  DateTime _selectedDate = DateTime.now();
  int _severity = 3;
  String? _notes;
  final List<SymptomType> _selectedSymptoms = [];

  final List<SymptomType> _allSymptoms = [
    SymptomType.cramps,
    SymptomType.headache,
    SymptomType.bloating,
    SymptomType.breastTenderness,
    SymptomType.fatigue,
    SymptomType.acne,
    SymptomType.backache,
    SymptomType.moodSwings,
    SymptomType.nausea,
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Symptoms'),
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
            _buildSymptomSelection(),
            const SizedBox(height: 24),
            _buildSeveritySection(),
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

  Widget _buildSymptomSelection() {
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
            'Select Symptoms',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _allSymptoms.map((symptom) {
              final isSelected = _selectedSymptoms.contains(symptom);
              return FilterChip(
                label: Text(_getSymptomDisplayName(symptom)),
                selected: isSelected,
                onSelected: (selected) {
                  setState(() {
                    if (selected) {
                      _selectedSymptoms.add(symptom);
                    } else {
                      _selectedSymptoms.remove(symptom);
                    }
                  });
                },
                selectedColor: const Color(0xFF9C27B0),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSeveritySection() {
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
            'Severity',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: List.generate(5, (index) {
              final isActive = index < _severity;
              return Expanded(
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      _severity = index + 1;
                    });
                  },
                  child: Container(
                    height: 30,
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    decoration: BoxDecoration(
                      color: isActive
                          ? _getSeverityColor(index)
                          : Colors.grey[300],
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: 8),
          Center(
            child: Text(
              _getSeverityLabel(_severity),
              style: TextStyle(
                color: _getSeverityColor(_severity - 1),
                fontWeight: FontWeight.w500,
              ),
            ),
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
              hintText: 'Add any notes about your symptoms...',
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
        onPressed: () => _saveSymptoms(context),
        child: const Text(
          'Save Symptoms',
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

  String _getSymptomDisplayName(SymptomType symptom) {
    switch (symptom) {
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
      case SymptomType.acne:
        return 'Acne';
      case SymptomType.backache:
        return 'Backache';
      case SymptomType.moodSwings:
        return 'Mood Swings';
      case SymptomType.nausea:
        return 'Nausea';
      case SymptomType.heavyFlow:
        return 'Heavy Flow';
      case SymptomType.lightFlow:
        return 'Light Flow';
      case SymptomType.spotting:
        return 'Spotting';
      case SymptomType.none:
        return 'None';
    }
  }

  void _saveSymptoms(BuildContext context) {
    if (_selectedSymptoms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select at least one symptom'),
        ),
      );
      return;
    }

    for (final symptomType in _selectedSymptoms) {
      final symptom = Symptom(
        id: const Uuid().v4(),
        type: symptomType,
        date: _selectedDate,
        severity: _severity,
        notes: _notes,
      );
      context.read<PeriodProvider>().addSymptom(symptom);
    }

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Symptoms logged successfully!'),
        backgroundColor: Color(0xFF4CAF50),
      ),
    );

    Navigator.of(context).pop();
  }

  Color _getSeverityColor(int level) {
    switch (level) {
      case 0:
        return Colors.green;
      case 1:
        return Colors.lightGreen;
      case 2:
        return Colors.yellow;
      case 3:
        return Colors.orange;
      case 4:
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  String _getSeverityLabel(int level) {
    switch (level) {
      case 1:
        return 'Mild';
      case 2:
        return 'Moderate';
      case 3:
        return 'Moderate';
      case 4:
        return 'Severe';
      case 5:
        return 'Very Severe';
      default:
        return '';
    }
  }
}