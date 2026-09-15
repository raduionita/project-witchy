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
| Release | `flutter build apk --release` + `flutter build ios --release --no-codesign` | End of the **final** phase (Phase 18) |

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
    ├── fertility/                       # BBT, cervical mucus, LH/OPK, intimacy, fertility predictor
    ├── wellness/                        # cycle-synced wellness content
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

**Gate:** ✅ `flutter analyze` clean, `flutter build apk --debug` succeeds, `flutter test` passes, `flutter run` boots to shell screen.

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

**Gate:** ✅ `flutter analyze`, ✅ `flutter build apk --debug`, ✅ `flutter test` (15 tests) all pass.

---

## Phase 2 — Cycle Domain Logic (the engine)

- [x] **2.1** `CycleCalculator` service: cycle-length, period-length, next-period prediction (reverse-count luteal phase), ovulation date, fertile window. Injectable `now` for testability.
- [x] **2.2** `CalendarFetcher`: month-grid generation (42-cell, Monday-start); mark period days, fertile days, ovulation day, predicted days.
- [x] **2.3** Cycle phasing utilities: `CyclePhase` (menstrual / follicular / ovulatory / luteal) + `phaseAt`.
- [x] **2.4** `CycleProvider` (ChangeNotifier): point flow — add/edit/delete logs, recompute predictions reactively.
- [x] **2.5** Prediction edge cases: irregular/overdue cycles, first-log, missing data (profile `firstPeriodDate` fallback, median-length adaptation).
- [x] **2.6** Unit tests: ovulation, fertile window, next-period across multiple realistic datasets (22 tests for engine + fetcher + provider).
- [x] **2.6b** Fixed `PersistedListMixin.update/remove` to match by `idOf` (value-equality matching broke `copyWith` updates).

**Gate:** ✅ analyze clean, ✅ build, ✅ tests green (37 total).

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

- [x] **4.1** Symptom tracker CRUD with categories + `SymptomPatternService` (recurrence + trend detection).
- [x] **4.2** Cycle history view: past cycles list with average/count/metrics.
- [x] **4.3** Trend & graphs using `fl_chart` (cycle length, symptoms over time, prediction accuracy).
- [x] **4.4** Report generation: per-month summary screen (lengths, symptoms, insights) — be careful to use existing/safe data.
- [x] **4.5** Merritt per the privacy mission: all reports computed locally.

**Gate:** ✅ analyze clean, ✅ `flutter build apk --debug` OK, ✅ `flutter test` 66 passed — **passed**. (Symptom CRUD lives in `features/logging/`; reports computed locally per 4.5.)

---

## Phase 5 — Pregnancy & Perimenopause Trackers

- [x] **5.1** Pregnancy mode: weeks/trimester calculator, phase-based guidance content.
- [x] **5.2** Perimenopause mode: localized symptom categories + personalized tracking.
- [x] **5.3** Shared accurate text/insight rendering for both modes.
- [x] **5.4** Mode switching from Settings; state persisted in `ProfileRepository`.
- [x] **5.5** Integrate into shell navigation (mode-aware home).

**Gate:** ✅ analyze clean, ✅ `flutter build apk --debug` OK, ✅ `flutter test` 78 passed — **passed**. (Fixed days-to-go calc to use 40 weeks; added targeted tests for guidance, catalog, shared text, and Settings mode-switch.)

---

## Phase 6 — Notifications & Smart Reminders

> Requires platform config (Android exact alarms, iOS notification permissions).

- [x] **6.1** Add `flutter_local_notifications` + `timezone` + `flutter_timezone`; init and request permissions.
- [x] **6.2** `ReminderService`: schedule period-start/end, medication, water, sleep, custom reminders.
- [x] **6.3** Reminder CRUD UI (`ReminderRepository` + screen), selectable frequencies.
- [x] **6.4** Platform config: AndroidManifest permissions (`POST_NOTIFICATIONS`, `SCHEDULE_EXACT_ALARM`), iOS `Info.plist` notification settings, plugin init in `AndroidManifest`/`AppDelegate`.
- [x] **6.5** Nice defaults + permission-denied fallback UI.

