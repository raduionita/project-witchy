# WITCHY: Mobile Design System & UI/UX Specification
**Document Version:** 1.9.9
**Product Name:** Witchy — Comprehensive Menstrual, Fertility & Reproductive Health Tracker
**Target Platforms:** iOS, Android, web (Cross-Platform Mobile App)
**Primary Aesthetic:** Celestial witch / soft mystic — deep plum gradients on lavender-white, gold accents, Playfair Display + Inter
**Reference Mockup:** `resources/Qwen_html_20260917_r3vw6tc9n.html` (authoritative for colors, radii, type)

---

## 1. Executive Summary & Product Vision

**Witchy** is a comprehensive, beautifully designed women's health application that re-frames reproductive health tracking as an empowering, intuitive, and holistic daily practice. By bridging clinical-grade biometric logging (menstrual flow, basal body temperature, ovulation hormones, gestational milestones) with an elegant, calm aesthetic, Witchy allows users to understand the natural rhythms of their bodies without the sterile, patronizing feel of traditional medical apps.

### 1.1 Core UX Objectives

- Instant cycle orientation: day count, bleed countdown, fertility status in one glance (Today).
- Friction-free daily logging: single-tap flow, multi-tap moods/symptoms, pain slider.
- Trust via consistency: one card style, one button style, one bottom nav across all 20 routes.
- Privacy-first local auth: no backend; one-time consent gate (`witchy_privacy_accepted`), then `AuthProvider` (Google / Apple sign-in, plus skip/incognito) stores a device-only session — all rhythms persisted via `shared_preferences`.
- Titles are neutral and clinical (`Today`, `Articles`); only routes are branded.

---

## 2. Design System Architecture & Foundational Tokens

### 2.0 COLOR TOKEN VISUAL HARMONY

| Hex | Color name | Usage |
| :--- | :--- | :--- |
| `#FAF7FC` | bg | App scaffold background |
| `#FFFFFF` | card | Card surface |
| `#2A0A3C` | ink | Headings, body strong |
| `#4D3B5E` | body | Secondary body text |
| `#8B7F95` | muted | Hints, timestamps, subs |
| `#ECE3F2` | line | Card borders, dividers |
| `#7B2CBF` | pur | Primary: active chips, period days, toggles ON, chart bars, links |
| `#6A1B9A` | pur-d | Tag text on lavender |
| `#3B0A5E` / `#26063F` | plum / plum2 | Gradient buttons, dark cards, FAB (`135deg plum → plum2`) |
| `#D9A036` | gold | Stars, moon emblem, tags, progress, FAB icon, avatar ring |
| `#E0517F` | pink | Fertility peak, bleed badges, alert icons |
| `#F3EAF9` / `#E7D6F4` | lav / lav2 | Icon badges, tags, pills |

### 2.1 Color Palette & Design Tokens

Witchy uses a dark purple-led palette per mockup (see 2.0).

| Token Name | Hex Value | RGB / Opacity | Usage & Application | Contrast vs. Surface |
| :--- | :--- | :--- | :--- | :--- |
| `color-primary` | `#7B2CBF` | `rgb(123,44,191)` | Primary buttons (via plum gradient), period days, active pills, chart bars, toggles ON | 7.2:1 on white (AA) |
| `color-plum` | `#3B0A5E` | `rgb(59,10,94)` | Button/dark-card gradient start, tab ON, FAB | 12.9:1 (AAA) on white |
| `color-ink` | `#2A0A3C` | `rgb(42,10,60)` | Headings | 15.1:1 on `#FAF7FC` |
| `color-gold` | `#D9A036` | `rgb(217,160,54)` | Accents, tags on dark, progress fill | 2.4:1 decorative only |
| `color-pink` | `#E0517F` | `rgb(224,81,127)` | Fertility peak value, period tags, bleed icons | 4.1:1 on white |
| `color-danger` | `#8B1E2F` | `rgb(139,30,47)` | Delete All Data destructive button | 9.0:1 (AAA) on white |
| `color-line` | `#ECE3F2` | `rgb(236,227,242)` | Borders, dividers | — |
| `color-surface` | `#FAF7FC` | `rgb(250,247,252)` | Scaffold | — |

Code: `lib/theme/app_colors.dart` (`AppColors`).

**Dark variant (Milestone 1 Phase 12):** `AppColors.dark` flips mode-varying tokens via getters - bg `#1B0A2A`, card `#26063F`, ink `#F3EAF9`, body `#CDBEDD`, muted `#9E90AC`, line `#3E2A54`, pur `#9D5CFF`, field `#2A0F45`, plus dark `lav/lav2/switchOff/sliderTrack/sectionTitle/chipText/navInactive/placeholder/fertile*/pinkBg/goldBg/blueBg/tabBg` values. Accent tokens (`gold`, `pink`, `plum`, `orb*`, `avatar*`) stay shared. `buildAppTheme({Brightness brightness})` in `lib/theme/app_theme.dart` sets the flag and builds the matching `ThemeData`; `main.dart` picks dark ONLY when `SettingsProvider.darkMode` is on (light is the default; the Profile toggle is the sole control, platform brightness is ignored - Dark Mode toggle repaints live).

**App icon (Milestone 1 Phase 13):** gold cat-moon mark on brand purple `#3B0A5E`. Source art `assets/images/cat-moon-gold-512.png`; `tool/generate_app_icon.dart` composites `assets/images/app_icon_1024.png` (glyph at 80% inset) and `flutter_launcher_icons` (config in `pubspec.yaml`) generates Android legacy + adaptive (foreground gold, background `#3B0A5E`), the iOS AppIcon set, and web icons + favicon. Regenerate with `dart run tool/generate_app_icon.dart && dart run flutter_launcher_icons`.

### 2.2 Typography System

Playfair Display (display/serif) + Inter (sans). Code: `lib/theme/app_text_styles.dart` (`AppText`).

