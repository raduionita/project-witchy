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

## Implementation

### Phase 1: Initial Implementation
- [x] `git init`
- [x] `flutter create . --org com.qvonyx --project witchy`
- [ ] ???

### Phase 2: ???
- [ ] ???

---

## Dependencies

Required packages:
- `freezed` - For generating freezed models
- `freezed_annotation` - For generating freezed models
- `provider` - State management
- `uuid` - Unique ID generation
- `shared_preferences` - App preferences
- `flutter_local_notifications` - Notifications
- `flutter_launcher_icons` - App icon generation
- `flutter_native_splash` - App splash screen
- `intl` - Internationalization
- `url_launcher` - URL launching
- `json_serializable` - JSON serialization
- `font_awesome_flutter` - Icons
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
