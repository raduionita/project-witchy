# PLAN.md - Witchy - Period Tracker & Cycle Calendar App

A comprehensive health tracking application designed to help you understand and monitor your menstrual cycle, fertility window, pregnancy, and overall reproductive health.

## Project Structure

```
lib/
├── main.dart                          # app entry point with Provider setup
├── models/                            # Models (i.e. profile, etc.)
├── services/                          # API calls  
├── providers/                         # Providers
├── screens/                           # Screens
├── widgets/                           # Widgets common to screens
└── utils/
```

---

## Dependencies

Required packages:
- `provider` - State management
- `shared_preferences` - Storage - reading and writing simple key-value pairs
- `freezed` - For generating freezed models
- `freezed_annotation` - For generating freezed models
- `uuid` - Unique ID generation
- `flutter_local_notifications` - Notifications
- `flutter_launcher_icons` - App icon generation
- `flutter_native_splash` - App splash screen
- `intl` - Internationalization
- `url_launcher` - Launching a URL. Supports web, phone, SMS, and email schemes
- `json_serializable` - Auto-generate code for converting to and from JSON by annotating Dart classes
- `font_awesome_flutter` - The Font Awesome Icon pack available as Flutter Icons
- `device_info_plus` - Device information

--- 

## Data Storage

The app uses shared_preferences to store user data locally.

---

## Running the App

```bash
flutter pub get
flutter run
```

---

## Implementation status

### Phase 1: Initial Implementation ✓ COMPLETE
- [x] `git init`
- [x] `flutter create . --org com.qvonyx --project witchy`
- [x] Added dependencies (provider, shared_preferences, uuid, flutter_local_notifications, intl, url_launcher, font_awesome_flutter, device_info_plus)
- [x] Created models (PeriodCycle, Profile, Symptom)
- [x] Created services (PeriodTrackingService, NotificationService)
- [x] Created providers (CycleProvider, ProfileProvider)
- [x] Created screens (HomeScreen, CalendarScreen, PeriodTrackerScreen, InsightsScreen)
- [x] Created utilities (CycleCalculator)
- [x] Updated main.dart with Provider setup and navigation
- [x] All LSP errors resolved (flutter analyze passes with no issues)

### Phase 2: Advanced Features ✓ COMPLETE
- [x] Implement fertility window predictions (CycleCalculator)
- [x] Implement symptom pattern recognition (InsightsScreen)
- [x] Add pregnancy tracker (PregnancyTrackerScreen)
- [x] Add AI health assistant chat (HealthAssistantScreen)
- [x] Implement perimenopause tracking (PerimenopauseTrackerScreen)
- [ ] Implement smart reminders and notifications (stub implemented, API pending)
- [x] Implement data export functionality (DataExportService)
- [ ] Add Wear OS integration (requires native code)
- [x] Implement couple sharing feature (CoupleSharingScreen)

### Phase 3: Polish & Launch
- [ ] Add app icon and splash screen
- [ ] Implement internationalization (i18n)
- [ ] Add comprehensive testing
- [ ] Performance optimization
- [ ] App store submission preparation
