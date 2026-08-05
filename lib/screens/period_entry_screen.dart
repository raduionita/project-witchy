import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/cycle_provider.dart';
import '../providers/symptoms_provider.dart';
import '../models/period_cycle.dart';
import '../utils/theme_colors.dart';

class PeriodEntryScreen extends StatefulWidget {
  const PeriodEntryScreen({super.key});

  @override
  State<PeriodEntryScreen> createState() => _PeriodEntryScreenState();
}

class _PeriodEntryScreenState extends State<PeriodEntryScreen> {
  DateTime? _startDate;
  DateTime? _endDate;
  double _flowIntensity = 2.0;
  String? _notes;
  final List<String> _selectedSymptoms = [];
  final List<Mood> _selectedMoods = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Log Period'),
        backgroundColor: WitchyColors.primary,
        foregroundColor: Colors.white,
        actions: [
          TextButton(
            onPressed: _savePeriod,
            child: const Text('Save', style: TextStyle(fontSize: 16)),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDateSection(),
            const SizedBox(height: 24),
            _buildFlowSection(),
            const SizedBox(height: 24),
            _buildSymptomSection(),
            const SizedBox(height: 24),
            _buildMoodSection(),
            const SizedBox(height: 24),
            _buildNotesSection(),
          ],
        ),
      ),
    );
  }

  Widget _buildDateSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Period Dates', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildDatePicker('Start Date', _startDate, (date) {
                    setState(() => _startDate = date);
                  }),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildDatePicker('End Date (optional)', _endDate, (date) {
                    setState(() => _endDate = date);
                  }),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker(String label, DateTime? date, ValueChanged<DateTime?> onChanged) {
    return InkWell(
      onTap: () async {
        final picked = await showDatePicker(
          context: context,
          initialDate: date ?? DateTime.now(),
          firstDate: DateTime(2000),
          lastDate: DateTime.now().add(const Duration(days: 365)),
        );
        if (picked != null) onChanged(picked);
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: WitchyColors.borderColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(Icons.calendar_today, size: 16, color: WitchyColors.primary),
            const SizedBox(width: 8),
            Text(
              date != null ? DateFormat('MMM d, yyyy').format(date) : label,
              style: TextStyle(
                color: date != null ? WitchyColors.textColor : WitchyColors.lightText,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlowSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Flow Intensity', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Row(
              children: [
                const Text('Light'),
                const Spacer(),
                Text('Heavy'),
              ],
            ),
            const SizedBox(height: 8),
            Slider(
              value: _flowIntensity,
              min: 0,
              max: 5,
              divisions: 5,
              label: _flowIntensity.toStringAsFixed(0),
              activeColor: WitchyColors.periodColor,
              onChanged: (value) {
                setState(() => _flowIntensity = value);
              },
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _buildFlowBar(1),
                _buildFlowBar(2),
                _buildFlowBar(3),
                _buildFlowBar(4),
                _buildFlowBar(5),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFlowBar(int level) {
    final isActive = _flowIntensity.round() == level;
    return Column(
      children: [
        Container(
          width: 8,
          height: 16 + (level * 4),
          decoration: BoxDecoration(
            color: isActive ? WitchyColors.periodColor : WitchyColors.borderColor,
            borderRadius: BorderRadius.circular(4),
          ),
        ),
        const SizedBox(height: 4),
        Text(
          level.toString(),
          style: TextStyle(
            fontSize: 10,
            color: isActive ? WitchyColors.periodColor : WitchyColors.lightText,
            fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildSymptomSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Symptoms', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Consumer<SymptomsProvider>(
              builder: (context, provider, child) {
                return Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: provider.getAvailableSymptoms().map((symptom) {
                    final isSelected = _selectedSymptoms.contains(symptom);
                    return FilterChip(
                      label: Text(symptom),
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
                      selectedColor: WitchyColors.primary.withValues(alpha: 0.2),
                      checkmarkColor: WitchyColors.primary,
                    );
                  }).toList(),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMoodSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Mood', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: Mood.values.map((mood) {
                final isSelected = _selectedMoods.contains(mood);
                return FilterChip(
                  label: Text(mood.name.toUpperCase()),
                  selected: isSelected,
                  onSelected: (selected) {
                    setState(() {
                      if (selected) {
                        _selectedMoods.add(mood);
                      } else {
                        _selectedMoods.remove(mood);
                      }
                    });
                  },
                  selectedColor: WitchyColors.primary.withValues(alpha: 0.2),
                  checkmarkColor: WitchyColors.primary,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Notes (optional)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            TextField(
              maxLines: 4,
              decoration: const InputDecoration(
                hintText: 'Add any notes about your period...',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) => _notes = value,
            ),
          ],
        ),
      ),
    );
  }

  void _savePeriod() {
    if (_startDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please select a start date')),
      );
      return;
    }

    final symptoms = _selectedSymptoms.map((s) => Symptom(name: s)).toList();

    context.read<CycleProvider>().addPeriod(
      startDate: _startDate!,
      endDate: _endDate,
      flowIntensity: _flowIntensity,
      symptoms: symptoms,
      notes: _notes,
    );

    for (final mood in _selectedMoods) {
      context.read<CycleProvider>().addMood(
            PeriodCycle(startDate: _startDate!),
            mood,
          );
    }

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Period logged successfully')),
      );
    }
  }
}
