# Witchy - Period Tracker & Cycle Calendar App

A comprehensive health tracking application designed to help you understand and monitor your menstrual cycle, fertility window, pregnancy, and overall reproductive health.

## Project Structure

```
lib/
├── main.dart                          # App entry point with Provider setup
├── models/                            # Data models
│   ├── period_cycle.dart              # Period cycle tracking
│   ├── symptom.dart                   # Symptom logging
│   ├── mood.dart                      # Mood tracking
│   ├── user_profile.dart              # User profile data
│   ├── fertility_prediction.dart      # Fertility predictions
│   ├── pregnancy_tracker.dart         # Pregnancy tracking
│   └── notification_model.dart        # Notification settings
├── services/                          # Business logic & API calls
│   ├── storage_service.dart           # Local data persistence
│   ├── cycle_service.dart             # Cycle calculations & predictions
│   └── notification_service.dart      # Push notifications
├── providers/                         # State management (Provider)
│   ├── user_provider.dart             # User profile state
│   ├── period_provider.dart           # Period tracking state
│   ├── fertility_provider.dart        # Fertility predictions state
│   ├── pregnancy_provider.dart        # Pregnancy tracking state
│   └── notification_provider.dart     # Notification management state
├── screens/                           # UI Screens
│   ├── onboarding_screen.dart         # First-time user setup
│   ├── home_screen.dart               # Main dashboard
│   ├── calendar_screen.dart           # Cycle calendar view
│   ├── log_period_screen.dart         # Log period details
│   ├── symptom_log_screen.dart        # Log symptoms
│   ├── mood_log_screen.dart           # Log moods
│   ├── pregnancy_screen.dart          # Pregnancy tracker
│   ├── insights_screen.dart           # Health insights & patterns
│   ├── partner_screen.dart            # Partner sharing feature
│   ├── content_screen.dart            # Health library
│   └── settings_screen.dart           # App settings
└── utils/                             # Utilities (placeholder)
```

---

## Implementation Status

### Phase 1: Initial Setup ✓
- [x] `git init`
- [x] `flutter create . --org com.qvonyx --project witchy`
- [x] Updated pubspec.yaml with required dependencies
- [x] Ran `flutter pub get` successfully

### Phase 2: Core Features ✓
- [x] **Data Models** - Created 7 comprehensive models:
  - PeriodCycle with flow levels and symptoms
  - Symptom tracking with severity levels
  - Mood tracking with multiple emotion types
  - UserProfile with cycle preferences
  - FertilityPrediction with fertile window calculations
  - PregnancyTracker with trimester tracking
  - AppNotification with scheduling support

- [x] **Services** - Implemented 3 core services:
  - StorageService for local data persistence using SharedPreferences
  - CycleService for cycle calculations, ovulation prediction, and fertility windows
  - NotificationService for push notification management

- [x] **State Management** - Built 5 Provider classes:
  - UserProvider for user profile management
  - PeriodProvider for cycle and symptom tracking
  - FertilityProvider for fertility predictions
  - PregnancyProvider for pregnancy tracking
  - NotificationProvider for notification management

- [x] **Screens** - Developed 11 complete screens:
  - OnboardingScreen with multi-page setup
  - HomeScreen with cycle overview and quick actions
  - CalendarScreen with visual cycle calendar
  - LogPeriodScreen with flow level and symptom selection
  - SymptomLogScreen with severity tracking
  - MoodLogScreen with emotion visualization
  - PregnancyScreen with trimester progress
  - InsightsScreen with pattern recognition
  - PartnerScreen for couple sharing
  - ContentScreen with health library
  - SettingsScreen with privacy controls

- [x] **App Integration** - Wired everything together in main.dart:
  - Provider setup with MultiProvider
  - Route configuration
  - Bottom navigation with 4 main tabs
  - Floating action button for quick logging
  - Onboarding flow integration

### Phase 3: Testing & Validation ✓
- [x] Fixed all Flutter analyze errors (0 issues remaining)
- [x] Resolved dependency conflicts (flutter_local_notifications ^19.5.0)
- [x] Updated deprecated API usage (withOpacity → withValues)
- [x] Fixed icon references and type mismatches

---

## Dependencies

All required packages installed and resolved:
- `provider: ^6.1.2` - State management
- `uuid: ^4.5.1` - Unique ID generation
- `shared_preferences: ^2.3.4` - Local data storage
- `flutter_local_notifications: ^19.5.0` - Push notifications
- `intl: ^0.19.0` - Internationalization
- `url_launcher: ^6.3.1` - URL launching
- `font_awesome_flutter: ^10.8.0` - Icons
- `device_info_plus: ^11.2.0` - Device information
- `timezone: ^0.10.1` - Timezone handling
- `fl_chart: ^0.69.2` - Charts (reserved for future use)

---

## Data Storage

The app uses **SharedPreferences** for local data storage:
- User profiles
- Period cycles and history
- Symptoms and moods
- Fertility predictions
- Pregnancy tracking data
- Notification settings

All data stays on-device for maximum privacy.

---

## Key Features Implemented

### 1. Menstrual Cycle Tracking
- Log period start/end dates
- Track flow levels (light to heavy)
- Record symptoms with severity
- Calculate average cycle length
- Predict next period date

### 2. Fertility & Ovulation
- Calculate fertile window (6-day window)
- Predict ovulation date (cycle_length - 14 days)
- Display fertility scores for each day
- Visual calendar indicators

### 3. Pregnancy Tracker
- Calculate gestational week and day
- Estimate due date
- Track trimester progression
- Weekly baby development info
- Pregnancy progress bar

### 4. Symptom & Mood Logging
- 12+ symptom types with severity levels
- 9 mood categories with icons
- Date-based tracking
- Pattern recognition in insights

### 5. Privacy & Security
- No account required
- No third-party data sharing
- All data stored locally
- Anonymous mode available

### 6. Notifications
- Period reminders
- Ovulation alerts
- Customizable notification times
- Local notification scheduling

---

## Running the App

```bash
# Install dependencies
flutter pub get

# Run on connected device/emulator
flutter run

# Build for iOS
flutter build ios

# Build for Android
flutter build apk
```

---

## Next Steps (Future Enhancements)

- [ ] AI Health Assistant chat feature
- [ ] Wear OS integration
- [ ] Advanced chart visualizations using fl_chart
- [ ] Export data functionality
- [ ] Cloud backup option (opt-in)
- [ ] Widget support for home screen
- [ ] Dark mode theme
- [ ] Multi-language support (intl package ready)

---

## Technical Notes

- **State Management**: Provider pattern with ChangeNotifier
- **Data Persistence**: SharedPreferences for offline-first architecture
- **Notifications**: flutter_local_notifications v19.5.0 with zonedSchedule API
- **Type Safety**: Full Dart type annotations and null safety
- **Code Quality**: Zero Flutter analyze warnings or errors

---

## Developer Information

**Developer**: qvonyx.com  
**Email**: witchy@qvonyx.com  
**Version**: 1.0.0

---

*Last updated: August 2026*
