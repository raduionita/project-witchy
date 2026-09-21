# PLAN.md — Witchy Period Tracker & Cycle Calendar App

A full, **ready-for-production implementation plan** for a comprehensive health tracking application that helps users understand and monitor their menstrual cycle, fertility window, pregnancy, and overall reproductive health.

This plan is split into **Phases**. Each phase is a list of tasks that MUST be completed **one-by-one**. At the **end of every phase** the project MUST be **error-free and buildable**.

---

## Rules & Conventions (apply in every phase)

- **NO Firebase.** Storage uses `shared_preferences`; state uses `provider`.
- **Files**: `snake_case.dart`. **Classes**: `PascalCase`. **Functions/Variables**: `camelCase`. **Constants**: `kPascalCase`. **Private members**: leading underscore `_`.
- **Import order**: Dart → Flutter → Packages → Relative.
- All features live in feature folders: `lib/features/<name>/` containing `models/`, `providers/`, `screens/`, `widgets/`.
- **Navigation**: Navigator 2.0 (`Router` + custom `RouterDelegate` + `RouteInformationParser`).
- **Charts**: `fl_chart`.
- **Couples Mode**: placeholder only (local token, real backend deferred).
- Health data is **privacy-first**: no location, no personal info beyond local storage, no third-party sharing, not a diagnostic tool.

## Completion Gates (MUST pass)

| Gate | Command | When |
|------|---------|------|
| Analyze | `flutter analyze` | After **every task** — zero errors/warnings |
| Build | `flutter build apk --debug` | End of **every phase** |
| Test | `flutter test` | End of **every phase** |
| Release | `flutter build apk --release` + `flutter build ios --release --no-codesign` + `flutter build web` | End of the **final** phase |

> If a gate fails, fix the error and run the gate again before moving to the next task.

## Project Structure

```
lib/
├── main.dart                          # entry point: runApp(WitchyApp)
├── models/                            # core shared models
├── services/                          # storage, cycle calculation, reminders
├── providers/                         # shared/exposed providers
├── screens/                           # framework-level screens (splash, shell)
├── widgets/                           # shared primitives
├── utils/                             # constants, date helpers
├── theme/
assets/
├── images/
└── content/                           # seeded articles (privacy-first)
test/
```

---

## Phase 0 — Project Configuration & Essential Infrastructure

> Everything later builds on this baseline.

- [ ] **0.1** Add base dependencies to `pubspec.yaml`: `provider`, `shared_preferences`, `uuid`, `intl`, `freezed`, `freezed_annotation`, `json_serializable`, `build_runner`, `font_awesome_flutter`, `device_info_plus`, `url_launcher`. Dev: `build_runner`, `flutter_lints`.
- [ ] **0.2** Run `flutter pub get`, then `flutter pub run build_runner build --delete-conflicting-outputs`.
- [ ] **0.3** Verify the folder skeleton from `Project Structure` above + `assets/` (empty `images/` + `content/`).
- [ ] **0.4** Design system: `theme/` (color scheme, typography, spacing) and shared widget primitives in `lib/widgets/` (AppButton, AppCard, AppText, AppIcon).
- [ ] **0.5** Simple navigation: `MaterialApp.routes`.
- [ ] **0.6** Root bootstrap: `MultiProvider` + `AppBootstrap` (async load placeholder).

**Gate:** `flutter analyze`, `flutter build apk --debug`, `flutter test`,`flutter run`

---

## Phase 1 — Data Layer & Core Local Storage

>> Creates offline-first persisted storage that honors the privacy mission.

- [ ] **1.1** Freezed models: `UserProfile`, `PeriodLog`, `Cycle`, `SymptomLog`, `Reminder`, `Article` (fields, equality, `copyWith`). Nested `TimeOfDayModel` moved to its own file.
- [ ] **1.2** `json_serializable` `fromJson`/`toJson` for each model. Added `build.yaml` with `explicit_to_json: true` for nested freezed types.
- [ ] **1.3** `StorageService`: typed get/set/remove wrappers over `shared_preferences`, key-namespacing, error handling, `clear`.
- [ ] **1.4** Repository layer: `ProfileRepository`, `CycleRepository`, `LogsRepository`, `ReminderRepository` — CRUD + persist/load, in-memory cache + disk sync (via `PersistedListMixin`).
- [ ] **1.5** Provider layer: `AppStateProvider` (async load of all repos at boot), provided through the widget tree on bootstrap completion.
- [ ] **1.6** Unit tests: model (de)serialization; repository round-trip with a mock `shared_preferences` (`SharedPreferences.setMockInitialValues`).
- [ ] **1.7** Run `build_runner`.

**Gate:** `flutter analyze`, `flutter build apk --debug`, `flutter test`

---
