# PLAN.md — Witchy Period Tracker & Cycle Calendar App

A full, **ready-for-production implementation plan** for a comprehensive health tracking application that helps users understand and monitor their menstrual cycle, fertility window, pregnancy, and overall reproductive health.

The project is a fresh Flutter scaffold (only `lib/main.dart`, no dependencies yet). This plan is split into **Phases**. Each phase is a list of tasks that MUST be completed **one-by-one**. At the **end of every phase** the project MUST be **error-free and buildable**.

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
| Release | `flutter build apk --release` + `flutter build ios --release --no-codesign` | End of phase 11 |

> If a gate fails, fix the error and run the gate again before moving to the next task.

## Project Structure

```
lib/
├── main.dart                          # entry point: runApp(WitchyApp)
├── app/
│   ├── app.dart                       # WitchyApp root widget
│   ├── app_bootstrap.dart             # loads stored data before UI renders
│   └── router/
│       ├── appraisal_route_path.dart
│       ├── appraisal_router_delegate.dart
│       └── appraisal_route_information_parser.dart
├── models/                            # core shared models
├── services/                          # storage, cycle calculation, reminders
├── providers/                         # shared/exposed providers
├── screens/                           # framework-level screens (splash, shell)
├── widgets/                           # shared primitives
├── utils/                             # constants, date helpers
└── features/
    ├── onboarding/
    ├── calendar/
    ├── logging/
    ├── insights/
    ├── symptoms/
    ├── pregnancy/
    ├── perimenopause/
    ├── reminders/
    ├── auth/
    ├── couples/
    ├── content/
    └── settings/
assets/
├── images/
└── content/                           # seeded articles (privacy-first)
test/
```

---

## Phase 0 — Project Configuration & Essential Infrastructure

> Everything later builds on this baseline.

- [x] **0.1** Add base dependencies to `pubspec.yaml`: `provider`, `shared_preferences`, `uuid`, `intl`, `freezed`, `freezed_annotation`, `json_serializable`, `build_runner`, `font_awesome_flutter`, `device_info_plus`, `url_launcher`. Dev: `build_runner`, `flutter_lints`.
- [x] **0.2** Run `flutter pub get`, then `flutter pub run build_runner build --delete-conflicting-outputs`.
- [x] **0.3** Create the folder skeleton from `Project Structure` above + `assets/` (empty `web/` + `content/`).
- [x] **0.4** Design system: `utils/app_theme.dart` (material color scheme, typography, spacing, light + dark themes) and shared widget primitives in `lib/widgets/` (AppButton, AppCard, AppText, AppIcon).
- [x] **0.5** Navigator 2.0 setup: `AppRoutePath` (sealed hierarchy: Splash, Shell, Onboarding), `AppRouterDelegate` (Extends `PopNavigatorRouterDelegateMixin<AppRoutePath>`), `AppRouteInformationParser` (`RouteInformationParser<AppRoutePath>`), and K `MaterialApp.router`.
- [x] **0.6** Root bootstrap: `app/app.dart` with root `MultiProvider` + `AppBootstrap` (async load placeholder).
- [x] **0.7** Replace scaffold `lib/main.dart` pointing at `MaterialApp.router`.

**Gate (0):** ✅ `flutter analyze` clean, `flutter build apk --debug` succeeds, `flutter test` passes, `flutter run` boots to shell screen.

---

## Phase 1 — Data Layer & Core Local Storage

>> Creates offline-first persisted storage that honors the privacy mission.

- [x] **1.1** Freezed models: `UserProfile`, `PeriodLog`, `Cycle`, `SymptomLog`, `Reminder`, `Article` (fields, equality, `copyWith`). Nested `TimeOfDayModel` moved to its own file.
- [x] **1.2** `json_serializable` `fromJson`/`toJson` for each model. Added `build.yaml` with `explicit_to_json: true` for nested freezed types.
- [x] **1.3** `StorageService`: typed get/set/remove wrappers over `shared_preferences`, key-namespacing, error handling, `clear`.
- [x] **1.4** Repository layer: `ProfileRepository`, `CycleRepository`, `LogsRepository`, `ReminderRepository` — CRUD + persist/load, in-memory cache + disk sync (via `PersistedListMixin`).
- [x] **1.5** Provider layer: `AppStateProvider` (async load of all repos at boot), provided through the widget tree on bootstrap completion.
- [x] **1.6** Unit tests: model (de)serialization; repository round-trip with a mock `shared_preferences` (`SharedPreferences.setMockInitialValues`).
- [x] **1.7** Run `build_runner`.