| Style Token | Font Family | Weight | Size (pt/dp) | Line Height | Letter Spacing | Usage Examples |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `type-display-l` | Playfair Display | 800 | 34 | 1.1 | 0 | Splash `Witchy` brand (`AppText.brand`) |
| `type-h2` | Playfair Display | 700 | 21 | 1.2 | 0 | `Join Witchy`, `Set Your Cycle` (`AppText.h2`) |
| `type-serif-18` | Playfair Display | 700 | 18 | 1.25 | 0 | Profile name, `Log Today's Energy` |
| `type-appbar` | Playfair Display | 700 | 16.5 | 1.2 | 0.2 | `AppTopBar` titles |
| `type-body` | Inter | 400/500 | 11–12.5 | 1.5–1.55 | 0 | Subs, alert/post/article bodies (`AppText.sub`) |
| `type-sec` | Inter | 600 | 11.5–12 | 1.4 | 0 | Section labels (`AppText.sec`, `secIn`) |
| `type-caps` | Inter | 700 | 9 | 1.4 | 0.14em | `SHEDDING PHASE`, `CYCLE DAY` eyebrow |
| `type-btn` | Inter | 600 | 13.5 | 1.3 | 0 | `AppButton` label (white) |

### 2.3 Spacing, Grid & Layout System

- Page: `16px` horizontal padding, `6px` top / `14px` bottom, `12px` card gap (`ListView padding: 16,6,16,14`).
- Card inner: `16px`; rows: `8–12px` gaps; chip grids: `8px` spacing; bottom nav `78px` tall.
- Max width: single 390dp column (phone frame `390×844`); web centers same column.
- Status bar `46px` mock only; Flutter uses `SafeArea`.

### 2.4 Corner Radii & Elevation

- Card `18`, button `14`, input/soc `12`, chip `10`, pills/switches/avatar `999` (circle).
- Card shadow `0 1px 2px rgba(43,10,61,.04)`; button/FAB shadow `0 8–10px 18–22px rgba(59,10,94,.55–.6)`.
- Dark card: `linear-gradient(135deg, #3B0A5E, #26063F)`, no border, white text, `lav`-tinted body (`#E9D9F5`).

---

## 3. Component Library & UI Patterns

### 3.1 Cycle & Fertility Status Badges

- **Period Day Badge:** pink `AppTag.pink` (`#FCE7EF` on `#C2336B`), e.g. `Period Day 2`.
- **Fertile Window Badge:** lavender `AppTag` (`#F3EAF9` on `#6A1B9A`), e.g. `On Time`, `Lime Size`.
- **Ovulation Peak Badge:** pink stat value (`Peak Today` in `AppColors.pink`).
- **Status Cards:** `StatCard` duo (label caps 8.5 / serif value 19 / sub 10); `CycleOrb` 172dp radial (`#4A1170→#2A0740`) in conic ring (46% pur).
- **Day Detail Banner:** light `AppCard` mirroring `mock-calendar.html` `.detail` — 56px phase moon glyph (`assets/svgs/moon-{period,period-predicted,fertile,ovulation,waxing,waning}.svg`) + serif date + phase line (`New Moon · Period` … `Waning Moon · Luteal phase`), optional `Period may start tomorrow` note (12/700 pinkDark), `AppTag.pink('Period Day N')`/`AppTag('Cycle Day N')` badge, tappable flow + mood status rows → log sheet.

### 3.2 Biometric Logging Controls

- **Flow Severity Selector:** single-select `Wrap` of `AppChip` (`None/Light/Medium/Heavy`, `data-single`); selected = pur fill white text.
- **Symptom Multi-Select Pills:** 2-col grid `AppChip` with icon tint; toggle ON/OFF (moods, somatic echoes).
- **Form Inputs:** `AppTextField` white, 12dp radius, line border, pur focus; lead icon + `pad`; eye toggle for secret key.
- **Cycle Slider:** `AppSliderRow` label + serif pur value (`28 Days`, `Level 6`), 4dp track, white thumb pur border.
- **Primary Button:** `AppButton` full-width plum gradient, 14dp radius, gold icon, white 13.5/600 label.
- **Secondary Button:** `.soc` white bordered 12dp radius (Apple/Google).
- **BBT Quick-Entry Keypad:** deferred — temperature is logged from the log sheet's `AppSliderRow` (35.0–38.0 °C, 0.1 steps); `/chart` plots the readings directly; no custom keypad.
- **LH / Ovulation Test Reader Widget:** deferred — `/fertility` v1 uses orb + duo stat cards; no camera reader.

### 3.3 Navigation Patterns

- Bottom nav: 4 tabs `Today/Calendar/Insights/Articles` (`AppBottomNav`), pur active + 18×2.5 underline; Articles icon `auto_awesome` → `CovenScreen` tab; labels frozen. Log is a bottom drawer (`showLogSheet`), not a tab.
- App bar: `AppTopBar` 50px, serif 16.5 centered; shell tabs: **leading `person_outline` → `/profile`**, **action bell `notifications_outlined` → `/alerts`**; all pushed screens default **leading back `arrow_back`** (pop, `/dashboard` fallback); `/profile` leading back → home, action alerts → `/alerts`.
- Pushes: Today Flow/Mood/Pain/Sleep QA → log bottom sheet (today, auto-scrolled to that category when off-screen); Peak card → `/fertility`; CycleMap day tap → log bottom sheet (that date); trends + CycleMap cards → `/chart`; feed article tap → `/webview?title&url` (same mechanism as legal pages); Profile gestation → `/pregnancy`; Profile top-bar alerts → `/alerts` (settings + reminders now inline in Profile).
- No legacy aliases: every route in `main.dart` is canonical and reachable (see §4.2).

---

## 4. Screen-by-Screen UI/UX Specifications

### 4.1 Screen Architecture

