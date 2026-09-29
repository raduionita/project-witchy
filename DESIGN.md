# WITCHY: Mobile Design System & UI/UX Specification
**Document Version:** 1.4.0
**Product Name:** Witchy — Comprehensive Menstrual, Fertility & Reproductive Health Tracker
**Target Platforms:** iOS, Android, web (Cross-Platform Mobile App)
**Primary Aesthetic:** Celestial witch / soft mystic — deep plum gradients on lavender-white, gold accents, Playfair Display + Inter
**Reference Mockup:** `resources/Qwen_html_20260917_r3vw6tc9n.html` (authoritative for colors, radii, type)

---

## 1. Executive Summary & Product Vision

**Witchy** is a comprehensive, beautifully designed women's health application that re-frames reproductive health tracking as an empowering, intuitive, and holistic daily practice. By bridging clinical-grade biometric logging (menstrual flow, basal body temperature, ovulation hormones, gestational milestones) with an elegant, celestial-inspired aesthetic, Witchy allows users to understand the natural rhythms of their bodies without the sterile, patronizing feel of traditional medical apps.

### 1.1 Core UX Objectives

- Instant cycle orientation: day count, bleed countdown, fertility status in one glance (Sanctuary).
- Friction-free daily logging: single-tap flow, multi-tap moods/symptoms, pain slider.
- Trust via consistency: one card style, one button style, one bottom nav across all 20 routes.
- Privacy-first local auth: no backend; one-time consent gate (`witchy_privacy_accepted`), then `AuthProvider` (Google / Apple sign-in, plus skip/incognito) stores a device-only session — all rhythms persisted via `shared_preferences`.
- Titles are mystical and frozen (`Sanctuary`, `Sovereign Blood`, `Coven Sanctum`); only routes are clinical.

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
| `color-line` | `#ECE3F2` | `rgb(236,227,242)` | Borders, dividers | — |
| `color-surface` | `#FAF7FC` | `rgb(250,247,252)` | Scaffold | — |

Code: `lib/theme/app_colors.dart` (`AppColors`).

### 2.2 Typography System

Playfair Display (display/serif) + Inter (sans). Code: `lib/theme/app_text_styles.dart` (`AppText`).

| Style Token | Font Family | Weight | Size (pt/dp) | Line Height | Letter Spacing | Usage Examples |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `type-display-l` | Playfair Display | 800 | 34 | 1.1 | 0 | Splash `Witchy` brand (`AppText.brand`) |
| `type-h2` | Playfair Display | 700 | 21 | 1.2 | 0 | `Join the Coven`, `Set Your Rhythms` (`AppText.h2`) |
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
- **Info Banner:** dark `AppCard(dark:true)` with gold spark + tag + 11.5/1.55 body (`Daily Astral Insight`).

### 3.2 Biometric Logging Controls

- **Flow Severity Selector:** single-select `Wrap` of `AppChip` (`None/Light/Medium/Heavy`, `data-single`); selected = pur fill white text.
- **Symptom Multi-Select Pills:** 2-col grid `AppChip` with icon tint; toggle ON/OFF (moods, somatic echoes).
- **Form Inputs:** `AppTextField` white, 12dp radius, line border, pur focus; lead icon + `pad`; eye toggle for secret key.
- **Cycle Slider:** `AppSliderRow` label + serif pur value (`28 Days`, `Level 6`), 4dp track, white thumb pur border.
- **Primary Button:** `AppButton` full-width plum gradient, 14dp radius, gold icon, white 13.5/600 label.
- **Secondary Button:** `.soc` white bordered 12dp radius (Apple/Google).
- **BBT Quick-Entry Keypad:** deferred — `/chart` v1 uses slider + trend bars reusing `AppSliderRow`/`TrendBars`; no custom keypad.
- **LH / Ovulation Test Reader Widget:** deferred — `/fertility` v1 uses orb + duo stat cards; no camera reader.

### 3.3 Navigation Patterns

