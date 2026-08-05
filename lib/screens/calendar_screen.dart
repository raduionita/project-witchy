import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:intl/intl.dart';
import '../providers/cycle_provider.dart';
import '../models/period_cycle.dart';
import '../utils/theme_colors.dart';
import 'period_entry_screen.dart';

class CalendarScreen extends StatefulWidget {
  const CalendarScreen({super.key});

  @override
  State<CalendarScreen> createState() => _CalendarScreenState();
}

class _CalendarScreenState extends State<CalendarScreen> {
  DateTime _focusedMonth = DateTime.now();
  DateTime? _selectedDay;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Calendar'),
        backgroundColor: WitchyColors.primary,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          _buildCalendar(context),
          const Divider(),
          Expanded(child: _buildLoggedEvents(context)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const PeriodEntryScreen()),
          );
        },
        backgroundColor: WitchyColors.primary,
        icon: const Icon(Icons.add),
        label: const Text('Log'),
      ),
    );
  }

  Widget _buildCalendar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Consumer<CycleProvider>(
        builder: (context, provider, child) {
          return TableCalendar(
            firstDay: DateTime.now().subtract(const Duration(days: 365)),
            lastDay: DateTime.now().add(const Duration(days: 365)),
            focusedDay: _focusedMonth,
            selectedDayPredicate: (day) => isSameDay(_selectedDay, day),
            onDaySelected: (selectedDay, focusedMonth) {
              setState(() {
                _selectedDay = selectedDay;
                _focusedMonth = focusedMonth;
              });
            },
            calendarFormat: CalendarFormat.month,
            startingDayOfWeek: StartingDayOfWeek.monday,
            eventLoader: (day) {
              return _getEventsForDay(provider.cycles, day);
            },
            calendarStyle: CalendarStyle(
              todayDecoration: BoxDecoration(
                color: WitchyColors.primary.withValues(alpha: 0.3),
                shape: BoxShape.circle,
              ),
              selectedDecoration: BoxDecoration(
                color: WitchyColors.primary,
                shape: BoxShape.circle,
              ),
              markerDecoration: const BoxDecoration(
                color: WitchyColors.periodColor,
                shape: BoxShape.circle,
              ),
              markersMaxCount: 3,
              markerSize: 4,
              markerMargin: const EdgeInsets.symmetric(horizontal: 1),
            ),
            headerStyle: HeaderStyle(
              formatButtonVisible: false,
              titleTextStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              leftChevronIcon: const Icon(Icons.chevron_left, color: WitchyColors.primary),
              rightChevronIcon: const Icon(Icons.chevron_right, color: WitchyColors.primary),
            ),
          );
        },
      ),
    );
  }

  List<PeriodCycle> _getEventsForDay(List<PeriodCycle> cycles, DateTime day) {
    final events = <PeriodCycle>[];

    for (final cycle in cycles) {
      final startDate = cycle.startDate;
      final endDate = cycle.endDate ?? DateTime.now();

      if (day.isAfter(startDate.subtract(const Duration(days: 1))) &&
          day.isBefore(endDate.add(const Duration(days: 1)))) {
        events.add(cycle);
      }
    }

    return events;
  }

  Widget _buildLoggedEvents(BuildContext context) {
    return Consumer<CycleProvider>(
      builder: (context, provider, child) {
        final cycles = provider.cycles;

        if (cycles.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.event_note, size: 48, color: WitchyColors.lightText),
                SizedBox(height: 16),
                Text(
                  'No logged events yet',
                  style: TextStyle(color: WitchyColors.lightText),
                ),
                SizedBox(height: 8),
                Text(
                  'Tap the + button to log your first period',
                  style: TextStyle(color: WitchyColors.lightText, fontSize: 12),
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: cycles.length,
          itemBuilder: (context, index) {
            final cycle = cycles[index];
            return _buildCycleCard(cycle);
          },
        );
      },
    );
  }

  Widget _buildCycleCard(PeriodCycle cycle) {
    final startDateStr = DateFormat('MMM d, yyyy').format(cycle.startDate);
    final endDateStr = cycle.endDate != null
        ? ' - ${DateFormat('MMM d, yyyy').format(cycle.endDate!)}'
        : ' (active)';

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: WitchyColors.periodColor,
          child: const Icon(Icons.local_hospital, color: Colors.white),
        ),
        title: Text(
          'Started: $startDateStr$endDateStr',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Text(
          'Duration: ${cycle.duration} days | Flow: ${cycle.flowIntensity.toStringAsFixed(1)}',
          style: const TextStyle(color: WitchyColors.lightText),
        ),
        children: [
          if (cycle.symptoms.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Symptoms:', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: cycle.symptoms.map((s) => Chip(label: Text(s.name))).toList(),
                  ),
                ],
              ),
            ),
          ],
          if (cycle.moods.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Moods:', style: TextStyle(fontWeight: FontWeight.w500)),
                  const SizedBox(height: 4),
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: cycle.moods.map((m) => Chip(label: Text(m.mood.name.toUpperCase()))).toList(),
                  ),
                ],
              ),
            ),
          ],
          if (cycle.notes != null && cycle.notes!.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'Notes: ${cycle.notes}',
                style: const TextStyle().copyWith(fontStyle: FontStyle.italic),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                TextButton.icon(
                  onPressed: () {
                    context.read<CycleProvider>().deletePeriod(cycle);
                  },
                  icon: const Icon(Icons.delete, color: WitchyColors.periodColor, size: 18),
                  label: const Text('Delete', style: TextStyle(color: WitchyColors.periodColor)),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