**Gate:** ✅ analyze clean, ✅ `flutter build apk --debug` OK, ✅ `flutter build ios --release --no-codesign` OK, ✅ `flutter test` 102 passed — **passed**. Device verification of delivered notifications still required. Notes: `flutter_timezone` pinned to `^4.1.1` (5.x needs Kotlin 1.9+); Android desugaring enabled for the plugin; iOS needs no Info.plist change (permission is requested at runtime in Dart); period reminders schedule a one-shot at the predicted cycle date and re-anchor on prediction changes.

---

## Phase 7 — Authentication & Couples Mode (placeholder)

- [x] **7.1** Add `google_sign_in` + `sign_in_with_apple` deps.
- [x] **7.2** `AuthService` + `AuthProvider`; persisted session via `shared_preferences`.
- [x] **7.3** Google Sign-In flow; Apple Sign-In with iOS entitlements (Android fallback non-root).
- [x] **7.4** Couples Mode: **placeholder only** — local share-token/model + UI stub, real backend deferred. Document design.
- [x] **7.5** Auth UI (sign-in/sign-up screen) + optional account creation during onboarding.

**Gate:** ✅ analyze clean, ✅ `flutter build apk --debug` OK, ✅ `flutter build ios --release --no-codesign` OK, ✅ `flutter test` 123 passed — **passed**. Auth flow manual test on device still required. Notes: NO Firebase — sessions are local-only identities persisted via `shared_preferences` (`witchy.auth.session`, no tokens/PII); `AuthSession` is a freezed model with `google`/`apple` providers behind an `AuthGateway` interface (native plugins swappable for tests); Apple Sign-In needs the iOS `Runner.entitlements` (`com.apple.developer.applesignin`, wired into all Runner configs) and a real Apple developer account; Google Sign-In needs `google-services.json` (Android) / `GoogleService-Info.plist` + URL scheme (iOS) from the Google Cloud Console before device flows work — until then the UI surfaces a friendly "not configured" message instead of crashing. Couples mode is a local stub: `CoupleLink` model + 12-char `XXXX-XXXX-XXXX` share code generated on-device, nothing transmitted.

---

## Phase 8 — Content Library

- [x] **8.1** `Article`/`Video` models + seeded local content under `assets/content/` (privacy-first: no personal data, curated locally).
- [x] **8.2** Browse/search/filter UI; categories and favorites (persisted locally).
- [x] **8.3** Reading/viewing screen for articles.

**Gate:** ✅ analyze clean, ✅ `flutter build apk --debug` OK, ✅ `flutter test` 178 passed — **passed**. Notes: `Article` existed since Phase 1; added freezed `Video` model + generated code, seeded 8 articles / 4 videos in `assets/content/*.json` (registered in pubspec). `ContentSource` (abstract) + `AssetContentSource` keep the loader testable. `ContentProvider` loads the catalog, persists favorites (`witchy.content.favorites` — content IDs only, no PII) via `StorageService`, and drives a pure `filterContent` (type/category/query). New `Library` bottom-nav tab (6 tabs) hosting browse/search/`SegmentedButton` type filter/category chips/favorite stars; articles open `ArticleReaderScreen`, videos open `VideoDetailScreen` (launches via `url_launcher`). 10 new tests for filtering + favorites persistence. Caveat: the library uses a static loading text instead of an indeterminate spinner — a repeating spinner animation leaks across `testWidgets` cases in one process and hangs `pumpAndSettle`.

---

## Phase 9 — Privacy, Anonymous Mode & Localization

- [x] **9.1** Anonymous mode toggle: hides identifiers from persisted data.
- [x] **9.2** i18n skeleton via `flutter_localizations` + `intl` messages (English default; ARB structure ready for translation).
- [x] **9.3** Privacy Information screens (Terms of Service, Privacy Policy) supplied locally.
- [x] **9.4** Settings hub with privacy + anonymous controls.

