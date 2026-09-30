# PLAN.md — Witchy Period Tracker & Cycle Calendar App

A full, **ready-for-production implementation plan** for a comprehensive health tracking application that helps users understand and monitor their menstrual cycle, fertility window, pregnancy, and overall reproductive health.

This plan is split into **Phases**. Each phase is a list of tasks that MUST be completed **one-by-one**. At the **end of every phase** the project MUST be **error-free and buildable**.

**Status legend:** `[x]` done · `[~]` done differently (details noted) · `[-]` obsolete (superseded) · `[ ]` open

---

## Rules & Conventions (apply in every phase)

- **NO Firebase.** Storage uses `shared_preferences`; state uses `provider`.
- **Files**: `snake_case.dart`. **Classes**: `PascalCase`. **Functions/Variables**: `camelCase`. **Constants**: `kPascalCase`. **Private members**: leading underscore `_`.
- **Import order**: Dart → Flutter → Packages → Relative.
- **Navigation**: Navigator 2.0 (`Router` + custom `RouterDelegate` + `RouteInformationParser`). *Mandated rule — implemented in Phase 4; until then the app uses named routes.*
- **Charts**: `fl_chart`. *Mandated rule — implemented in Phase 4; `CycleOrb` ring gauge stays custom-painted (fl_chart has no radial gauge).*
- **Couples Mode**: placeholder only (local token, real backend deferred).
- Health data is **privacy-first**: no location, no personal info beyond local storage, no third-party sharing, not a diagnostic tool.

## Completion Gates (MUST pass)

| Gate | Command | When |
|------|---------|------|
| Analyze | `flutter analyze` | After **every task** — zero errors/warnings |
| Build | `flutter build apk --debug` | End of **every phase** |
| Test | `flutter test` | End of **every phase** |
| Release | `flutter build apk --release` + `flutter build ios --release --no-codesign` + `flutter build web` | End of the **final** phase (deferred — more phases expected before release) |

> If a gate fails, fix the error and run the gate again before moving to the next task.

## Project Structure

```
lib/
├── main.dart                          # entry point: runApp(App)
├── models/                            # core shared models
├── services/                          # storage, cycle calculation, reminders
├── providers/                         # shared/exposed providers
├── screens/                           # framework-level screens (splash, shell)
├── widgets/                           # shared primitives
├── utils/                             # constants, date helpers
├── theme/
assets/
├── images/
├── icons/
└── content/                           # seeded articles (privacy-first) — DEFERRED: articles live in lib/models/mock_data.dart
test/
```

---

## Phase 0 — Project Configuration & Essential Infrastructure ✅

> Everything later builds on this baseline.

- [x] **0.1** Add base dependencies to `pubspec.yaml`: kept `provider`, `shared_preferences`, `uuid`, `intl`, `font_awesome_flutter` (+ `google_fonts`, `flutter_svg`, `google_sign_in`, `sign_in_with_apple`). **Dropped as unneeded**: `freezed`, `freezed_annotation`, `json_serializable`, `build_runner`, `device_info_plus`, `url_launcher`, dev `build_runner`. Dev: `flutter_lints`.
- [x] **0.2** Run `flutter pub get`. ~~`flutter pub run build_runner build`~~ — obsolete (no codegen).
- [x] **0.3** Folder skeleton ✓ + `assets/icons` + `assets/images`. `assets/content/` omitted — seeded articles live in `lib/models/mock_data.dart`.
- [x] **0.4** Design system: `lib/theme/` (`AppColors`, `AppText`, `buildAppTheme`) and shared widget primitives in `lib/widgets/` (`AppButton`, `AppCard`, `AppTag`, `AppChip`, `AppTextField`, `AppSliderRow`, `AppTopBar`, `AppBottomNav`, `AppAvatar`, `AppIcons`).
- [x] **0.5** Simple navigation: `MaterialApp.routes` — **note**: temporary stand-in; Navigator 2.0 migration scheduled in Phase 4.
- [x] **0.6** Root bootstrap: async `main()` → `PrefsService` + 5 providers loaded → `MultiProvider` + `MaterialApp` (`App` in `lib/main.dart`).

