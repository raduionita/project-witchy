import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/symptom_provider.dart';
import '../models/cycle_model.dart';

/// Screen for logging and viewing symptoms.
class SymptomScreen extends StatefulWidget {
  const SymptomScreen({super.key});

  @override
  State<SymptomScreen> createState() => _SymptomScreenState();
}

class _SymptomScreenState extends State<SymptomScreen> {
  DateTime _selectedDate = DateTime.now();

  @override
  Widget build(BuildContext context) {
    final symptomProvider = context.watch<SymptomProvider>();
    final symptoms = symptomProvider.getSymptomsForDate(_selectedDate);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          DateFormat.yMMMMd().format(_selectedDate),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.calendar_today),
            onPressed: () => _selectDate(context),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildDateSelector(),
          const SizedBox(height: 16),
          if (symptoms.isEmpty)
            const Expanded(
              child: Center(
                child: Text(
                  'No symptoms logged for this date.\nTap + to add one.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            )
          else
            Expanded(child: _buildSymptomList(symptoms)),
          _buildAddSymptomButton(),
        ],
      ),
    );
  }

  Widget _buildDateSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () {
              setState(() {
                _selectedDate = _selectedDate.subtract(const Duration(days: 1));
              });
            },
          ),
          Expanded(
            child: Text(
              DateFormat.EEEE().format(_selectedDate),
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () {
              setState(() {
                _selectedDate = _selectedDate.add(const Duration(days: 1));
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSymptomList(List<SymptomEntry> symptoms) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: symptoms.length,
      itemBuilder: (context, index) {
        final symptom = symptoms[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Icon(_getSymptomIcon(symptom.type)),
            title: Text(_symptomTypeName(symptom.type)),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Severity: ${symptom.severity}/5'),
                if (symptom.note != null) Text(symptom.note!),
              ],
            ),
            trailing: IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                context.read<SymptomProvider>().removeSymptom(symptom.id);
              },
            ),
          ),
        );
      },
    );
  }

  Widget _buildAddSymptomButton() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: ElevatedButton.icon(
        icon: const Icon(Icons.add),
        label: const Text('Add Symptom'),
        onPressed: () => _showAddSymptomDialog(),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFAB1D6B),
          minimumSize: const Size(double.infinity, 50),
        ),
      ),
    );
  }

  void _showAddSymptomDialog() {
    SymptomType? selectedType;
    double severity = 3;
    String? note;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Log Symptom'),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Select symptom:'),
                const SizedBox(height: 8),
                ...SymptomType.values.map(
                  (type) => RadioListTile<SymptomType>(
                    title: Text(_symptomTypeName(type)),
                    value: type,
                    groupValue: selectedType,
                    onChanged: (value) {
                      setDialogState(() {
                        selectedType = value;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 16),
                const Text('Severity:'),
                Slider(
                  value: severity,
                  min: 1,
                  max: 5,
                  divisions: 4,
                  label: severity.round().toString(),
                  onChanged: (value) {
                    setDialogState(() {
                      severity = value;
                    });
                  },
                ),
                const SizedBox(height: 8),
                const Text('Notes (optional):'),
                TextField(
                  onChanged: (value) => note = value,
                  decoration: const InputDecoration(
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: selectedType != null
                  ? () {
                      final symptom = SymptomEntry(
                        id: DateTime.now().millisecondsSinceEpoch,
                        date: _selectedDate,
                        type: selectedType!,
                        severity: severity,
                        note: note,
                      );
                      context
                          .read<SymptomProvider>()
                          .addSymptom(symptom);
                      Navigator.pop(context);
                    }
                  : null,
              child: const Text('Save'),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  IconData _getSymptomIcon(SymptomType type) {
    switch (type) {
      case SymptomType.cramps:
        return Icons.accessibility;
      case SymptomType.headache:
        return Icons.psychology;
      case SymptomType.bloating:
        return Icons.cake;
      case SymptomType.breastTenderness:
        return Icons.favorite;
      case SymptomType.fatigue:
        return Icons.battery_4_bar;
      case SymptomType.moodSwings:
        return Icons.sentiment_satisfied;
      case SymptomType.acne:
        return Icons.face;
      case SymptomType.backache:
        return Icons.accessibility_new;
      case SymptomType.nausea:
        return Icons.vertical_align_top;
      case SymptomType.heavyFlow:
      case SymptomType.lightFlow:
      case SymptomType.spotting:
        return Icons.water_drop;
      case SymptomType.ovulationPain:
        return Icons.flash_on;
      case SymptomType.libido:
        return Icons.local_fire_department;
      case SymptomType.temperature:
        return Icons.thermostat;
      case SymptomType.cervicalMucus:
        return Icons.science;
    }
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