- Bottom nav: 4 tabs `Today/Calendar/Insights/Magic` (`AppBottomNav`), pur active + 18×2.5 underline; Magic icon `auto_awesome` → `CovenScreen` tab; labels frozen. Log is a bottom drawer (`showLogSheet`), not a tab.
- App bar: `AppTopBar` 50px, serif 16.5 centered; shell tabs: **leading `person_outline` → `/profile`**, **action bell `notifications_outlined` → `/alerts`**; all pushed screens default **leading back `arrow_back`** (pop, `/dashboard` fallback); `/profile` leading back → home, action gear → `/settings`; `/settings` leading back → `/profile`.
- Pushes: Sanctuary Flow QA → `/cycle`, Mood/Pain/Notes QA → log bottom sheet (today); Peak card → `/fertility`; insight card → `/library`; CycleMap day tap → log bottom sheet (that date); trends + CycleMap cards → `/chart`; Library card → `/library/<slug>` (via `onGenerateRoute`, unknown slug → `/library`); Profile bond → `/binding`, gear/Manage → `/settings`, bells card button → `/reminders`, gestation → `/pregnancy`.
- No legacy aliases: every route in `main.dart` is canonical and reachable (see §4.2).

---

## 4. Screen-by-Screen UI/UX Specifications

### 4.1 Screen Architecture

| User Journey Phase | Core Screen (title frozen) | Route | Connected / Sub-Screens | Dynamic Routing & Behavior |
| :--- | :--- | :--- | :--- | :--- |
| Entry | Welcome | `/` | → `/privacy`, `/auth`, `/dashboard` | CTA `Awaken Your Power` → `/privacy` first run, straight to `/auth` once consented; returning onboarded users auto-redirect `/dashboard` |
| Entry | Your Privacy Promise (gate) | `/privacy` | → `/webview`, `/`, `/auth` | 3 checkbox rows (Terms / Privacy Policy / Child Protection) → in-app webview; Refuse → `/`, Accept (all checked) → saves `witchy_privacy_accepted` + `/auth` |
| Entry | Join the Coven | `/auth` | → `/onboarding` | Bottom stack: Continue with Google / Continue with Apple / Skip for now — all `reset` to `/onboarding` (local session, errors → SnackBar) |
| Onboarding | Set Your Rhythms | `/onboarding` | → `/dashboard` | Year of Birth dropdown (required), last-bleed date picker, 28d/5d sliders; `Begin the Journey` inert until year chosen → persist + log first day → shell |
| Home | Sanctuary | `/dashboard` (shell 0) | → `/cycle`, `/fertility`, `/library`, log sheet | Orb day 14 Full Moon Peak; Bleeding In 14d/Nov 10; Peak Today → fertility; insight card → library; Mood/Pain/Notes QA → log sheet (today) |
| Home | Lunar Cycle Map | `/calendar` (shell 1) | → `/chart`, log sheet | Oct 2026 grid (10–13 fertile lav, 14–18 period pur); day tap → log bottom sheet; detail card Oct 15 Period Day 2; month card tap → chart |
| Log | Apothecary Log sheet | bottom drawer (no route) | — | `showLogSheet(date)`; flow single + moods/symptoms multi; per-date state in `LoggingProvider` (`DayLog` map); entries = calendar day tap, Sanctuary QA |
| Home | Lunar Records | `/insights` (shell 2) | → `/chart` | Bars M1–M7 (58–94%), 28.4d/5.2d, chronology Sept/Aug/July tags; trends card tap → chart |
| Home | Witch Profile | `/profile` (pushed, not a tab) | → `/settings`, `/reminders`, `/pregnancy`, `/binding` | Avatar HS, Scorpio Moon; toggles owned by Settings (Manage links); `Amulet Bells` 3rd card (live active count + button → reminders); gestation → pregnancy |
| Community | Coven Sanctum | `/coven` (shell 3, Magic tab) | — | Tabs Recent/Ancients; 3 posts (MC/CS/LG); FAB plum/gold plus |
| Cycle | Sovereign Blood | `/cycle` | — | Dark `Day 3 of 5` + 3 drops; volume single; pain slider L6; scribbles note |
| Pregnancy | Gestation Spells | `/pregnancy` | — | Dark Week 12 (Day 4), gold 30% bar, 196 days; Lime Size; tips |
| Alerts | Celestial Alerts | `/alerts` | — | `Whispers Received` inbox (sub + 4 alert cards with `IconBadge` tints); entry = bell top-right on all shell tabs |
| Profile | Amulet Reminders | `/reminders` | — | 5 configurable bells (`RemindersProvider`); header live `X of 5 bells active`; OFF collapses time/freq pills; entry = Profile `Amulet Bells` card button |
| Library | Apothecary Library | `/library` | → `/library/<slug>` | Search + 4 articles (Luteal, Herbs, Meditation, Fertility); tap → detail via `onGenerateRoute` |
| Library | Article Detail | `/library/<slug>` (dynamic) | — | Slug lookup (`articleById`, unknown → library); thumb gradient hero, cat/readTime, title, excerpt + body; back to library |
| Insights | BBT & Ovulation Chart | `/chart` | — | Reuses `TrendBars` + avg duo + note card; entries = Records trends card, CycleMap month card |
| Fertility | Fertility Window | `/fertility` | — | Orb variant (Peak Day) + window duo + TTC tips; entry = Sanctuary Peak card |
| Profile | Settings | `/settings` | — | App settings owned here: lunar switch, dark mode; gear/Manage top-right of Profile; reuses `SettingsRow` |
| Community | Coven Binding | `/binding` | — | HS✦KP header, invite input + send, 3 visibility switches |