**Gate:** `flutter analyze`, `flutter build apk --debug`, `flutter test`, `flutter build web` ✅

---

## Phase 1 — Data Layer & Core Local Storage ✅

> Creates offline-first persisted storage that honors the privacy mission.

- [~] **1.1** ~~Freezed models~~ **Done differently**: plain-Dart models — `DayLog`, `Article`, `ReminderItem`, `AlertItem`, `CovenPost`, `CycleSettings`, `AuthIdentity` (one per file, hand-written). No `UserProfile`/`PeriodLog`/`Cycle`/`SymptomLog` — replaced by `DayLog` + `CycleSettings` + `AuthIdentity`.
- [-] **1.2** ~~`json_serializable` + `build.yaml`~~ **Obsolete**: manual `toJson`/`fromJson` only where needed; serialization handled in `PrefsService`.
- [x] **1.3** `PrefsService` (as `StorageService`): typed accessors over `shared_preferences`, `witchy_*` key namespacing, session + settings + day-log getters/setters — `lib/services/prefs_service.dart`.
- [-] **1.4** Repository layer + `PersistedListMixin` — **Obsolete**: persistence lives in each provider (static `load(PrefsService)` + save-on-mutation).
- [~] **1.5** ~~`AppStateProvider`~~ **Done differently**: `AuthProvider`, `OnboardingProvider`, `LoggingProvider`, `SettingsProvider`, `RemindersProvider` individually loaded in `main()` and passed as fields.
- [x] **1.6** Unit tests: model (de)serialization; provider persist→reload round-trip with `SharedPreferences.setMockInitialValues`. ✅ (delivered in Phase 2)
- [-] **1.7** Run `build_runner` — obsolete (no codegen).

**Gate:** `flutter analyze`, `flutter build apk --debug`, `flutter test` ✅

---

## Phase 2 — Test Hardening ✅

> Turns the open 1.6 into real coverage: serialization, persistence, auth.

- [x] **2.1** Serialization round-trip tests: `DayLog`, `AuthIdentity`, `CycleSettings` — `toJson → fromJson` equality; missing/extra JSON keys tolerated.
- [x] **2.2** Provider persistence round-trip tests with `SharedPreferences.setMockInitialValues`: load defaults → mutate (settings incl. lunar/dark/3 share flags, reminders, onboarding `onboarded`, logging `DayLog` map) → save → fresh `load()` verifies values; auth session save/restore/clear.
- [x] **2.3** Auth behavior tests: `signInWithEmail` → signed-in + session persisted **without password**; `AuthProvider.load` restores identity from session; `signOut` clears session + state.

**Gate:** `flutter analyze` ✅, `flutter test` ✅ (20/20), `flutter build apk --debug` ✅

---

## Phase 3 — Cycle Prediction Engine

> Replaces hardcoded mock dates (`'Bleeding In 14 Days / Nov 10'`) with real predictions.

- [x] **3.1** `lib/services/cycle_calculator.dart` — pure functions with injectable `today`: cycle day, phase, next-period date + days remaining, fertile window, ovulation peak day, bleed-day progress (inputs: `lastPeriod`, cycle length, bleed length).
- [x] **3.2** Wire dynamic predictions: Sanctuary stat duo + peak card, `/fertility` window duo, `/cycle` "Day X of Y", `/calendar` fertile/period day coloring (from `lastPeriod` + `CycleSettings` + logged `DayLog`s).
- [x] **3.3** Unit tests: boundary cases — today = period start, cycle wrap into next month, short (20d) / long (40d) cycles.

**Gate:** `flutter analyze` ✅, `flutter test` ✅ (35/35), `flutter build apk --debug` ✅

---

## Phase 4 — Navigator 2.0 + fl_chart

