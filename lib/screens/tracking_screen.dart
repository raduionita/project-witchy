// Tracking screen - add and manage cycle entries (periods, ovulation)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/cycle_models.dart';
import '../providers/cycle_tracker_provider.dart';

class TrackingScreen extends StatefulWidget {
  const TrackingScreen({super.key});

  @override
  State<TrackingScreen> createState() => _TrackingScreenState();
}

class _TrackingScreenState extends State<TrackingScreen> {
  DateTime? _selectedDate;
  EntryType? _selectedEntryType;

  @override
  void initState() {
    super.initState();
    _selectedDate = DateTime.now().add(const Duration(days: -1)); // Default to yesterday
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Track Cycle'), backgroundColor: AppColors.primary),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _buildDatePicker(context),
            const SizedBox(height: 24),
            _buildEntryTypeSelection(),
            const SizedBox(height: 16),
            _buildDurationSlider(context),
          ],
        ),
      ),
    );
  }

  Widget _buildDatePicker(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            const Icon(Icons.calendar, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _selectedDate?.toString().split(' ')[0] ?? 'Select Date',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const Icon(Icons.chevron_down),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEntryTypeSelection() {
    return Column(
      children: [
        const Text('What are you tracking?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 8),
        ...[
          EntryType.periodStart,
          EntryType.periodEnd,
          EntryType.ovulation,
        ].map((entryType) => Card(
          child: ListTile(
            leading: _getEntryIcon(entryType),
            title: Text(_getEntryLabel(entryType)),
            subtitle: Text(_getEntryDescription(entryType), style: TextStyle(color: AppColors.textSecondary)),
            onTap: () {
              if (state.mounted) {
                setState(() => _selectedEntryType = entryType);
              }
            },
          ),
        )),
      ],
    );
  }

  Widget _buildDurationSlider(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text('Duration (days)', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Slider(
              value: _selectedEntryType?.isPeriodStart() == true ? 5.0 : 1.0,
              min: 1,
              max: 14,
              divisions: 20,
              onChanged: (value) => setState(() { /* update duration */ }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _getEntryIcon(EntryType type) {
    switch (type) {
      case EntryType.periodStart: return const Icon(Icons.circle, color: AppColors.primary);
      case EntryType.periodEnd: return const Icon(Icons.circle_outline, color: AppColors.primary);
      case EntryType.ovulation: return const Icon(Icons.auto_aviation, color: AppColors.secondary);
      default: return const Icon(Icons.circle_outlined);
    }
  }

  String _getEntryLabel(EntryType type) {
    switch (type) {
      case EntryType.periodStart: return 'Period Starts';
      case EntryType.periodEnd: return 'Period Ends';
      case EntryType.ovulation: return 'Ovulation';
      default: return '';
    }
  }

  String _getEntryDescription(EntryType type) {
    switch (type) {
      case EntryType.periodStart: return 'When your period begins';
      case EntryType.periodEnd: return 'When your period ends';
      case EntryType.ovulation: return 'Fertile window begins';
      default: return '';
    }
  }

}