### 4.2 App Structure

```
- / (welcome)
  - /privacy → /webview?title&url
  - /auth
  - /onboarding
- /dashboard (MainScreen shell: Sanctuary / Cycle Map / Records / Coven tabs)
  - /calendar (Cycle Map tab)
  - /insights (Records tab)
  - /coven (Coven tab)
  - /chart
  - log bottom sheet (opened from FAB or day/QA taps)
- /profile → /settings, /reminders, /pregnancy, /binding
- /alerts
- /cycle
- /fertility
- /library → /library/<slug>
Back rule: pushed screens pop (fallback `/dashboard`); shell tabs switch in place; sheet dismisses down.
```

---

### Screen 01: Welcome (`/`)

- **Purpose:** Establish brand trust, holistic health authority, and privacy focus; route newcomers through the consent gate.
- **Layout Structure:**
  - **Hero Emblem:** `AppEmblem` circular emblem (`132x132pt`) — `#EFE2F8` outer disc, radial core (`#4A1170 → #2A0740`) with gold moon glyph, centered in expanded upper half.
  - **Title Section:** Brand name `"Witchy"` (`type-display-l`, 34/800), tagline `"Track your cycle with magic"` (12, muted).
  - **Bottom Action:** Single CTA `"Awaken Your Power"` (`AppButton`); reads `PrefsService.isPrivacyAccepted()` → unconsented goes `/privacy`, consented goes `/auth`. Foot padding `20/30`. No Sign In link (auth lives on Join).
  - **Returning Users:** If `OnboardingProvider.onboarded`, auto-redirect to `/dashboard` (post-frame).

### Screen 02: Your Privacy Promise (`/privacy`)