> Fulfills the two mandated rules from §Rules & Conventions.

- [x] **4.1** Add `fl_chart` to `pubspec.yaml`.
- [x] **4.2** Navigator 2.0: `RouteInformationParser<String>` + `RouterDelegate` (stack of route names → `Navigator(pages:)`); replace all `pushNamed` / `pop` / `pushReplacementNamed` / `pushNamedAndRemoveUntil` call sites (~20, incl. `AppTopBar` back) with `context.go()` / `context.back()` / `context.reset()` helpers; preserve `/library/<slug>` dynamic segment + unknown-slug fallback; shell-tab routes stay `MainScreen(initialIndex:)`; web deep links work.
- [x] **4.3** Rebuild `TrendBars` with `fl_chart` `BarChart` (same M1–M7 pur-gradient bars) — `/insights` + `/chart` update automatically. **Exception:** `CycleOrb` ring gauge stays custom-painted (fl_chart has no radial gauge).
- [x] **4.4** Existing widget tests still pass (navigation behavior preserved).

**Gate:** `flutter analyze` ✅, `flutter test` ✅ (35/35), `flutter build apk --debug` ✅, `flutter build web` ✅

---

## Phase 5 — Real Reminders & Profile Identity

> Turns the 5 reminder bells into actual scheduled notifications; shows who signed in.

- [x] **5.1** Add `flutter_local_notifications` + `timezone` / `flutter_timezone`; Android: core-library desugaring in `android/app/build.gradle.kts`, `POST_NOTIFICATIONS` manifest entry; iOS: `requestAuthorization` flow.
- [x] **5.2** `lib/services/notification_service.dart` — init + schedule/cancel per bell (`zonedSchedule`, daily at configured time, `matchDateTimeComponents: time`); pure `buildNotificationRequests()` extracted for testability.
- [x] **5.3** Wire: `RemindersProvider` bell toggles ↔ schedule/cancel; `SettingsProvider.lunarNotifications` ↔ period-prediction alert; existing `PrefsService` persistence unchanged.
- [x] **5.4** Profile identity: header shows `AuthIdentity` display name/email (fallback to current placeholder), **Sign Out** button → `auth.signOut()` → reset stack to `/`.
- [x] **5.5** Tests: `buildNotificationRequests` unit test; sign-out widget test.

**Gate:** `flutter analyze` ✅, `flutter test` ✅ (41/41), `flutter build apk --debug` ✅, `flutter build web` ✅

---

## Phase 6 — Cycle Domain Logic (the engine)

> Review note: draft tasks 2.1–2.6 were renumbered to 6.1–6.7; CycleCalculator already shipped in Phase 3, so 6.1 closes as done and the phase focuses on the genuinely new pieces (fetcher, enum, reactive provider, history adaptation, log integrity).