| User Journey Phase | Core Screen (title frozen) | Route | Connected / Sub-Screens | Dynamic Routing & Behavior |
| :--- | :--- | :--- | :--- | :--- |
| Entry | Welcome | `/` | → `/privacy`, `/onboarding`, `/dashboard` | CTA `Get Started` → `/privacy` first run, straight to `/onboarding` once consented (auth screen exists at `/auth` but stays hidden); returning onboarded users auto-redirect `/dashboard` |
| Entry | A Note on Privacy (gate) | `/privacy` | → `/webview`, `/`, `/onboarding` | 3 checkbox rows (Terms / Privacy Policy / Safe Space) → in-app webview; Refuse → `/`, Accept (all checked) → saves `witchy_privacy_accepted` + `/onboarding` |
| Entry | Join Witchy | `/auth` | → `/onboarding` | Bottom stack: Continue with Google / Continue with Apple / Skip for now — all `reset` to `/onboarding` (local session, errors → SnackBar) |
| Onboarding | Set Your Cycle | `/onboarding` | → `/dashboard` | Tracking mode chips (multi-toggle, default `{Cycle}`, all three can be active at once), Year of Birth dropdown (defaults to now − 25, so CTA active from first frame), last-bleed date picker, 28d/5d sliders; `Get Started` → persist + log first day → shell |
| Home | Today | `/dashboard` (shell 0) | → `/fertility`, log sheet | Orb day 14 Ovulation; Bleeding In 14d/Nov 10 (Perimenopause: earliest-latest window `dMin-dMax Days` + `d MMM - d MMM · range` sub, no single-day claim); Peak Today → fertility (fertility stat card hidden outside Cycle mode); `Today's Log` QA (Flow/Mood/Pain/Sleep, LogData icons) → log sheet today scrolled to category; day-detail card (glyph + phase + Cycle Day badge + flow/mood rows → log sheet; Perimenopause softens the note to `Period may start any day now` for d-1/d-2) |
| Home | Calendar | `/calendar` (shell 1) | → log sheet, month picker | Oct 2026 grid (today ring, dimmed adjacent days, cycle-day micro-labels, legend row); Perimenopause replaces arithmetic predictions with the `CalendarFetcher` predicted window (whole possible bleed range marked, fertile/ovulation glyphs hidden); day tap → log bottom sheet; month label → month/year picker sheet; late pill + Today chip when late/off-month; detail card with status tag, tappable rows, clear-day confirm (`/chart` now via Records → Trends) |
| Log | Log sheet | bottom drawer (no route) | — | `showLogSheet(date)`; 10 categories in `lib/common/log_data.dart` (all multi-toggle 2-col); per-date state in `LoggingProvider` (`DayLog` map); entries = calendar day tap, Today QA |
| Home | Insights | `/insights` (shell 2) | → `/chart` | `TrendBars` of observed cycle lengths (last 7, `C1..Cn` labels, empty state < 2 cycles), 28.4d/5.2d, `Irregularity` card (shortest-longest spread + `N Days variation` tag, empty state < 2 cycles), chronology Sept/Aug/July tags; trends card tap → chart |
| Home | Profile | `/profile` (pushed, not a tab) | → `/alerts`, `/pregnancy` | Avatar G, LOCAL · CYCLE TRACKING; `App Settings` card (lunar + dark switches), `Reminders` card (5 inline bell rows, live count, pills when ON); `Pregnancy Tracker → View` row only in Pregnancy mode |
| Community | Articles | `/coven` (shell 3, Articles tab) | → `/webview?title&url` | Remote article feed from `https://qvonyx.com/witchy/articles.xml` (`FeedService`, PrefsService cache, pull-to-refresh); article cards = `AppTag` category + pubDate + serif title + excerpt; tap → in-app webview; loading/empty states; no title/tabs/FAB of its own (shell tab title stays) |
| Pregnancy | Pregnancy Tracker | `/pregnancy` | — | Computed from its own persisted LMP (`GestationProvider`, not the cycle anchor): Week/Day, gold progress, countdown, bucketed size/tips content; empty state seeds the date; route gated to Pregnancy mode + onboarded |
| Alerts | Alerts | `/alerts` | — | `Recent Alerts` inbox from `AlertProvider` (generated + persisted, unread dot on the bells); Perimenopause swaps the peak alert for the hedged `may open as early as today` wording; entry = bell top-right on shell tabs and Profile |
| Insights | BBT & Ovulation Chart | `/chart` | — | fl_chart `LineChart` of the last 30 days of logged temperatures (gaps for unlogged days, dashed gold ovulation marker) + real pre-shift/post-shift `StatCard`s; empty state → log sheet prompt; entries = Records trends card |
| Fertility | Fertility Window | `/fertility` | — | Orb variant (Peak Day) + window duo + TTC tips; entry = Today Peak card (Cycle mode only - `CycleProvider.showFertilityPredictions` also gates calendar glyphs, BBT ovulation marker and fertile alerts) |
| App | App Splash Preview | `/splash` (direct only) | — | In-app preview of the native launch splash: full plum screen, gold cat-moon at 25% of the smaller axis; no in-app entry (link/button), no redirect |

### 4.2 App Structure

```
- / (welcome)
  - /privacy → /webview?title&url
  - /auth
  - /onboarding
- /dashboard (MainScreen shell: Today / Calendar / Insights / Articles tabs)
  - /calendar (Cycle Map tab)
  - /insights (Records tab)
  - /coven (Articles tab - article feed)
  - /chart
  - log bottom sheet (opened from FAB or day/QA taps)
- /profile → /alerts, /pregnancy
- /alerts
- /fertility
- /webview?title&url (legal pages + feed articles)
- /splash (direct only; no in-app link)
Back rule: pushed screens pop (fallback `/dashboard`); shell tabs switch in place; sheet dismisses down.
```

---

### Screen 01: Welcome (`/`)