- **Purpose:** One-time consent gate before Join — local-first data promise + legal acknowledgements (acceptance persisted as `witchy_privacy_accepted`).
- **Layout Structure:**
  - **Header:** `h2` `"Your Privacy Promise"` (centered) + centered sub: stories stay on-device, nothing uploaded/sold/shared, not a substitute for professional medical care. Header + card are vertically centered in the space above the actions (`Expanded > Center`, scrollable fallback).
  - **Consent Card:** `AppCard` with 3 centered `_ConsentRow`s — `Terms of Service`, `Privacy Policy`, `Child Protection` — each a checkbox (pur when checked) + title/link (center-aligned) opening the in-app webview (`LegalLinks` URLs → `/webview?title&url`).
  - **Actions:** Bottom row — `"Refuse"` (outlined) → `backOr('/')`; `"Accept"` (`AppButton`, wrapped in `Opacity 0.45` and inert until all three checked) → save consent + `reset('/auth')`. Refuse never persists consent, so the gate reappears next launch.

### Screen 03: Join the Coven (`/auth`)

- **Purpose:** Backend-free entry; no email/password form — Google / Apple sign-in or incognito skip (`AuthProvider`, device-only session in `shared_preferences`).
- **Layout Structure:**
  - **Center Block:** `AppEmblem` (`112pt`), `h2` `"Join Witchy"`, sub `"Your rhythms stay on this device. Sign up to keep your magic in sync, or slip in incognito and begin straight away."` — vertically centered in the free space.
  - **Bottom Actions (thumb reach, full width, dark like `AppButton`):** `"Continue with Google"` (`_Soc`, plum gradient + primary shadow, white label/icon) → `signInWithGoogle()`; `"Continue with Apple"` (`_Soc`, same) → `signInWithApple()`; `"Skip for now"` (`_Ghost`, solid `plum2`, white label + moon) → incognito. All three `reset('/onboarding')`; failures surface a SnackBar, user cancellation is silent.

### Screen 04: Set Your Rhythms (`/onboarding`)

- **Purpose:** Calibrate year of birth, last bleed date, cycle + bleed lengths; persist via `PrefsService` (`OnboardingProvider.finish`).
- **Layout Structure:**
  - **Header:** `h2` `"Set Your Rhythms"` + sub `"Calibrate your lunar engine. When did your last bleeding phase commence?"`.
  - **Year of Birth Card:** `AppCard` — label + serif value (`Select year` placeholder) with `DropdownButton<int>` (current year … −100) → `setYear`, persisted as `witchy_birth_year`.
  - **Date Card:** Tappable `AppCard` — `"Last bleeding phase"` + serif date (`Pick a date` placeholder) + calendar icon → native `showDatePicker` (past dates only).
  - **Slider Cards:** Two `AppCard`s hosting `AppSliderRow` — `"Cycle duration (stardust tides)"` (`20–40`, default `28 Days`), `"Bleeding phase length"` (`2–10`, default `5 Days`).
  - **Bottom Action:** Spacer-pinned `"Begin the Journey"` (`Opacity 0.45` + inert until a year is chosen) → `finish()` (saves rhythms + year + first-day `DayLog` `Medium`) → `reset('/dashboard')`.

### Screen 05: Sanctuary (`/dashboard`)

- **Purpose:** The core home screen; provides instant visibility into current cycle day, fertile status, hormone phase, and daily health insights.
- **Layout Structure:**
  - **Cycle Orb:** `CycleOrb` — `172pt` radial (`#4A1170 → #2A0740`) in conic ring (46% pur), `"CYCLE DAY"` gold caps + serif `14` + `"Full Moon Peak"`.
  - **Stat Duo:** `Bleeding In / 14 Days / Nov 10 · predicted` + pink `Fertility Window / Peak Today / High chance` (tap → `/fertility`).
  - **Quick Actions:** `"Log Today's Magic"` label + 4 `QuickAction` tiles — Flow → `/cycle`, Mood/Pain/Notes → log bottom sheet for today.
  - **Insight Card:** Dark card — gold spark + `"Daily Astral Insight"` + `AppTag.gold("Scorpio Moon")` + 11.5/1.55 body (tap → `/library`).

### Screen 06: Lunar Cycle Map (`/calendar`)