- [x] **6.1** `CycleCalculator` service: cycle day, next-period, ovulation, fertile window, phase, month day-sets — delivered in Phase 3 (`lib/services/cycle_calculator.dart`), injectable `today` parameter. Extended by 6.3 / 6.6.
- [x] **6.2** `CalendarFetcher` (`lib/services/calendar_fetcher.dart`): `MonthCells` for a month — fixed 42-cell Monday-first grid; per-day flags: predicted period, logged bleed (actual), fertile, ovulation, logged, selected. Consumed by `CycleMapScreen`; `CycleCalendar` becomes purely presentational.
- [x] **6.3** `CyclePhase` enum (`lib/models/cycle_phase.dart`: menstrual / follicular / fertile / ovulatory / luteal — 5 values so `Fertile Window` keeps its own label) + `CycleCalculator.phaseAt(...) → CyclePhase`; themed labels move onto the enum as the single source (`phase()` delegates).
- [x] **6.4** `CycleProvider` (`lib/providers/cycle_provider.dart`, ChangeNotifier): constructed from `OnboardingProvider` + `LoggingProvider`, subscribes to both; exposes **effective** `lastStart`/`cycleLength` (6.6 adaptation), today's cycleDay / phase / next-period / days-until / fertile window / ovulation, and recent bleed chronology; provided in `main.dart` `MultiProvider`; migrated consumers: sanctuary, fertility, cycle_map, blood, settings + `main()` notification prediction (records completes in 7.2).
- [x] **6.5** Log data integrity: `LoggingProvider.deleteDay()`; non-materializing read (`peekDay`/`hasLog` — view code no longer calls `day()`); default flow `'Medium'` → `'None'` (incl. `fromJson` fallback + `day_log_test`); calendar/blood detail cards show placeholders when the day is unlogged.
- [x] **6.6** `PeriodHistory` (`lib/services/period_history.dart`): infer bleed spans from `DayLog.flow != 'None'` days → period start dates, median cycle length, latest start; adaptation rule = ≥2 observed cycle lengths → median + latest logged start, else onboarding settings; **plus backwards multi-cycle wrap** in `CycleCalculator` (dates before `lastStart` now resolve into earlier cycles instead of clamping — past months mark correctly; clamp tests rewritten).
- [x] **6.7** Unit tests: fetcher grids (Feb 2026 Sunday-first, leap-safe, 42 cells), `phaseAt` boundaries + enum labels, history (median odd/even/empty, spans, cycle lengths), `CycleProvider` reactivity + adaptation overrides, log integrity (peek/delete/`'None'` default) — suite 64/64.

**Gate:** `flutter analyze` ✅, `flutter test` ✅ (64/64), `flutter build apk --debug` ✅, `flutter build web` ✅

---

## Phase 7 — Core Tracking UI (calendar, dashboard, onboarding)

> Review note: draft tasks 3.1–3.6 renumbered to 7.1–7.6; several were already delivered under earlier phases (marked `[~]`/`[x]`).

- [x] **7.1** Calendar widget: `CycleCalendar` rebuilt — fixed 6-row / 42-cell Monday-first grid over `MonthCells`, ovulation day marker (pink dot), predicted (outline) vs logged-bleed (solid) styling, horizontal swipe month navigation alongside the arrows, per-cell click cursor.
- [~] **7.2** Logging flow: `LogBottomSheet` (flow / mood / symptom / notes chips) delivered in earlier phases — spec'd "LogPeriodSheet + LoggingScreen" done differently. **Completed**: `RecordsScreen` now shows real data — bleed chronology (range, length, On Time / Short / Long / Current tags vs effective cycle length) + average cycle/bleed from `CycleProvider`, with an empty state for no data.
- [x] **7.3** Home dashboard — delivered as `SanctuaryScreen` (phase orb, cycle day, next-period countdown, fertility window card).
- [x] **7.4** Onboarding (`RhythmsScreen` at `/onboarding`): days 14–20 strip replaced by a tappable date field → native `showDatePicker` (past dates only, default today); `finish()` saves the picked date **and writes the start-day `DayLog`** (`setFlow(..., 'Medium')`), then `reset('/dashboard')`.
- [x] **7.5** Shell bottom nav wired to real screens (`Sanctuary` / `CycleMap` / `Records` / `Coven` + log FAB) — delivered in earlier phases; `CycleProvider` provided in `main.dart` (6.4) — plan's `app.dart` reference obsolete.
- [x] **7.6** Boot navigation — delivered differently: splash post-frame redirect (`onboarded → /dashboard`) + `finish()` `reset('/dashboard')`; no `AppRouterDelegate._destinationAfterBootstrap()` needed.

**Gate:** `flutter analyze` ✅, `flutter test` ✅ (65/65), `flutter build apk --debug` ✅, `flutter build web` ✅

---
## Phase 8 — Entry Flow Rework (welcome, privacy gate, join, onboarding)

> New phase driven by user request: privacy consent screen between welcome and auth, welcome cleanup, join redesign (social + skip only), onboarding year of birth, docs update.