- **Purpose:** Establish brand trust, holistic health authority, and privacy focus; route newcomers through the consent gate.
- **Layout Structure:**
  - **Hero Emblem:** `AppEmblem` circular emblem (`132x132pt`) — `#EFE2F8` outer disc, radial core (`#4A1170 → #2A0740`) with gold cat-moon (stencil `assets/images/cat-moon-mask-512.png` tinted `color: AppColors.gold` + `BlendMode.srcIn`, `cacheWidth: 256`, sized `0.36 * size`), centered in expanded upper half.
  - **Title Section:** Brand name `"Witchy"` (`type-display-l`, 34/800), tagline `"Track your cycle and health"` (12, muted).
  - **Bottom Action:** Single CTA `"Get Started"` (`AppButton`); reads `PrefsService.isPrivacyAccepted()` → unconsented goes `/privacy`, consented goes `/auth`. Foot padding `20/30`. No Sign In link (auth lives on Join).
  - **Returning Users:** If `OnboardingProvider.onboarded`, auto-redirect to `/dashboard` (post-frame).
  - **Native Launch Splash:** `flutter_native_splash` — plum `#3B0A5E` full-screen + gold `assets/images/cat-moon-gold-512.png`; logo = **25% of the smaller viewport axis**. Android is static dp: logo bitmaps hand-sized to `90dp × density` (25% on 360dp phones; Android 12 `windowSplashScreen*` cap 288dp); iOS `LaunchScreen.storyboard` logo box = `0.25 × min(width, height)` (priority-encoded min constraints, `scaleAspectFit`); web `<img>` uses `width: min(25vw, 25vh)`. ⚠ These hand-edits are **overwritten by `dart run flutter_native_splash:create`** — re-apply after any config change.

### Screen 02: A Note on Privacy (`/privacy`)

- **Purpose:** One-time consent gate before Join — local-first data promise + legal acknowledgements (acceptance persisted as `witchy_privacy_accepted`).
- **Layout Structure:**
  - **Header:** `h2` `"A Note on Privacy"` (centered) + centered sub: stories stay on-device, nothing uploaded/sold/shared, not a substitute for professional medical care. Header + card are vertically centered in the space above the actions (`Expanded > Center`, scrollable fallback).
  - **Consent Card:** `AppCard` with 3 centered `_ConsentRow`s — `Terms of Service`, `Privacy Policy`, `Safe Space guidelines` (age confirmation; webview title `Safe Space`, `LegalLinks.childProtection` URL unchanged) — each a checkbox (pur when checked) + title/link (center-aligned) opening the in-app webview (`LegalLinks` URLs → `/webview?title&url`).
  - **Actions:** Bottom row — `"Refuse"` (outlined) → `backOr('/')`; `"Accept"` (`AppButton`, wrapped in `Opacity 0.45` and inert until all three checked) → save consent + `reset('/auth')`. Refuse never persists consent, so the gate reappears next launch.

### Screen 03: Join Witchy (`/auth`)

- **Purpose:** Backend-free entry; no email/password form — Google / Apple sign-in or incognito skip (`AuthProvider`, device-only session in `shared_preferences`).
- **Layout Structure:**
  - **Center Block:** `AppEmblem` (`112pt`), `h2` `"Join Witchy"`, sub `"Your data stays on this device. Sign in to back it up, or continue without an account."` — vertically centered in the free space.
  - **Bottom Actions (thumb reach, full width, dark like `AppButton`):** `"Continue with Google"` (`_Soc`, plum gradient + primary shadow, white label/icon) → `signInWithGoogle()`; `"Continue with Apple"` (`_Soc`, same) → `signInWithApple()`; `"Skip for now"` (`_Ghost`, solid `plum2`, white label + moon) → incognito. All three `reset('/onboarding')`; failures surface a SnackBar, user cancellation is silent.

### Screen 04: Set Your Cycle (`/onboarding`)

- **Purpose:** Calibrate year of birth, last bleed date, cycle + bleed lengths; persist via `PrefsService` (`OnboardingProvider.finish`).
- **Layout Structure:**
  - **Header:** `h2` `"Set Your Cycle"` + sub `"Set up your cycle. When did your last period start?"`.
  - **Tracking Mode Card:** `AppCard` `"What shall we track?"` + `TrackingModeChips` multi-toggle `AppChip` row (`lib/widgets/tracking_mode_chip.dart`) - `Cycle` (droplet, default), `Pregnancy` (person-pregnant), `Perimenopause` (moon); selected = pur fill; any number of modes can be active at once and the last one can never be deselected (always >= 1); writes `OnboardingProvider.trackingModes` (a `Set`, persists `witchy_tracking_modes` JSON list with legacy `witchy_tracking_mode` migration) and is saved again in `finish()`.
  - **Year of Birth Card:** `AppCard` — label + serif value with `DropdownButton<int>` (current year … −100) → `setYear`, persisted as `witchy_birth_year`; preselected with the `OnboardingProvider` fallback default (`DateTime.now().year − 25`) so a value always exists.
  - **Date Card:** Tappable `AppCard` — `"Last bleeding phase"` + serif date (`Pick a date` placeholder) + calendar icon → native `showDatePicker` (past dates only).
  - **Slider Cards:** Two `AppCard`s hosting `AppSliderRow` — `"Cycle length"` (`20–40`, default `28 Days`), `"Bleeding phase length"` (`2–10`, default `5 Days`).
  - **Bottom Action:** Spacer-pinned `"Get Started"` (active from the first frame — default year is preselected; `Opacity 0.45` only if `yearOfBirth` were ever null) → `finish()` (saves rhythms + year + first-day `DayLog` `Medium`) → `reset('/dashboard')`.

### Screen 05: Today (`/dashboard`)

- **Purpose:** The core home screen; provides instant visibility into current cycle day, fertile status, hormone phase, and daily health insights.
- **Layout Structure:**
  - **Cycle Orb:** `CycleOrb` — `172pt` radial (`#4A1170 → #2A0740`) in conic ring (46% pur), `"CYCLE DAY"` gold caps + serif `14` + `"Ovulation"`.
  - **Stat Duo:** `Bleeding In / 14 Days / Nov 10 · predicted` + pink `Fertility Window / Peak Today / High chance` (tap → `/fertility`). Variable cycles show the `CycleProvider.predictedRange()` window (`dMin–dMax Days`, sub `d MMM – d MMM · range`; collapses to `N Days` when spread < 2); Perimenopause always forces the range + range wording and hides the fertility card. Pregnancy active (mode + LMP): card becomes `Pregnancy / open Pregnancy Tracker` (→ `/pregnancy`); pregnancy mode without LMP: `Set up tracker / add dates in Pregnancy Tracker`. Late but still projecting: `N Day(s) Late / log your period to re-anchor`; projection stopped: `Log to update / cycle running long - log to re-anchor`.
  - **Section Split:** each section below lives in its own private widget inside `sanctuary_screen.dart` (`_StatsRow`, `_TodaysMagicSection`, `_AstralInsightCard`, `_FertilityPeakCard`, `_InsightRow`).
  - **Quick Actions:** `"Today's Log"` label + 4 `QuickAction` tiles — icons from `LogCategory.icon` in `LogData` (Flow droplet / Mood heart / Pain fire / Sleep moon); a tile with entries logged today renders the `filled` state (solid `AppColors.pur` bg, white label, white icon badge); all → `showLogSheet(context, today, scrollTo: category)`, sheet scrolls only when the section isn't fully visible.
  - **Day Detail Card:** light `AppCard` per `mock-calendar.html` `.detail` — 56px moon glyph (phase + predicted-period variants), serif date, phase line, `Period may start tomorrow` note when `daysUntilPeriod == 1` (Perimenopause: `Period may start any day now` on d-1/d-2), `Period Day N`/`Cycle Day N` badge, tappable flow + mood rows → log sheet (no `/library` link).

