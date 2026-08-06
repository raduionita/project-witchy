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
- `provider` - State management, lazy-loading, wrapper around InheritedWidget
- `shared_preferences` - Storage - local - reading and writing simple key-value pairs
- `google_sign_in` - Google Sign-In
- `sign_in_with_apple` - Apple Sign-In
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

## Implementation status

### Phase 1: Initial Implementation
- [x] `git init`
- [x] `flutter create . --org com.qvonyx --project witchy`
- [ ] TODO

### Phase 2: TODO
- [ ] TODO