- [x] **8.1** Welcome (was Splash, `lib/screens/welcome_screen.dart`): renamed class/file, bottom "Sign In" link removed, post-frame redirect (`onboarded → /dashboard`) kept; "Awaken Your Power" now routes through the consent gate — `PrefsService.isPrivacyAccepted()` ? `/auth` : `/privacy`.
- [x] **8.2** Privacy gate (`lib/screens/privacy_screen.dart` at `/privacy`): "Your Privacy Promise" copy + 3 checkbox rows (Terms, Privacy Policy, Child Protection) each linking to a new in-app webview (`lib/screens/webview_screen.dart` at `/webview?title&url`, `webview_flutter` ^4.10.0, web falls back to selectable URL card); URLs centralized in `lib/utils/legal_links.dart`; Refuse → back to `/`, Accept (enabled only when all 3 checked) → `setPrivacyAccepted()` then `reset('/auth')`; consent persists (`witchy_privacy_accepted`) so Awaken skips the gate next time.
- [x] **8.3** Join (`lib/screens/join_screen.dart`): email/password form removed (`AuthProvider.signInWithEmail` deleted + tests), `MoonRow` deleted; center = `AppEmblem` + "Join Witchy" + subtitle; bottom actions (thumb reach): Continue with Google, Continue with Apple, "Skip for now" — all three `reset('/onboarding')`.
- [x] **8.4** Onboarding (`lib/screens/rhythms_screen.dart`): Year of Birth dropdown (current year … −100, `witchy_birth_year` persisted via `OnboardingProvider.yearOfBirth`/`setYear`/`finish()`); CTA renamed "Bind Magic Link" → "Begin the Journey", inert (Opacity 0.45) until a year is chosen; `AppEmblem` widget extracted (`lib/widgets/app_emblem.dart`), `moon_row.dart` + `splash_screen.dart` deleted.
- [x] **8.5** Tests: widget flow suite rewritten (welcome, gate accept/refuse/consent-skip, skip→onboarding→year→journey→Sanctuary, sign-out) + persistence (consent/birth-year round-trips) + auth tests (email removed) — suite 68/68; `main.dart` now injects `Provider<PrefsService>` so screens can read/write prefs directly.
- [x] **8.6** Docs: PLAN.md (this section), DESIGN.md → v1.4.0 (privacy screen + renumbered screens 01–20, join/rhythms/welcome rewrites, nav tree + route table), README.md (consent + anonymous skip + in-app privacy screen).

**Gate:** `flutter analyze` ✅, `flutter test` ✅ (68/68), `flutter build apk --debug` ✅, `flutter build web` ✅

---

## Phase 9 — Calendar Parity (Flo-style fidelity)

> New phase driven by user request: richer calendar cells, legend, month picker, late state, pain in the log sheet, clear-day. Agreed defaults: 1a (tiny cycle-day number under every in-month cell), 2 (keep current palette, no follicular/luteal phase tints), 3 (month label opens month/year picker; `/chart` stays reachable via Records → Trends), 4 (adjacent-month days dimmed & non-tappable).