**Gate (phase):** ✅ `flutter analyze`, ✅ `flutter build apk --debug`, ✅ `flutter test` (15 tests) all pass.

---

## Phase 2 — Cycle Domain Logic (the engine)

- [x] **2.1** `CycleCalculator` service: cycle-length, period-length, next-period prediction (reverse-count luteal phase), ovulation date, fertile window. Injectable `now` for testability.
- [x] **2.2** `CalendarFetcher`: month-grid generation (42-cell, Monday-start); mark period days, fertile days, ovulation day, predicted days.
- [x] **2.3** Cycle phasing utilities: `CyclePhase` (menstrual / follicular / ovulatory / luteal) + `phaseAt`.
- [x] **2.4** `CycleProvider` (ChangeNotifier): point flow — add/edit/delete logs, recompute predictions reactively.
- [x] **2.5** Prediction edge cases: irregular/overdue cycles, first-log, missing data (profile `firstPeriodDate` fallback, median-length adaptation).
- [x] **2.6** Unit tests: ovulation, fertile window, next-period across multiple realistic datasets (22 tests for engine + fetcher + provider).
- [x] **2.6b** Fixed `PersistedListMixin.update/remove` to match by `idOf` (value-equality matching broke `copyWith` updates).

**Gate (phase):** ✅ analyze clean, ✅ build, ✅ tests green (37 total).

---

## Phase 3 — Core Tracking UI (calendar, dashboard, onboarding)

- [x] **3.1** Calendar widget: custom `CycleCalendar` (42-cell Monday-first grid), colored day states (period / fertile / ovulation / predicted), swipe + arrow navigation. Moved into `features/calendar/`.
- [x] **3.2** Logging flow: `LogPeriodSheet` (intensity chips, symptom chips, mood, notes) + `LoggingScreen` with recent logs.
- [x] **3.3** `HomeScreen` dashboard: today's phase, cycle day, next-period countdown, fertile window card.
- [x] **3.4** `OnboardingScreen` in `features/onboarding/` (old `screens/` placeholder removed): last period date, cycle length, period length → saves profile + logs first day + navigates to shell.
- [x] **3.5** App shell bottom nav wired to real Home / Calendar / Logging screens + `CycleProvider` provided via `MultiProvider` in `app.dart`.
- [x] **3.6** Navigation wiring: boot → onboarding (first run) → shell; `AppRouterDelegate._destinationAfterBootstrap()`.

**Gate:** ✅ analyze, ✅ build, ✅ tests (38). Manual smoke deferred to a device run.

---

## Phase 4 — Insights, Symptoms & Reports

- [ ] **4.1** Symptom tracker CRUD with categories + `SymptomPatternService` (recurrence + trend detection).
- [ ] **4.2** Cycle history view: past cycles list with average/count/metrics.
- [ ] **4.3** Trend & graphs using `fl_chart` (cycle length, symptoms over time, prediction accuracy).
- [ ] **4.4** Report generation: per-month summary screen (lengths, symptoms, insights) — be careful to use existing/safe data.
- [ ] **4.5** Merritt per the privacy mission: all reports computed locally.

**Gate (phase):** analyze, build, `flutter test` green.

---

## Phase 5 — Pregnancy & Perimenopause Trackers

- [ ] **5.1** Pregnancy mode: weeks/trimester calculator, phase-based guidance content.
- [ ] **5.2** Perimenopause mode: localized symptom categories + personalized tracking.
- [ ] **5.3** Shared accurate text/insight rendering for both modes.
- [ ] **5.4** Mode switching from Settings; state persisted in `ProfileRepository`.
- [ ] **5.5** Integrate into shell navigation (mode-aware home).

**Gate:** analyze, build, test.