### Screen 06: Calendar (`/calendar`)

- **Purpose:** Comprehensive monthly view showing predicted periods, ovulation windows, and historical logs.
- **Layout Structure:**
   - **Calendar Card:** `AppCard` with month header — chevron pair + `"October 2026"` label; label tap → `showMonthPicker` modal bottom sheet (year stepper chevrons clamped 1900–2200 + 12-month grid, returns first-of-month). Below: `CycleCalendar` 7-col grid of 54dp cells (Monday-first, 4dp row gap) — **moon-glyph marks** from `assets/svgs/` via `flutter_svg`: period days = lav2 half-disc + pur ring (solid logged / dashed predicted), fertile = `pinkBg` right half-disc + pink ring, ovulation = `pinkBg` disc + pink ring (period/predicted family = pur, fertile/ovulation family = pink for at-a-glance separation); fertile/ovulation dots follow the engine window (ovu-5..ovu+1 + uncertainty pad) and hide when confidence is lost or pregnancy is active; **today** = lav `#F3EAF9` background + 1.5px pur ring + bold ink number, **selected** = 2px ink ring; pink ovulation / blue logged dots at the cell foot; date 15/500 ink over cycle-day 11/500 muted micro-label; **dimmed non-tappable adjacent-month days** (`placeholder` color, number only), per-cell `Semantics` label (full date + today/selected/period/predicted/ovulation/fertile/logged/cycle day; adjacent → "outside this month"). Perimenopause passes `predictedStart`/`predictedEnd` (`CycleProvider.predictedRange()`) into `CalendarFetcher` so the predicted period is the whole possible bleed range (earliest start through latest start + bleed length) instead of single-cycle arithmetic. Then `CalendarLegend` — same SVG glyphs (period / predicted / fertile / ovulation) + blue logged dot. Status row when days-late > 0 or an adjacent month is shown: `AppTag.gold("N Days Late")` + tappable `AppTag("Today")` → jumps back to the current month. Day tap → selects day + opens log bottom sheet.
  - **Logged Section:** built by `_buildCalendarCard()` / `_buildLoggedCard()` split — header `AppText.sec` `"Period logged"` (mirrors Today's `Today's Log`) + the **10 newest flow-logged days** (newest first), each its own `AppCard(dark: true)` purple card: serif white date + `Period Day N` / `Period Logged` tag (`AppTag.pink`), white `IconBadge` (pur glyph) + white flow/mood rows; **tap card → `showLogSheet` for that date** and it becomes the selected entry — `"Clear this day's log"` link (pink 11pt w600) renders only on it → confirm dialog (`Clear this day?` / Cancel / Clear) → `LoggingProvider.deleteDay` + selection reset. Empty state: muted `"No period logged yet"`.

### Screen 07: Log Sheet (bottom drawer, no route)

- **Purpose:** Per-day symptom logging without leaving context; opened by tapping a calendar day or Today QA.
- **Layout Structure:**
  - **Sheet Chrome:** `showLogSheet(context, date)` (`log_bottom_sheet.dart`) — `showModalBottomSheet`, `DraggableScrollableSheet` (`0.5–0.95`, initial `0.85`), top-rounded `24dp`, drag handle (`40x4` line fill).
  - **Header:** Serif `{Month} {day}, {year}` (17pt) + sub `"Select physical and mental essences flowing within you."`.
  - **Log Categories:** rendered by private `_LogCycleSection` widget — every category is a multi-toggle 2-col `AppChip` grid (`childAspectRatio: 4.8`); section titles verbatim from `resources/log_bottom_sheet.txt` in order — `Period and bleeding` (Light 1 pink droplet / Medium 2 / Heavy 3 pinkDark / Spotting 1 pur droplet via `LogOption.iconCount`; no `None` — untoggling all chips = no flow), `Collection method`, `Pain and body symptoms`, `Digestion and stool`, `Skin and hair`, `Mood and emotions`, `Cravings and appetite`, `Vaginal discharge and cervical fluid` (6 entries incl. plain-toggle `None or dry`), `Sex and sex drive`, `Sleep`. Compact `AppChip`: padding 10×6, radius 8, label 11/500, icon gap 5 (fills its grid cell). Data lives in `lib/common/log_data.dart`: `LogOption(name, icon?, color = AppColors.pur, iconCount = 1)` per entry (icon omitted when absent; `AppChip` overlaps `iconCount` copies at 6px step) grouped as `LogCategory(title, options, icon?)` in `LogData` (`icon` feeds Today quick-action tiles). Bleeding/discharge toggles go through `toggleFlow`/`toggleDischarge`; `setFlow` (replace-style) remains for the onboarding seed. Each section carries its own color (`LogCategory.color`): the title is tinted with `AppColors.readableOn(category.color, AppColors.bg)` (auto-darkened to >= 4.5:1 so vivid accents like gold stay legible), selected chips fill with the section color (label/icon via `AppColors.onColor`, white vs ink by contrast), and iconless options inherit it. Palette in `LogData` order: bleeding `red`, collection `blue`, pain `orange`, digestion `green`, skin/hair `teal`, mood `gold`, cravings `brown`, discharge `pur`, sex `pink`, sleep `indigo` (`orange`, `teal`, `brown`, `indigo` added to `AppColors`).
  - **Uterine Contraction Pain:** private `_LogCycleSlider` wrapping `AppSliderRow` (0–10, live `Level N` label) → `setPain`, sits between Sleep and Notes.
  - **Basal Body Temperature:** private `_TemperatureRow` between the pain slider and Notes — `null` renders a `Not logged` label + `Add reading` `AppChip` (`AppIcons.thermometer`) that seeds 36.5 °C; once set, a serif pur live value (`36.4 °C`) + clear `IconButton` + `AppSliderRow`-styled slider (35.0–38.0 °C, `divisions: 30` = 0.1 steps, values snapped via `toStringAsFixed(1)`) → `LoggingProvider.setTemperature(date, value|null)` (`null` clears without deleting the entry).
  - **Ovulation Test:** private `_OvulationTestRow` after the temperature row — `null` renders `Not logged` + Positive/Negative `AppChip`s (tap selects, tap again clears) + clear `IconButton` when set; status text pink when Positive → `LoggingProvider.setOvulationTest(date, 'positive'|'negative'|null)` (`DayLog.ovulationTest`, additive JSON key, legacy payloads read `null`).
  - **State:** Per-date `DayLog` map in `LoggingProvider` (key `yyyy-MM-dd`, persisted via `PrefsService`); unlogged days read as `DayLog` defaults — flow/discharge empty sets (legacy payloads `flow: 'Light'` / `''` / `'None'` migrate on load), empty option sets (collection/symptoms/digestion/skinHair/moods/cravings/sex/sleep), pain 6, temperature `null`, empty notes — via non-materializing `peekDay` (views never call `day()`).

### Screen 08: Insights (`/insights`)

- **Purpose:** Longitudinal analysis of cycle regularity, period duration variation, and luteal phase stability.
- **Layout Structure:**
  - **Trends Card:** `"Stardust Cycle Trends"` + `TrendBars(values, labels)` (112pt, real observed cycle lengths from `CycleProvider.observedCycleLengths`, last 7 capped, pur-gradient bars, `C1..Cn` labels, padded y-range so 1-day differences stay visible); under 2 completed cycles → centered muted `"Log two completed cycles to grow your trends."` empty state; tap → `/chart`.
  - **Average Duo:** Centered `StatCard`s — `28 d / Average Cycle` (median of the last 6 observed lengths, `CycleProvider.medianRecentCycleLength`), `5.2 d / Average Bleed`.
  - **Irregularity Card:** `"Irregularity"` + `shortest–longest Days` serif value, `Shortest to longest cycle` sub and `N Days variation` `AppTag` (spread from `CycleProvider.cycleSpread`, i.e. longest minus shortest of the last 6 observed lengths; the shortest–longest display row stays all-time); under 2 completed cycles → muted `"Log two completed cycles to see your spread."` empty state. Most meaningful in Perimenopause mode but always visible.
  - **Chronology Card:** `"Period History"` + 3 `_Crow` rows (`Sept 14–19 / 5 Days / On Time`, `Aug 16–21 / On Time`, `July 19–23 / 4 Days / Short` pink tag).

### Screen 09: BBT & Ovulation Chart (`/chart`)

- **Purpose:** Advanced clinical-grade BBT graphing to visually confirm ovulation via biphasic temperature shifts.
- **Layout Structure:**
  - **App Bar:** `AppTopBar("BBT Chart")`, back pops (fallback `/dashboard`).
  - **Empty State:** no logged temperatures → `AppCard` with `"No temperatures yet"` + guidance copy + `AppButton("Log your temperature")` → `showLogSheet(today)`; plot and stats hidden.
  - **Shift Card:** `"Biphasic Temperature Shift"` + fl_chart `LineChart` (172pt) of the last 30 calendar days — x = day index from window start (bottom titles `d MMM` every ~quarter window), y = °C with 0.5 steps snapped to half-degrees, pur 2pt polyline with dots (dots at <= 16 points), **gaps** rendered by splitting consecutive-day runs into separate `LineChartBarData` segments; ovulation marker (when inside the window): BBT-confirmed date (`CycleProvider.confirmedOvulationDate`) wins over the predicted day (`CycleCalculator.ovulationDay`) = dashed gold `VerticalLine` + gold `"Confirmed ovulation"` label + legend row, else dashed muted line + `"Predicted ovulation"`.
  - **Average Duo:** `StatCard`s computed from readings — `Pre-shift average` (mean °C before the ovulation marker) and `Post-shift rise` (`post - pre`, `+0.0°`); `—` when either side has no readings.
  - **Explainer Card:** Dark card — serif `"How to read this"` + 11.5/1.55 lav body on three-morning sustained rise.
  - **Entries:** Records trends card (month picker replaced the old CycleMap month-card jump). Full keypad deferred.

### Screen 10: Fertility Window (`/fertility`)

- **Purpose:** Dedicated view for users Trying to Conceive (TTC), highlighting peak conception probability days.
- **Layout Structure:**
  - **App Bar:** `AppTopBar("Fertility Window")`, back pops.
  - **Peak Orb:** `CycleOrb` variant — serif `14` + `"Peak Day"` phase.
  - **Window Duo:** Pink `Conception chance / Peak Today / Ovulation likely` + `Window / 5 Days / Day 12 – Day 16`.
  - **Tips Card:** Dark card — serif `"TTC Tips"` + cervical-fluid/LH-surge guidance body.
  - **Paused State:** pregnancy active (mode + LMP): dark card `"Predictions paused"` + explainer + `AppButton("Open Pregnancy Tracker")` (→ `/pregnancy`) instead of the orb/duo/tips.
  - **Entry:** Today Peak card. LH/camera reader deferred.

### Screen 11: Pregnancy Tracker (`/pregnancy`)

- **Purpose:** Computed gestational tracker, reachable only when `TrackingMode.pregnancy` is in `trackingModes` (Profile row is hidden otherwise); replaces the hardcoded Week 12 mock. **Decoupled from cycle tracking:** the route is gated in `AppRouterDelegate` (not onboarded or pregnancy mode off -> welcome) and the LMP is never auto-seeded from `OnboardingProvider.lastPeriodStart` - the tracker owns its own persisted date.
- **Data:** `GestationProvider` (persisted `witchy_pregnancy_lmp` + optional `witchy_pregnancy_edd_override`) computes gestational days from the LMP date-only, `week = days ~/ 7`, `dayOfWeek = days % 7`, `progress = days/280` (clamped), `daysRemaining`, `daysPastDue`, `dueDate = override ?? lmp + 280` (`dueDateSource` = `doctor`/`LMP`), `dueDateParikh(cycleLength) = lmp + 280 + (cycleLength - 28)` shown as an alternative when cycle != 28 and no override is set, `trimester` (weeks 0-12 / 13-27 / 28+). With an override, gestational age re-anchors as `280 - (override - today)` (clamped >= 0). Week content from `GestationContent.forWeek` (10 buckets covering weeks 0-40 + past-term fallback) in `lib/common/gestation_content.dart`.
- **Layout Structure:**
  - **App Bar:** `AppTopBar("Pregnancy Tracker", action: favorite_border)`.
  - **Empty State (no LMP):** AppCard - serif `"Your gestation journey awaits"` + muted body + `AppButton("Set last period date")` → past-only `showDatePicker` (last 300 days, `lastDate: now`) seeds the provider.
  - **Progress Card (dark):** gold caps `"GESTATION SANCTUARY"`, serif `"Week N (Day D)"` (21pt) computed, gold progress bar (`6pt`, value = `progress`), countdown copy (`"$n days until arrival portal opens"` / `"The arrival portal opens today"` / `"$n days past the due date"`), due-date + `T{n} Trimester` line.
  - **Comparison Card:** `"Spiritual Comparison"` + `AppTag(content.size)`; search `IconBadge` + `content.development` body (bucket content, e.g. weeks 12-15 = `"Apple Size"`).
  - **Tips Card:** `"Pregnancy Tips"` + `content.tip` body.
  - **LMP Row Card:** `"Last bleeding phase"` + formatted date + calendar icon → reopens the picker.
  - **Due Date Card:** value = effective due date, sub `"Due date: LMP"` / `"Due date: doctor-set"`, Parikh alternative line when cycle != 28 and no override; `AppButton("Set due date"/"Change")` → picker (today … today+300) + `"Use LMP date"` clears the override.
- **Seeding:** none - the Pregnancy chip only enables the screen; the user sets the LMP on the screen itself (empty-state button or LMP row). Onboarding finish no longer calls `GestationProvider.setLmp`.

### Screen 12: Removed (`/library`)

- **Removed in Milestone 1 Phase 6.** Static library list replaced by the Articles feed (Screen 17); `/library` and `/library/<slug>` routes deleted.

### Screen 13: Article Detail (`/library/<slug>`)

- **Removed in Milestone 1 Phase 6.** Article bodies now live on the linked web pages, opened via `/webview?title&url`.

### Screen 14: Profile (`/profile`)

- **Purpose:** Identity + alignments hub; owns app settings and amulet bells inline (settings/reminders screens removed in Phase 4).
- **Layout Structure:**
  - **App Bar:** `"Profile"` — back top-left → home (fallback `/dashboard`), **alerts top-right** (`AppIcons.alerts`, same as shell) → `/alerts`.
  - **Identity Header:** `AppAvatar` G `84pt` (white ring + gold halo), serif `"Guest"` (18pt), gold caps `"LOCAL · CYCLE TRACKING"`, gold star.
  - **Cycle Averages Card:** Live values from `CycleProvider` - `Average Cycle Length` = `meanCycleLength` (`—` until 2 observed cycles) and `Bleeding Phase Length` = `bleedLength` + `Tracking Mode` row (pur underline label = active modes joined with `, `) → bottom sheet with the same 3 `TrackingModeChips`; tapping a chip toggles it via `OnboardingProvider.toggleTrackingMode` (multi-select, the sheet stays open, >= 1 mode always kept).
  - **Pregnancy Settings Card:** `Pregnancy Tracker → View` (→ `/pregnancy`) - card rendered only when `trackingModes` contains `TrackingMode.pregnancy`.
  - **App Settings Card (new):** `SettingsRow` switches — `Cycle Notifications` (ON, `setLunar` + awaited `NotificationService.syncPeriodPrediction`, failure surfaced as SnackBar) and `Dark Mode` (OFF, `setDark`, now drives the real dark theme), owned by `SettingsProvider`.
  - **Reminders Card:** `"Reminders"` header + live `"X of N reminders active"` (`N = RemindersProvider.items.length`) + inline bell rows (hairline dividers): `IconBadge` + serif title + muted subtitle + pur `Switch` (`toggle` + awaited `NotificationService.syncReminder` with cycle anchors, failure → SnackBar); when ON, `InfoPill` pair (clock time / spark freq) below the row. Bell `freq` now drives scheduling: `Every day`/`Daytime` repeat daily (hourly fans out 08:00-20:00), `Daily during peak` fires once per predicted bleed day, `Window start` once at fertile-window start, `3 days prior` once at predicted start minus 3; bells re-sync whenever cycle data or reminders change.
  - **Session Card:** `AppButton("Sign Out")` → clears session, `reset('/')` (welcome requires signed-in, so sign-out stays on the first screen); below it a `DangerButton("Delete All Data")` (`AppColors.danger` `#8B1E2F` bg, white label) - confirm dialog (`Delete all data?`) → wipes every `witchy_*` pref, resets all providers in memory, resyncs notifications, lands on welcome.
  - **Footer:** Centered `"Witchy / Version <package_info_plus>"` (9.5, placeholder; single-sourced from pubspec).

### Screen 16: Alerts (`/alerts`)

- **Purpose:** Generated inbox of real cycle milestones - replaces the former static mock list.
- **Data:** `AlertProvider` (persisted under `witchy_alerts`, cap 30) merges candidates from `AlertGenerator` on startup and whenever `CycleProvider` changes; candidates dedupe by stable id (`period-d2-<date>`, `late-dN-<date>`, `fertile-<date>`, `fertile-start-<date>`, `log-<date>`, `moon-new|full-<date>`), expired `eventDate`s are pruned, read state survives regeneration. Provider-level one-shots with stable ids + existence checks (the generator is pure): `opk-positive-<date>` (positive OPK logged, gated on fertility predictions + confidence) and `period-today-<date>` (flow logged today, gated off in pregnancy).
- **Generator rules:** period predicted in 2/1 days, late days 1-5 (`Period Late`, exclusive vs countdown), fertile window start (first fertile day, peri-aware copy) + ovulation day = fertile peak (peri-aware copy), missing daily log after 18:00, new/full moon via synodic phase. Fertility block requires `predictionsConfident`; period block requires a non-null projection and no active pregnancy; moon milestones fire in every mode.
- **Layout Structure:**
  - **App Bar:** `AppTopBar("Alerts")`, back pops.
  - **Inbox Header:** Serif `"Recent Alerts"` + sub `"Reminders for the days ahead, based on your cycle."`.
  - **Alert Cards:** One `AppCard` per alert - tinted `IconBadge` (tints derive from `AlertType`) + serif title + relative `intl` timestamp (`just now` / `N min ago` / `N h ago` / `yesterday` / `d MMM`); unread shows a pink dot + full-ink title/body, read dims to muted; tap marks read.
  - **Empty State:** "`"No alerts yet"` card - "Nothing new right now. Alerts appear as your cycle nears a milestone."`
  - **Entry:** Bell top-right on the shell tabs and the Profile top bar shows a pink unread dot while `unreadCount > 0`.

### Screen 17: Articles (`/coven`)

- **Purpose:** Remote wisdom feed - RSS-style article list served from `https://qvonyx.com/witchy/articles.xml`; each entry opens in the in-app webview.
- **Layout Structure:**
  - **No own title/tabs/FAB.** Rendered as the shell's 4th tab (shell app bar keeps the `Articles` title).
  - **Data:** `FeedService` fetches + parses `<item>` entries (title, link, description with HTML stripped, pubDate, category - default `GUIDE`); payload cached in `PrefsService` (`witchy_feed_cache`) for offline; pull-to-refresh refetches; network failure falls back to cache, empty cache shows the `"No articles yet"` empty state.
  - **Article Cards:** `AppCard` per item - `AppTag(category)` + muted `d MMM yyyy` pubDate row, serif 14 title, muted 10.5 excerpt (3-line ellipsis); tap → `context.go('/webview?title=<enc>&url=<enc>')`.

### Screen 18: Removed (`/binding`)

- **Removed in Milestone 1 Phase 6.** Couple/partner sync needs a backend (forbidden by project rules); the invite UI and the 3 local share flags were no-ops and were deleted with their prefs keys.

### Screen 19: App Splash Preview (`/splash`)

- **Purpose:** In-app preview of the native launch splash (identical look), held until later integration; not reachable from any link/button — typed/direct route only, no redirect logic.
- **Layout Structure:**
  - **Canvas:** Full-bleed `Scaffold`, `AppColors.plum` (`#3B0A5E`), no SafeArea, no app bar.
  - **Emblem:** `LayoutBuilder` → `side = min(width, height) * 0.25`; centered stencil `assets/images/cat-moon-mask-512.png` tinted `AppColors.gold` (`BlendMode.srcIn`) at `side × side`, `BoxFit.contain` (same 25%-of-smaller-axis rule as the native splash); gold-512 PNG is kept only for `flutter_native_splash`, which cannot tint at runtime.
  - **Entry:** Direct route only (`/splash`); back uses default stack behavior.

### Prediction Engine (Fixes 4)

- **Purpose:** Local-only prediction math behind every date the UI shows. No cloud, no ML - honest rolling statistics + logged-signal integration. Code: `lib/services/cycle_calculator.dart` (pure date math), `lib/services/cycle_stats.dart` (rolling medians), `lib/services/bbt_analyzer.dart` (biphasic shift), `lib/providers/cycle_provider.dart` (reactive surface).
- **Fertile window:** ovulation day minus 5 through plus 1 (sperm 5 d, egg 1 d) + uncertainty pad on each side: `pad = 2` with < 3 observed cycles, `0` when recent spread <= 7, else `min(spread ~/ 2, 4)`; total width capped at 14 days, ovulation always inside. Ovulation = predicted next start minus luteal length (personal when detected, else 14).
- **Rolling statistics (`CycleStats`):** averages over the last 6 observed cycles, predictions over the last 12 (median estimator, lengths clamped 20-40); spread/shortest/longest over the last 6; ancient outliers age out of predictions but stay on the Records all-time display. Seeded by onboarding history (rhythms seeds previous periods as full spans) + logged bleeds. Bleed length stays slider-only.
- **Personal luteal:** BBT-confirmed ovulation (10+ readings, 3-day sustained mean rise >= 0.3 C over a 6-day baseline) beats OPK-indicated (latest positive + 1 day, luteal from implied gaps), which beats arithmetic 14. Clamped 10-18.
- **Late / confidence:** late 1-5 d → `Period Late` alert; late > longest + 5 → `predictionsConfident = false` (fertility UI + alerts hidden, "running long" copy); late > longest + 10 → projection stops (`nextPeriodStart`/`predictedRange` null → `Log to update`) until a new bleed is logged.
- **Range display:** single day only when recent spread < 2, else earliest-latest range; Perimenopause always forces range + range wording.
- **Pregnancy:** active = pregnancy mode in set + LMP date set (mode alone keeps cycle UI + shows a setup nudge). Active suppresses fertility predictions, period countdown, and late/period alerts; moon milestones still fire. Dating: Naegele LMP+280 default, Parikh `+ (cycle - 28)` alternative, manual doctor-set EDD override with provenance label.
- **Honesty copy:** `DisclaimerText` footer ("Predictions are estimates - not a contraceptive and not medical advice.") under prediction surfaces on Today, Fertility, Pregnancy, and Chart.