- [x] **9.1** Cell fidelity: `CalendarDayCell` + `CalendarFetcher` — `isToday` flag (injectable `today:` param, normalized day comparison), per-cell `cycleDay` (0 for adjacent), adjacent-month cells carry real prev/next-month day numbers via normalized `DateTime` arithmetic.
- [x] **9.2** `CycleCalendar` render — today ring (pur outline on empty cells, white on filled), dimmed non-tappable adjacent cells (`placeholder` color), cycle-day micro-label under every in-month circle, per-cell `Semantics` label (full date + today/selected/period logged/predicted/ovulation/fertile/entries/cycle day; adjacent → "outside this month").
- [x] **9.3** `CalendarLegend` (`lib/widgets/calendar_legend.dart`) — centered wrap: period (solid) / predicted (outline) / fertile / ovulation / logged dots.
- [x] **9.4** `MonthPickerSheet` (`lib/widgets/month_picker_sheet.dart`) — `showMonthPicker(context, current)` modal bottom sheet: year chevron stepper (clamped 1900–2200) + 12-month grid; `CycleMapScreen` month label opens it (replaces the direct `/chart` jump).
- [x] **9.5** `CycleMapScreen` — `CycleProvider.daysLate` gold "N Days Late" pill + tappable "Today" chip when late or off-month; month shift keeps sensible selection (today if in view, else 1st); flow/mood detail rows tappable → `showLogSheet`; "Clear this day's log" link → confirm dialog → `deleteDay`.
- [x] **9.6** `CycleProvider.daysLate({today})` (floor 0, resets when a new bleed start logs) + `LogBottomSheet` gains the `AppSliderRow` pain slider (Uterine Contraction Pain 0–10) above Notes.
- [x] **9.7** Tests — fetcher (+isToday, cycleDay, adjacent day numbers), provider (+daysLate group), new `test/widgets/calendar_widgets_test.dart` (day tap, adjacent muted/non-tappable/semantics, legend labels, month-picker result + year stepping, calendar-tab screen wiring) — suite **78/78**.
- [x] **9.8** Docs — PLAN.md (this section), DESIGN.md → v1.5.0 (Screen 06 legend/picker/today/late/clear-day, Screen 07 pain slider + real `DayLog` defaults, §4.1 `/calendar` + `/chart` entry rows).

**Out of scope (flagged):** year view, week strip, pill/birth-control dots, wearables/BBT, pregnancy mode, locale week-start (Monday-first fixed), per-cell follicular/luteal phase tints.

**Gate:** `flutter analyze` ✅, `flutter test` ✅ (78/78), `flutter build apk --debug` ✅, `flutter build web` ✅

---

## Phase 10 — Profile Consolidation (settings + reminders folded in)

> User request: fold Settings and Reminders into the Profile screen; remove their buttons; add new `AppCard`s; Profile's gear action becomes the alerts button (same as MainScreen). Agreed: delete both screens + routes, dedicated "App Settings" card, one Amulet Bells card with 5 rows.

- [x] **10.1** `ProfileScreen` rework — top-bar action `AppIcons.gear → AppIcons.alerts` (`go('/alerts')`); dropped the `Notification Preferences → Manage` and `Appearance → Manage` links (Lunar Alignments = stats only, Apothecary keeps Gestation + Bond).
- [x] **10.2** New **App Settings** `AppCard` — `Receive Lunar Notifications` switch (`setLunar` + `NotificationService.syncPeriodPrediction` with `CycleProvider.nextPeriodStart()`) and `Dark Magic Mode` switch (`setDark`), ported from the old SettingsScreen.
- [x] **10.3** **Amulet Bells** card rebuilt — header + live count kept; `Open Amulet Reminders` button removed; 5 inline bell rows (hairline dividers: `IconBadge` + title/subtitle + pur `Switch` → `toggle` + `NotificationService.syncReminder`; ON rows show clock/freq `InfoPill`s).
- [x] **10.4** Deletions — `lib/screens/settings_screen.dart`, `lib/screens/reminders_screen.dart` removed; `app_router_delegate.dart` drops both imports and the `/settings` + `/reminders` cases (unknown paths recover via the welcome redirect).
- [x] **10.5** Tests — suite **80/80** unchanged (sign-out widget test still reaches Sign Out after the taller Profile; no screen tests referenced the deleted routes).
- [x] **10.6** Docs — DESIGN.md → v1.6.0 (nav/app-bar lines, §4.1 rows, nav tree, Screen 14 rewrite, Settings + Amulet Reminders sections deleted, screens 16–20 renumbered 15–18), PLAN.md (this section).

**Gate:** `flutter analyze` ✅, `flutter test` ✅ (80/80), `flutter build apk --debug` ✅, `flutter build web` ✅