---

## Phase 6 — Notifications & Smart Reminders

> Requires platform config (Android exact alarms, iOS notification permissions).

- [ ] **6.1** Add `flutter_local_notifications` + `timezone` + `flutter_timezone`; init and request permissions.
- [ ] **6.2** `ReminderService`: schedule period-start/end, medication, water, sleep, custom reminders.
- [ ] **6.3** Reminder CRUD UI (`ReminderRepository` + screen), selectable frequencies.
- [ ] **6.4** Platform config: AndroidManifest permissions (`POST_NOTIFICATIONS`, `SCHEDULE_EXACT_ALARM`), iOS `Info.plist` notification settings, plugin init in `AndroidManifest`/`AppDelegate`.
- [ ] **6.5** Nice defaults + permission-denied fallback UI.

**Gate:** analyze, build. Notifications require device; verify platform config manually on a device.

---

## Phase 7 — Authentication & Couples Mode (placeholder)

- [ ] **7.1** Add `google_sign_in` + `sign_in_with_apple` deps.
- [ ] **7.2** `AuthService` + `AuthProvider`; persisted session via `shared_preferences`.
- [ ] **7.3** Google Sign-In flow; Apple Sign-In with iOS entitlements (Android fallback non-root).

- [ ] **7.4** Couples Mode: **placeholder only** — local share-token/model + UI stub, real backend deferred. Document design.

- [ ] **7.5** Auth UI (sign-in/sign-up screen) + optional account creation during onboarding.

**Gate:** analyze, build, auth flow manual test on device.

---

## Phase 8 — Content Library

- [ ] **8.1** `Article`/`Video` models + seeded local content under `assets/content/` (privacy-first: no personal data, curated locally).
- [ ] **8.2** Browse/search/filter UI; categories and favorites (persisted locally).
- [ ] **8.3** Reading/viewing screen for articles.

**Gate:** analyze, build, tests for filtering.

---

## Phase 9 — Privacy, Anonymous Mode & Localization

- [ ] **9.1** Anonymous mode toggle: hides identifiers from persisted data.
- [ ] **9.2** i18n skeleton via `flutter_localizations` + `intl` messages (English default; ARB structure ready for translation).
- [ ] **9.3** Privacy Information screens (Terms of Service, Privacy Policy) supplied locally.
- [ ] **9.4** Settings hub with privacy + anonymous controls.

**Gate:** analyze, build, tests.

---

## Phase 10 — Polish, Icons, Splash & Launch

- [ ] **10.1** `flutter_launcher_icons` config + generate icons (Android + iOS).
- [ ] **10.2** `flutter_native_splash` config + generate splash screen.
- [ ] **10.3** Theming pass: refine light/dark, spacing, accessibility (contrast, text scale).
- [ ] **10.4** Android manifest + `Info.plist` review (permissions minimal: notifications only; no camera/location).
- [ ] **10.5** Deep-link single-parity review of Navigator 2.0 routes (`AppLinkKind`).

**Gate:** analyze clean, `flutter test` green.

---

## Phase 11 — Release Readiness

- [ ] **11.1** Remove all TODO placeholders, prints, dead code; `flutter analyze --fatal-infos`.
- [ ] **11.2** `flutter build apk --release`.
- [ ] **11.3** `flutter build ios --release --no-codesign`.
- [ ] **11.4** Full test suite pass: `flutter test`.
- [ ] **11.5** Final security/privacy audit of persisted keys (no tokens, no PII keys), and README update.

**Gate (release):** `flutter analyze` zero issues, release builds succeed, entire suite green.

---

## Definitions of Done (per task)

- Code compiles; `flutter analyze` clean on that task's files.
- Any new package is listed in the phase, `pub get` + `build_runner` (if codegen) run.
- Feature/service is wired into an buildable `test` if internal logic — otherwise a targeted unit test.

## Compliance guardrails (maintain throughout)

- NO Firebase, NO third-party analytics/tracking.
- All health data stays **on-device** (`shared_preferences`).
- Not a diagnostic/contraception tool — include standard releases in onboarding/settings.
- No PII or identifiers in persisted keys.