**Gate:** ✅ analyze clean, ✅ `flutter build apk --debug` OK, ✅ `flutter build ios --release --no-codesign` OK, ✅ `flutter test` 191 passed — **passed**. Notes: `PrivacyProvider` persists the anonymous-mode flag (`witchy.privacy.anonymousMode`); enabling it in Settings also clears the stored auth session (`witchy.auth.session`) so no name/email identifier remains on device, and the account card is hidden while active. i18n uses Flutter gen-l10n: `l10n.yaml` + `lib/l10n/app_en.arb` (English template; `synthetic-package: false` writes `app_localizations*.dart` into `lib/l10n/`), delegates wired into `MaterialApp.router`, first strings adopted by the Settings hub. Legal screens are local-only curated content (`legal_content.dart` + reusable `LegalDocumentScreen`) opened from Settings. An in-app language switcher sits **above** the theme card in Settings via `LocaleProvider` (`AppLocaleOption.system`/`english`/`spanish`, persisted under `appearance.locale`); the system option defers to the device locale with English as the fallback when a device language is unsupported. `app_es.arb` adds Spanish, and switching to Español live-localizes the screen. 11 new tests (locale provider unit tests, l10n Spanish resolution, settings language-switch ordering test); the two stale "coming soon" privacy tests were replaced.

---

## Phase 10 — Polish, Icons, Splash & Launch

- [x] **10.1** `flutter_launcher_icons` config + generate icons (Android + iOS).
- [x] **10.2** `flutter_native_splash` config + generate splash screen.
- [x] **10.3** Theming pass: refine light/dark, spacing, accessibility (contrast, text scale).
- [x] **10.4** Android manifest + `Info.plist` review (permissions minimal: notifications only; no camera/location).
- [x] **10.5** Deep-link single-parity review of Navigator 2.0 routes (`AppLinkKind`).

**Gate:** analyze clean, `flutter test` green.

> **Gate:** ✅ `flutter analyze` clean, ✅ `flutter test` 201 passed, ✅ `flutter build apk --debug`, ✅ `flutter build ios --release --no-codesign` — **passed**. Notes: Brand assets generated in `assets/images/` (Deep Plum `#2D1B4E` + gold crescent-moon emblem per DESIGN.md): `icon/app_icon.png` (launcher), `icon/app_icon_foreground.png` (Android adaptive foreground), `splash/splash_logo.png` (native splash, light + dark). Theming pass rewrote `utils/app_theme.dart` around the DESIGN.md palette (plum primary, gold secondary, rose tertiary, `#FAF6F8` surface, `#1E1333` text), added a proper dark scheme with light-lavender primary for contrast, and component themes (cards, inputs, chips, navigation bar, tooltips, text selection); in-app `SplashScreen` now shows the moon emblem. Manifest review: added `POST_NOTIFICATIONS` (Android 13+ runtime) and corrected the app label to `Witchy`; iOS `Info.plist` stays minimal (no location/camera/photo keys). Deep-link parity codified via new `AppLinkKind` enum in `app_route_path.dart` (single source of truth for `/`, `/onboarding`, `/shell`), consumed by the parser with unknown paths falling back to splash; 6 new router tests added.

---

## Phase 11 — Biometric & Fertility Logging (DESIGN Screens 06, 09)

> Gap: DESIGN.md specs BBT, cervical mucus, LH/OPK reader, pregnancy tests and intimacy logging (Screen 06); none exist today — `PeriodLog`/`SymptomLog` only carry flow/symptoms/mood/notes.

- [x] **11.1** Data model: `CervicalMucusType` (dry/sticky/creamy/watery/eggwhite), `OvulationTestResult` (negative/high/peak), `PregnancyTestResult` (negative/positive), `BbtReading` (date, tempC, takenAt, notes), `IntercourseLog` (date, notes); per-day `BiometricLog` aggregator.
- [x] **11.2** Storage: `BiometricRepository` (CRUD + persist/load via `PersistedListMixin`), `BiometricProvider` (ChangeNotifier) wired into `AppStateProvider`.
- [x] **11.3** Logging UI: BBT quick-entry keypad (decimal, logged-at timestamp), mucus chips, LH/pregnancy-test reader toggle, intimacy toggle — surfaced from the existing log sheets + Calendar/Home long-press.
- [x] **11.4** Calendar day cells show data symbols (droplet = flow, thermometer = BBT, sparkle = LH peak, heart = intimacy) and the day-strip/today panel surfaces today's BBT + peak status.
- [x] **11.5** i18n strings (en + es) + unit/widget tests (repository round-trip, reader states, symbol mapping).

**Gate:** analyze clean, `flutter build apk --debug`, `flutter test` green.