- **Purpose:** Comprehensive monthly view showing predicted periods, ovulation windows, and historical logs.
- **Layout Structure:**
  - **Calendar Card:** `AppCard` with `"October 2026"` serif header (chevron pair) + `CycleCalendar` 7-col grid (fertile `10–13` lav `#EBDCF7`, period `14–18` pur fill white text); day tap → log bottom sheet for that date; month header tap → `/chart`.
  - **Detail Card:** `"October 15, 2026"` + `AppTag.pink("Period Day 2")`; rows — pink drop `"Medium bleed flow intensity"`, pur heart `"Intuitive, reflective mood"`.

### Screen 07: Apothecary Log (bottom drawer, no route)

- **Purpose:** Per-day symptom logging without leaving context; opened by tapping a calendar day or Sanctuary QA.
- **Layout Structure:**
  - **Sheet Chrome:** `showLogSheet(context, date)` (`log_bottom_sheet.dart`) — `showModalBottomSheet`, `DraggableScrollableSheet` (`0.5–0.95`, initial `0.85`), top-rounded `24dp`, drag handle (`40x4` line fill).
  - **Header:** Serif `{Month} {day}, {year}` (17pt) + sub `"Select physical and mental essences flowing within you."`.
  - **Bleed Intensity:** Single-select `Wrap` of `AppChip` (`None/Light/Medium/Heavy`, pur fill when ON).
  - **Emotional Currents:** 2-col grid — Enchanted / Grounded / Shadowy / Restless (icon-tinted, multi-toggle).
  - **Somatic Echoes:** 2-col grid — Uterine Cramps / Headache / Bloating / Fatigue (multi-toggle).
  - **State:** Per-date `DayLog` map in `LoggingProvider` (key `yyyy-MM-dd`, persisted via `PrefsService`); new days seed `Medium` + Uterine Cramps + pain 6 + default scribble.

### Screen 08: Lunar Records (`/insights`)

- **Purpose:** Longitudinal analysis of cycle regularity, period duration variation, and luteal phase stability.
- **Layout Structure:**
  - **Trends Card:** `"Stardust Cycle Trends"` + `TrendBars` (`112pt`, 7 bars `58–94%` pur gradient, `M1–M7`); tap → `/chart`.
  - **Average Duo:** Centered `StatCard`s — `28.4 d / Average Cycle`, `5.2 d / Average Bleed`.
  - **Chronology Card:** `"Chronology of Bleeds"` + 3 `_Crow` rows (`Sept 14–19 / 5 Days / On Time`, `Aug 16–21 / On Time`, `July 19–23 / 4 Days / Short` pink tag).

### Screen 09: BBT & Ovulation Chart (`/chart`)

- **Purpose:** Advanced clinical-grade BBT graphing to visually confirm ovulation via biphasic temperature shifts.
- **Layout Structure:**
  - **App Bar:** `AppTopBar("BBT Chart")`, back pops (fallback `/dashboard`).
  - **Shift Card:** `"Biphasic Temperature Shift"` + reused `TrendBars`.
  - **Average Duo:** `36.4° / Pre-shift average` + `+0.4° / Post-shift rise`.
  - **Explainer Card:** Dark card — serif `"How to read this"` + 11.5/1.55 lav body on three-morning sustained rise.
  - **Entries:** Records trends card, CycleMap month card. Full keypad/chart deferred.

### Screen 10: Fertility Window (`/fertility`)

- **Purpose:** Dedicated view for users Trying to Conceive (TTC), highlighting peak conception probability days.
- **Layout Structure:**
  - **App Bar:** `AppTopBar("Fertility Window")`, back pops.
  - **Peak Orb:** `CycleOrb` variant — serif `14` + `"Peak Day"` phase.
  - **Window Duo:** Pink `Conception chance / Peak Today / Ovulation likely` + `Window / 5 Days / Day 12 – Day 16`.
  - **Tips Card:** Dark card — serif `"TTC Tips"` + cervical-fluid/LH-surge guidance body.
  - **Entry:** Sanctuary Peak Today card. LH/camera reader deferred.

