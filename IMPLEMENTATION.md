# Witchy - Period Tracker & Cycle Calendar App

A comprehensive health tracking application designed to help you understand and monitor your menstrual cycle, fertility window, pregnancy, and overall reproductive health.

## Project Structure

```
lib/
├── main.dart                          # App entry point with Provider setup
├── models/
│   └── cycle_models.dart              # Freezed data models (CycleEntry, PregnancyInfo, etc.)
├── services/
│   └── period_tracking_service.dart   # Core business logic for cycle tracking and predictions
├── providers/
│   └── cycle_tracker_provider.dart    # State management with Provider
├── screens/
│   ├── home_screen.dart               # Main navigation hub (bottom nav)
│   ├── tracking_screen.dart           # Add/manage cycle entries
│   ├── calendar_screen.dart           # Visual calendar view of cycles
│   ├── pregnancy_screen.dart          # Pregnancy tracking and fertility insights
│   ├── health_insights_screen.dart    # Cycle predictions and health information
│   └── settings_screen.dart           # App preferences and privacy controls
├── widgets/
│   └── app_widgets.dart               # Reusable UI components
└── utils/
    └── constants.dart                 # App colors, theme, and enums
```

## Implementation Status

### ✅ Completed
- [x] Project structure with clean architecture (models, services, providers, screens, widgets)
- [x] Data models using Freezed (CycleEntry, PregnancyInfo, PerimenopauseTracker, CyclePrediction)
- [x] Period tracking service with business logic (cycle calculations, predictions)
- [x] State management using Provider (CycleTrackerProvider)
- [x] Home screen with bottom navigation bar (Cycle, Calendar, Pregnancy, Settings)
- [x] Tracking screen for adding cycle entries (period start/end, ovulation)
- [x] Calendar screen with visual cycle tracking
- [x] Pregnancy tracker screen with fertility window insights
- [x] Health insights screen for cycle predictions and regularity analysis
- [x] Settings screen with app preferences

### 🔄 Next Steps
- [ ] Add calendar navigation (month/week switching)
- [ ] Implement data persistence with Hive or SharedPreferences
- [ ] Add health insights widgets to home screen
- [ ] Build symptom tracking feature
- [ ] Implement perimenopause tracking screen
- [ ] Add smart reminders and notifications service
- [ ] Create content library screen with health articles
- [ ] Add Wear OS integration for smartwatch tracking

## Dependencies

Required packages:
- `freezed_annotation` - For generating freezed models
- `provider` - State management
- `uuid` - Unique ID generation

## Running the App

```bash
flutter pub get
flutter run
```