> **Gate:** ✅ `flutter analyze` clean, ✅ `flutter build apk --debug` OK, ✅ `flutter test` 211 passed — **passed**. Notes: New freezed models `BbtReading`, `IntercourseLog` and the per-day `BiometricLog` aggregator (with enums `CervicalMucusType`, `OvulationTestResult`, `PregnancyTestResult`) live in `lib/models/`; `BiometricRepository` adds the `witchy.biometric_logs` key via `PersistedListMixin` and is loaded/cleared with `AppStateProvider`; `BiometricProvider` (registered in `app.dart`) upserts by date preserving the day id, exposes `bbtOn`/`ovulationTestOn`/`markersFor`, and drives `LogBiometricsSheet` (BBT ±0.05°C stepper + direct entry + logged-at time picker, mucus chips, deselectable LH/pregnancy-test chips, intimacy switch, clear-day). Biometric entry points: new tile on the Logging tab, thermostat button in the calendar header + today panel, both opening the sheet for today. `CalendarDay` gained `CalendarDayMarker` (flow/bbt/lhPeak/intimacy) + a `markers` list rendered as tiny icons (new `DayMarkersRow` widget) in the calendar grid and home day strip; the today panel shows `BBT 36.45°C · LH Peak` badges. 10 new tests (model serialization, provider upsert/remove/markers, repository round-trip, calendar marker rendering, sheet save flow).

---

## Phase 12 — Fertility Analytics: BBT Chart & Fertility Predictor (DESIGN Screens 08, 09)

> Gap: no BBT chart or dedicated fertility predictor exist; insights are cycle-length/symptom focused only.

- [ ] **12.1** `BbtChartService`: per-cycle coverline (follicular/luteal baseline split), biphasic-shift detection, ovulation confirmation (3 consecutive elevated readings), shift magnitude (+°C).
- [ ] **12.2** BBT chart screen (`/insights/bbt`): `fl_chart` line graph with coverline overlay, vertical ovulation marker, LH/mucus overlay toggles, clinical-interpretation box; cycle selector dropdown.
- [ ] **12.3** Fertility predictor screen (`/fertility/window`): 7-day conception window with per-day probability estimates, fertility scorecard aligning BBT shift + LH peak + egg-white mucus, intimacy-logger shortcut.
- [ ] **12.4** Wire both into the Insights tab + deep links; TTC-adjacent insights surfaced on the home dashboard.
- [ ] **12.5** i18n + tests (coverline/ovulation math, probability model, chart data assembly).

**Gate:** analyze clean, `flutter build apk --debug`, `flutter test` green.

---

## Phase 13 — TTC Mode & Contraceptive Baseline (DESIGN Screens 02, 03, 04)

> Gap: DESIGN defines four lifecycle goals (Cycle, TTC, Pregnancy, Perimenopause) — only three exist; no hormonal/contraceptive method affects predictions; the DESIGN hero cycle clock is not implemented.

- [ ] **13.1** New `TrackingMode.ttc` (Trying to Conceive): labels/descriptions in en + es, home hands off to a fertility-first dashboard, shell + settings integrated.
- [ ] **13.2** `HormonalMethod` enum (none/combinedPill/progestinOnly/hormonalIud/copperIud/implant/patch/ring) persisted on `UserProfile`; methods that suppress ovulation hide fertile-window predictions with an explanatory note.
- [ ] **13.3** Cycle clock: circular dial hero on home (outer color-coded phase ring, animated illumination per DESIGN 5.1, center "Day N" + status); pregnancy mode swaps to a gestational-week dial; BBT/fertility quick badges.
- [ ] **13.4** Onboarding: 4-goal selector (Cycle/TTC/Pregnancy/Perimenopause) + hormonal-method picker in the baseline step; settings gains a method picker.
- [ ] **13.5** i18n + tests (prediction suppression logic, clock phase mapping, onboarding goal flow).

**Gate:** analyze clean, `flutter build apk --debug`, `flutter test` green.

---

## Phase 14 — Calendar Pro & Cycle-Synced Wellness (DESIGN Screens 05, 11)

> Gap: the Calendar tab is a bare month grid (no view toggle, no date-summary panel); the content library is not cycle-phase aware.

