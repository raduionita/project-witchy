import 'package:flutter/material.dart';

import '../l10n/app_localizations.dart';
import '../models/calendar_day.dart';

/// Icon for a small calendar data marker.
IconData calendarMarkerIcon(CalendarDayMarker marker) => switch (marker) {
  CalendarDayMarker.flow => Icons.water_drop,
  CalendarDayMarker.bbt => Icons.thermostat,
  CalendarDayMarker.lhPeak => Icons.auto_awesome,
  CalendarDayMarker.intimacy => Icons.favorite,
};

/// Localized, screen-reader friendly label for a marker.
String calendarMarkerLabel(AppLocalizations l10n, CalendarDayMarker marker) =>
    switch (marker) {
      CalendarDayMarker.flow => l10n.markerFlow,
      CalendarDayMarker.bbt => l10n.markerBbt,
      CalendarDayMarker.lhPeak => l10n.markerLhPeak,
      CalendarDayMarker.intimacy => l10n.markerIntimacy,
    };

/// Tiny icon row drawn inside a day cell for logged biometric data.
class DayMarkersRow extends StatelessWidget {
  const DayMarkersRow({
    super.key,
    required this.markers,
    this.size = 9,
    this.color,
  });

  final List<CalendarDayMarker> markers;
  final double size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    if (markers.isEmpty) return const SizedBox.shrink();
    final Color effective = color ?? Theme.of(context).colorScheme.onSurface;
    return Semantics(
      label: markers
          .map((CalendarDayMarker m) => calendarMarkerLabel(
                AppLocalizations.of(context),
                m,
              ))
          .join(', '),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          for (final CalendarDayMarker marker in markers)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: Icon(calendarMarkerIcon(marker), size: size, color: effective),
            ),
        ],
      ),
    );
  }
}