### Screen 11: Gestation Spells (`/pregnancy`)

- **Purpose:** Replaces the standard cycle dashboard when Pregnancy Mode is enabled; tracks fetal development and maternal health.
- **Layout Structure:**
  - **App Bar:** `AppTopBar("Gestation Spells", action: favorite_border)`.
  - **Progress Card:** Dark card — gold caps `"GESTATION SANCTUARY"`, serif `"Week 12 (Day 4)"` (21pt), gold `30%` progress bar (`6pt`, white 22% track), `"196 days until arrival portal opens"` (10.5, orb-sub).
  - **Comparison Card:** `"Spiritual Comparison"` + `AppTag("Lime Size")`; search `IconBadge` + `"Your little spirit matches a ripe Lime..."` body.
  - **Tips Card:** `"Astral Gestation Tips"` + first-trimester iron/mantra body (11.5/1.55).

### Screen 12: Apothecary Library (`/library`)

- **Purpose:** Provide medically sound, holistic self-care, nutritional, and herbal guidance tailored to the current menstrual cycle phase.
- **Layout Structure:**
  - **App Bar:** `AppTopBar("Apothecary Library")`, back pops.
  - **Search:** `AppTextField` (`"Search spells, herbs, anatomy..."`, search lead).
  - **Article Cards:** 4 `AppCard` rows — `62x62pt` gradient thumb + gold `CAT` caps + `readTime` + serif title (ellipsis) + excerpt (ellipsis): Luteal Phase (ANATOMY, 5 min), Cramp Herbs (BOTANICAL, 8 min), Moon Meditation (MINDFULNESS, 12 min), Fertility Window (LUNAR CYCLE, 6 min); tap → `/library/<slug>`.

### Screen 13: Article Detail (`/library/<slug>`)

- **Purpose:** Long-form reading interface for evidence-based reproductive health articles and clinical guides.
- **Layout Structure:**
  - **App Bar:** `AppTopBar("Wellness Detail")`, back → `/library`.
  - **Hero Card:** `140pt` gradient hero (`12dp` radius) + category `AppTag` / readTime row + serif title (18pt) + excerpt sub.
  - **Body Card:** Single practice paragraph (tea/rest/breath + log prompt, 11.5/1.55). Slug lookup via `articleById`; unknown slug falls back to `/library`.

### Screen 14: Witch Profile (`/profile`)

- **Purpose:** Identity + alignments hub; gateway to settings/reminders/pregnancy/binding.
- **Layout Structure:**
  - **App Bar:** `"Witch Profile"` — back top-left → home (fallback `/dashboard`), gear top-right → `/settings`.
  - **Identity Header:** `AppAvatar` HS `84pt` (white ring + gold halo), serif `"High Priestess Selene"` (18pt), gold caps `"SCORPIO MOON · THIRD CYCLE"`, gold star.
  - **Lunar Alignments Card:** Statics `29 Days / 5 Days` + `Notification Preferences → Manage` (→ `/settings`).
  - **Apothecary Settings Card:** `Appearance → Manage` (→ `/settings`), `Gestation Spells → View` (→ `/pregnancy`), `Cosmic Partner Bond → 1 Active` (→ `/binding`).
  - **Amulet Bells Card:** `"Amulet Bells"` header + live `"X of 5 bells active"` (watches `RemindersProvider`) + full-width `AppButton("Open Amulet Reminders")` → `/reminders`.
  - **Footer:** Centered `"Witchy App / Version 1.2.4 · Made with celestial energy"` (9.5, placeholder). Settings owns all toggles — Profile only links out.

### Screen 15: Settings (`/settings`)

- **Purpose:** App-level preferences (notifications, appearance).
- **Layout Structure:**
  - **App Bar:** `"Settings"`, back → `/profile` (pop, fallback `/profile`).
  - **Alignments Card:** `"Lunar Alignments"` + two `SettingsRow`s with pur switches (`SettingsProvider`) — `Receive Lunar Notifications` (ON), `Dark Magic Mode` (OFF).