- [ ] **14.1** Calendar: Month vs 6-Month view toggle; selected-date summary panel (phase, logged symptoms, BBT, LH, mucus, intimacy) with an "Edit log" action.
- [ ] **14.2** Wellness: `Article` gains `cyclePhase` + `wellnessCategory` (nutrition/movement/herbal/self-care); library gets phase filter tabs (Menstrual/Follicular/Ovulatory/Luteal/Pregnancy/Postpartum).
- [ ] **14.3** Seed phase-tagged wellness content under `assets/content/` (regenerated/registered in pubspec).
- [ ] **14.4** i18n + tests (filter logic, summary-panel assembly, seeded-content parse).

**Gate:** analyze clean, `flutter build apk --debug`, `flutter test` green.

---

## Phase 15 — Privacy, Security & Data Sovereignty (DESIGN Screen 14)

> Gap: `StorageService` has no schema versioning or per-entry defensive decode; no app lock, no incognito notifications, and no data export exist (only anonymous mode + clear-all).

- [ ] **15.1** Storage hardening: `schemaVersion` key + ordered migration map in `StorageService`; defensive decoding so one corrupt entry never wipes or fails a whole repository load.
- [ ] **15.2** Biometric app lock: add `local_auth`; opt-in FaceID/TouchID gate over the shell; friendly unavailable fallback; persisted preference.
- [ ] **15.3** Incognito notifications: `PrivacyProvider` flag that rewrites reminder titles/bodies to neutral text (no "period/fertility" labels).
- [ ] **15.4** CSV export of the full health record (profile, cycles, period/symptom/biometric logs, reminders) via share/`url_launcher` or file save; JSON import for restore; clear privacy notes.
- [ ] **15.5** i18n + tests (migration path, defensive decode, incognito rewriting, CSV assembly).

**Gate:** analyze clean, `flutter build apk --debug`, `flutter test` green.

---

## Phase 16 — Health Sync & Wearables, Privacy-First (DESIGN Screen 13, README Wear OS)

> Gap: Screen 13 (HealthKit / Health Connect / wearable temperature) and the README's Wear OS integration are unimplemented. Must stay privacy-first: device-to-device stores only, no cloud.

- [ ] **16.1** `HealthSyncGateway` abstraction (permission scopes, read/write direction, status) so sync is testable and swappable.
- [ ] **16.2** HealthKit + Health Connect integration: permission-gated toggles syncing periods/BBT/mucus; explicit consent banners; platform channels or documented deferred stubs.
- [ ] **16.3** Wearable temperature import placeholder (Oura / Apple Watch wrist temp) as status rows with "Connected"/"Not connected" stubs and a sync-preferences screen.
- [ ] **16.4** Sync preferences screen under Settings; all writes gated on explicit per-data-point consent; privacy warning banner.
- [ ] **16.5** Tests for the gateway contract + preference persistence.

**Gate:** analyze clean, `flutter build apk --debug`, `flutter test` green.

---

## Phase 17 — Pregnancy Pro, Notification Deep Links & Final Polish

> Gap: pregnancy is trimester-level only (no appointments, no week-by-week size/milestones); notification taps do not deep-link; `AppLinkKind` only covers `/`, `/onboarding`, `/shell`.

- [ ] **17.1** Prenatal appointments: model + CRUD + card on the pregnancy home (due-date countdown, "next appointment"); schedule appointment reminders via `ReminderService`.
- [ ] **17.2** Week-by-week fetal size/milestones content (curated, localized, non-clinical).
- [ ] **17.3** Notification-tap handling (`onDidReceiveNotificationResponse`) routing to the relevant screen (reminders → Reminders, appointment → Pregnancy).
- [ ] **17.4** Expand deep-link parity: `AppLinkKind` covers all main destinations (dashboard, calendar, insights, library, pregnancy, settings, reminders); parser + router tests.
- [ ] **17.5** i18n + tests.

**Gate:** analyze clean, `flutter build apk --debug`, `flutter test` green.

---

## Phase 18 — Release Readiness (final)

- [ ] **18.1** Remove all TODO placeholders, prints, dead code; `flutter analyze --fatal-infos`.
- [ ] **18.2** `flutter build apk --release`.
- [ ] **18.3** `flutter build ios --release --no-codesign`.
- [ ] **18.4** Full test suite pass: `flutter test`.
- [ ] **18.5** Final security/privacy audit of persisted keys (no tokens, no PII keys), store metadata (icons/screenshots/descriptions), and README update.

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