### Screen 16: Sovereign Blood (`/cycle`)

- **Purpose:** Bleed-day detail: volume, pain, notes. Binds today's `DayLog`.
- **Layout Structure:**
  - **App Bar:** `AppTopBar("Sovereign Blood")`, back pops.
  - **Phase Card:** Dark card — gold caps `"SHEDDING PHASE"`, serif `"Day 3 of 5"` (23pt), 3 gold drops.
  - **Volume Card:** `"Bleeding Volume"` + single-select chips (`Spotting/Light/Medium/Heavy`).
  - **Pain Card:** `AppSliderRow` `"Uterine Contraction Pain"` (`0–10`, `"Level 6"`).
  - **Scribbles Card:** `"Grimoire Scribbles"` + field-bg note container (chamomile/raspberry text).

### Screen 17: Celestial Alerts (`/alerts`)

- **Purpose:** The cosmos' received whispers, one inbox.
- **Layout Structure:**
  - **App Bar:** `AppTopBar("Celestial Alerts")`, back pops.
  - **Inbox Header:** Serif `"Whispers Received"` + sub `"The cosmos whispers its reminders. Align your biological temple."`.
  - **Alert Cards:** 4 `AppCard` rows — tinted `IconBadge` + serif title + muted timestamp + 11/1.55 body: Period Commencing (pink drop, 2h), Fertility Window Peak (gold moon, 1d), Magical Log Missing (quill, 2d), Astrological Milestone (star, 3d).
  - **Entry:** Bell top-right on all shell tabs.

### Screen 18: Amulet Reminders (`/reminders`)

- **Purpose:** Calibrate mystical bells for upcoming tides.
- **Layout Structure:**
  - **App Bar:** `AppTopBar("Amulet Reminders")`, back pops.
  - **Header:** Sub `"Calibrate mystical bells to warn you of upcoming tides."` + pur `"X of 5 bells active"` live count.
  - **Bell Cards:** 5 `AppCard`s — tinted `IconBadge` + serif title + muted subtitle + pur switch; when ON, `InfoPill` pair (clock time + freq): Log Period Commencing (09:00 AM / Daily during peak), Take Cosmic Pill (08:30 AM / Every day), Fertility Window Alert (07:00 AM / Window start), PMS Warning (06:00 PM / 3 days prior), Somatic Hydration (Hourly / Daytime).
  - **Entry:** Profile `Amulet Bells` card button.

### Screen 19: Coven Sanctum (`/coven`)

- **Purpose:** Anonymous community whispers + wisdom tabs.
- **Layout Structure:**
  - **Segment Tabs:** `Recent Whispers` / `Ancients' Wisdom` (`tabBg` pill, ON = plum fill).
  - **Post Cards:** 3 `AppCard`s — avatar initials + serif author + muted meta + tag + 11/1.55 body + likes/comments footer (MC 24/8 Herbal Remedies, CS 42/15 Dream Work, LG 18/3 Cosmic Cycle).
  - **FAB:** `50pt` plum-gradient circle, gold `+`.

### Screen 20: Coven Binding (`/binding`)

- **Purpose:** Invite partners/coven to shared celestial map + visibility scopes.
- **Layout Structure:**
  - **App Bar:** `AppTopBar("Coven Binding")`, back pops.
  - **Invite Header Card:** Centered HS ✦(gold spark) KP avatars + serif `"Bind Cosmic Partners"` (15pt) + share-map sub copy.
  - **Invite Card:** `"Invite Cosmic Bond"` + `AppTextField` (`partner@cosmic.com`, mail lead) + `AppButton("Send Binding Scroll")`.
  - **Visibility Card:** `"Scroll Visibility"` + 3 pur-switch `SettingsRow`s (`SettingsProvider`) — Share Bleeding Predictions (ON), Share Fertile Windows (ON), Share Anonymized Symptom Log (OFF).
