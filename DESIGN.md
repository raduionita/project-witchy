# WITCHY: Mobile Design System & UI/UX Specification
**Document Version:** 2.1.0  
**Product Name:** Witchy — Comprehensive Menstrual, Fertility & Reproductive Health Tracker  
**Target Platforms:** iOS & Android (Cross-Platform Mobile App)  
**Primary Aesthetic:** Deep Purple Femtech / Soft Minimal / Clean Clinical Clarity
**Reference Mockup:** `resources/gemini-code-1789467553712.html` (authoritative for colors, radii, type)  

---

## 1. Executive Summary & Product Vision

**Witchy** is a comprehensive, beautifully designed women’s health application that re-frames reproductive health tracking as an empowering, intuitive, and holistic daily practice. By bridging clinical-grade biometric logging (menstrual flow, basal body temperature, ovulation hormones, gestational milestones) with an elegant, celestial-inspired aesthetic, Witchy allows users to understand the natural rhythms of their bodies without the sterile, patronizing feel of traditional medical apps.

### 1.1 Core UX Objectives
* **Dynamic Goal Adaptation:** Effortlessly pivot UI states and terminology across four primary life stages: **Cycle Tracking**, **Trying to Conceive (TTC)**, **Pregnancy Monitoring**, and **Perimenopause / Holistic Health**.
* **Clinical Precision Meets Holistic Design:** Present complex biometric data (luteal phase lengths, BBT shifts, LH surge charts, fertility windows) in layered, visually intuitive interfaces that remain accessible to everyday users.
* **Privacy-First Architecture:** Emphasize zero-knowledge data architecture, local-only storage toggles, and clear visual cues that reassure users their sensitive reproductive health data is protected.
* **Empowering Daily Rituals:** Transform routine health logging into a meaningful self-care ritual through rewarding visual feedback, smooth interactions, and cycle-synced wellness recommendations.

---

## 2. Design System Architecture & Foundational Tokens

### 2.0 COLOR TOKEN VISUAL HARMONY
`#3B0066` |  Deep Purple       | (Hero Cards, Primary Branding, Navigation, Period Days)
`#5E2A84` |  Primary Light     | (Secondary Buttons, Active Icons, Toggles)
`#8154A2` |  Primary Lighter   | (Accents, Gradients)
`#E0D4EA` |  Light Lavender    | (Splash BG, Fertile Window, Selected Pills, Slider Track)
`#FFB7B2` |  Soft Coral/Pink   | (Ovulation Peak, Fertility Highlights, Best-Value Badge)
`#F8F6FA` |  Light Gray-Purple | (App Canvas Background)
`#333333` |  Text Dark          | (Headings, Body)
`#666666` |  Text Light         | (Subtitles, Captions)
`#E0E0E0` |  Border Gray        | (Input Borders, Dividers)

### 2.1 Color Palette & Design Tokens
Witchy uses a clean purple-led palette per mockup: **Deep Purple `#3B0066`** for primary actions, period markers, hero cards and charts, paired with **Light Lavender `#E0D4EA`** for fertile-window fills and splash backgrounds, and **Soft Coral/Pink `#FFB7B2`** for ovulation peak and fertility highlights. App canvas is `#F8F6FA`, cards `#FFFFFF`.

| Token Name | Hex Value | RGB / Opacity | Usage & Application | Contrast vs. Surface |
| :--- | :--- | :--- | :--- | :--- |
| `color-primary` | `#3B0066` | `rgb(59, 0, 102)` | Primary buttons, hero dark cards, period days, active pills, chart bars, toggles ON | 12.9:1 (AAA) |
| `color-primary-light` | `#5E2A84` | `rgb(94, 42, 132)` | Secondary accents, avatar placeholders, gradient steps | 8.1:1 (AAA) |
| `color-primary-lighter` | `#8154A2` | `rgb(129, 84, 162)` | Tertiary accents, gradients | 4.9:1 (AA) |
| `color-primary-lightest` | `#E0D4EA` | `rgb(224, 212, 234)` | Splash BG, fertile-window fills, selected-light pills, slider track, avatar ring | Decorative |
| `color-secondary-coral` | `#FFB7B2` | `rgb(255, 183, 178)` | Ovulation day, fertility-window active underline, featured accents | 1.6:1 (Dark Bg: 9.5:1) |
| `color-cycle-period` | `#3B0066` | `rgb(59, 0, 102)` | Period flow days, menstruation markers (solid fill, white text) | 12.9:1 (AAA) |
| `color-cycle-fertile`| `#E0D4EA` | `rgb(224, 212, 234)` | Fertile window dates (`#3B0066` text on `#E0D4EA` fill) | Decorative |
| `color-cycle-ovulation` | `#FFB7B2` | `rgb(255, 183, 178)` | Ovulation peak day (white text) | Decorative |
| `color-surface-base` | `#FFFFFF` | `rgb(255, 255, 255)` | Primary screen backgrounds, standard card containers | Base Ref |
| `color-surface-tint` | `#F8F6FA` | `rgb(248, 246, 250)` | App background canvas, empty-state panels | Base Ref |
| `color-text-primary` | `#333333` | `rgb(51, 51, 51)` | Primary headings, body copy, card titles | 12.6:1 (AAA) |
| `color-text-secondary`| `#666666` | `rgb(102, 102, 102)` | Subtitles, captions, unselected tab items | 5.7:1 (AA) |
| `color-border-subtle` | `#E0E0E0` | `rgb(224, 224, 224)` | Input borders, card dividers, calendar grid lines | Decorative |


### 2.2 Typography System
Per mockup: system sans stack `'Segoe UI', Tahoma, Geneva, Verdana, sans-serif` throughout. No serif display. Hierarchy is weight/size led.

* **Primary Display/Heading Font:** System sans stack (Brand, headers, numeric readouts)
* **UI/Body Sans-Serif Font:** Same system sans stack

| Style Token | Font Family | Weight | Size (pt/dp) | Line Height | Letter Spacing | Usage Examples |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `type-display-l` | System sans | 700 Bold | `32pt` | `1.20` | `0.00em` | Splash logo ("Witchy"), brand name |
| `type-display-m` | System sans | 700 Bold | `42–48pt` | `1.00–1.20` | `0.00em` | Cycle day number ("14"), slider value ("28 Days") |
| `type-h1` | System sans | 600 SemiBold | `18pt` | `1.30` | `0.00em` | Screen headers ("Today", "Calendar") |
| `type-h2` | System sans | 700 Bold | `20–24pt` | `1.30` | `0.00em` | Setup headers ("How long is your cycle?"), featured titles |
| `type-h3` | System sans | 700 Bold | `16pt` | `1.40` | `0.00em` | Section titles ("Flow", "Symptoms", "Mood") |
| `type-body-l` | System sans | 400 Regular | `15–16pt` | `1.50` | `0.00em` | Form inputs, insights copy |
| `type-body-m` | System sans | 400 Regular | `14pt` | `1.40` | `0.00em` | List items, banner text, article blurbs |
| `type-button` | System sans | 600 SemiBold | `16pt` | `1.00` | `0.00em` | Primary/secondary CTA buttons (`15px` padding, `25px` radius) |
| `type-caption` | System sans | 400 Regular | `12pt` | `1.40` | `0.00em` | Timestamps, legend labels, nav labels (`10px` nav) |
| `type-overline` | System sans | 400 Regular | `12pt` | `1.30` | `+0.08em` | Uppercase tags ("FEATURED") |

### 2.3 Spacing, Grid & Layout System
* **Grid Base:** 8pt base grid for structural spacing; 4pt minor grid for fine-tuning charts, badges, and calendar cells.
* **Screen Margins:** Standard horizontal margin of `20pt` (`24pt` on foldables/tablets).
* **Vertical Rhythm:**
  * Component Gap (within card): `8pt` – `12pt`
  * Section Gap: `24pt` – `32pt`
  * Screen Padding Bottom: `96pt` (to account for floating navigation bar).

### 2.4 Corner Radii & Elevation
Per mockup (`375x812` screen, `40px` frame radius):
* **`radius-s` (8pt):** Article thumbnails, small controls.
* **`radius-m` (12–15pt):** Inputs (`12px`), status/stat cards, info banners, featured article, chart container, settings groups (`15px`).
* **`radius-l` (24pt):** Reserved for hero sheets/modals (mockup uses `15px` max in-app).
* **`radius-pill` (20–25pt):** Primary/secondary buttons (`25px`), symptom pills (`20px`), calendar days (full circle `50%`), logo circle (full circle).
* **Calendar day cell:** `30x30pt` circle; legend dot `10x10pt` circle.
* **Toggle:** `50x24pt` track, `24px` radius, `20x20pt` thumb.
* **`shadow-card`:** `0 2px 5px rgba(0,0,0,0.02)` (status/article/stat cards).
* **`shadow-hero`:** `0 4px 10px rgba(0,0,0,0.05)` (cycle progress circle).
* **`shadow-frame`:** `0 10px 30px rgba(0,0,0,0.5)` (device frame only, not in-app).

---

## 3. Component Library & UI Patterns

### 3.1 Cycle & Fertility Status Badges
* **Period Day Badge:** Solid Deep Purple `#3B0066` background, white text, circle.
* **Fertile Window Badge:** Light Lavender `#E0D4EA` background, Deep Purple `#3B0066` text, circle.
* **Ovulation Peak Badge:** Soft Coral `#FFB7B2` background, white text, circle.
* **Status Cards:** White `#FFFFFF`, `15px` radius, `0 2px 5px rgba(0,0,0,0.02)`; active card has `3px` coral `#FFB7B2` bottom border; values in `#3B0066`, highlight values in `#FFB7B2`.
* **Info Banner:** Solid `#3B0066` background, white text, `15px` radius.

### 3.2 Biometric Logging Controls
* **Flow Severity Selector:** Pill chips (`20px` radius, white bg, `#E0E0E0` border); active fills `#3B0066` with white text.
* **Symptom Multi-Select Pills:** White chips with `#E0E0E0` border; active fills `#3B0066`/white; secondary-selected fills `#E0D4EA` with `#3B0066` text.
* **Form Inputs:** `12px 15px` padding, `12px` radius, `#E0E0E0` border, `#F8F6FA` fill.
* **Cycle Slider:** `6px` track in `#E0D4EA` (`3px` radius), `24px` circular thumb in `#3B0066`; value readout `48px` bold `#3B0066`.
* **Primary Button:** Full-width, `15px` padding, `#3B0066` fill, white text, `25px` radius, `16px`/600.
* **Secondary Button:** Full-width, transparent fill, `#3B0066` text/border, `25px` radius.
* **BBT Quick-Entry Keypad:** Large, high-target decimal keyboard modal with custom standard deviation alerts for unexpected temperature spikes.
* **LH / Ovulation Test Reader Widget:** Photo-upload or toggle control (Negative, High, Peak) with visual line-intensity comparison reference.

### 3.3 Navigation Patterns
* **Fixed Bottom Navigation Bar:**
  * Height: `64pt` (+ safe area, `10px 0 25px` padding), background `#FFFFFF`, top border `#E0E0E0`.
  * Inactive items `#666666`, active item `#3B0066`, labels `10px`.
  * **5 Core Destinations:**
    1. **Today / Cycle** (Icon: Home)
    2. **Calendar** (Icon: Calendar grid)
    3. **Log Health** (Icon: Central `+` in `#3B0066` circle, white glyph)
    4. **Analytics & Charts** (Icon: Bar/line chart)
    5. **Holistic & Settings** (Icon: Profile)
* **Headers:** White `#FFFFFF` bar, `18px`/600 centered title, `20px` icon buttons in `#333333`.
* **Content Canvas:** `#F8F6FA` default; form/log screens use white `#FFFFFF` variant.

---

## 4. Screen-by-Screen UI/UX Specifications

This section details the layout, functional components, data schemas, and user flows for all **14 screens** in the comprehensive health tracking architecture.

### 4.1 App Navigation & Screen Architecture

| User Journey Phase | Core Screen | Connected / Sub-Screens | Dynamic Routing & Behavior |
| :--- | :--- | :--- | :--- |
| **I. Onboarding & Setup** | **01. Welcome / Splash** (`/welcome`) | **02. Goal & Health Profile** (`/onboarding/profile`)<br>**03. Cycle Baseline Setup** (`/onboarding/baseline`) | Direct sequential flow; sets user stage (Cycle, TTC, Pregnancy, Perimenopause) to govern app terminology. |
| **II. Daily Ritual & Logging** | **04. Daily Cycle Clock & Dashboard** (`/dashboard`) | **05. Menstrual & Fertility Calendar** (`/calendar`)<br>**06. Biometric & Symptom Log** (`/check-in`) | Dashboard acts as the primary hub; central floating action button (FAB) opens **06. Log** from any root tab. |
| **III. Clinical Analytics & TTC** | **07. Cycle Trends & Analytics** (`/insights/overview`) | **08. Basal Temperature Chart** (`/insights/bbt`)<br>**09. Fertility Predictor** (`/fertility/window`) | Automatically highlights BBT shifts and LH test data if user's goal is set to Trying to Conceive (TTC). |
| **IV. Gestational Journey** | **10. Pregnancy & Gestational Tracker** (`/pregnancy`) | *Replaces Screen 04 & 07 when Pregnancy Mode is active* | Shifts primary metrics from cycle day/ovulation to gestational week, fetal milestones, and prenatal care. |
| **V. Holistic Wellness** | **11. Holistic Wellness Library** (`/wellness/library`) | **12. Educational Guide Detail** (`/wellness/detail`) | Content dynamically filters based on user's current cycle phase (e.g., Luteal Phase nutrition). |
| **VI. System & Security** | **13. Health Sync & Wearables** (`/settings/health`) | **14. Zero-Knowledge Privacy** (`/settings/privacy`) | Accessible via profile gear; manages local-only storage, biometric encryption, and device sensors. |

---

### Screen 01: Splash & Welcome (`/welcome`)
* **Purpose:** Establish brand trust, holistic health authority, and privacy focus.
* **Layout Structure:**
  * **Hero Emblem:** Circular emblem (`120x120pt`, mockup `logo-circle`) with Deep Purple fill `#3B0066`, serif `W` glyph in white, on Light Lavender `#E0D4EA` splash canvas.
  * **Title Section:** Brand name `"Witchy"` (`type-display-l`, bold), centered below emblem, followed by tagline `"Your holistic cycle, fertility, and reproductive health companion"`.
  * **Privacy Trust Badge:** Subtle badge: `"End-to-End Encrypted • Your Health Data Stays Yours"`.
  * **Bottom Actions:**
    * Primary CTA: `"Begin Health Journey"` (`#3B0066` pill button).
    * Secondary Link: `"Restore Encrypted Backup — Sign In"`.

---

### Screen 02: Primary Health Goal & Setup (`/onboarding/profile`)
* **Purpose:** Determine the user's reproductive stage to dynamically adapt the app's algorithms and UI terminology.
* **Layout Structure:**
  * **Header:** Progress bar (Step 1 of 3) with title `"What is your primary focus?"`.
  * **Goal Selector Grid (4 Interactive Cards):**
    1. **Track Menstrual Cycle:** `"Understand my period, symptoms, and hormonal phases."`
    2. **Try to Conceive (TTC):** `"Maximize fertility window, track ovulation & BBT."`
    3. **Track Pregnancy:** `"Monitor baby's development, milestones & maternal health."`
    4. **Perimenopause & Balance:** `"Navigate irregular cycles, hormonal shifts & wellness."`
  * **Bottom Actions:** `"Continue"` button (updates onboarding flow based on selected goal).

---

### Screen 03: Cycle History & Baseline Setup (`/onboarding/cycle-baseline`)
* **Purpose:** Collect baseline menstrual parameters to initialize predictive algorithms.
* **Layout Structure:**
  * **Header:** Progress bar (Step 2 of 3) and title `"Your Menstrual Baseline"`.
  * **Date Picker:** `"When did your last period start?"` (Interactive calendar selector).
  * **Numeric Sliders:**
    * **Average Cycle Length:** Range slider (`20 to 45 days`, default `28`).
    * **Average Period Duration:** Range slider (`2 to 10 days`, default `5`).
  * **Contraceptive / Hormonal Method Toggle:** Selectors for *None/Natural*, *Combined Pill*, *IUD (Hormonal/Copper)*, *Progestin-Only*.
  * **Bottom Actions:** `"Generate My Health Chart"` button.

---

### Screen 04: Daily Dashboard & Cycle Clock (`/dashboard`)
* **Purpose:** The core home screen; provides instant visibility into current cycle day, fertile status, hormone phase, and daily health insights.
* **Layout Structure:**
  * **Top Bar:** User greeting (`"Good morning, [User]"`) on left; current date and Privacy Shield icon on right.
  * **Dynamic Cycle Clock (Hero Centerpiece):**
    * Large circular dial (`220x220pt`) mapping the entire menstrual cycle.
    * Outer Ring: Color-coded segments representing Period (`#3B0066` solid), Fertile Window (`#E0D4EA` fill with `#3B0066` text), Ovulation Peak (`#FFB7B2`). Cycle circle is `180pt` white card with `10px` lavender ring and purple progress arc.
    * Center Text: Displays `"Day 14"` (`type-display-m`) with subtitle `"Ovulation Day • High Fertility"`.
    * Pregnancy Mode Adaptation: Replaces cycle clock with **Gestational Week Dial** (`"Week 18 • 2nd Trimester"`).
  * **Quick Health Badges (2-Column Grid):**
    * Left Badge: `"Period in 14 Days"` (or `"Peak Fertility Today"`).
    * Right Badge: `"BBT: 36.4°C"` (with up/down trend arrow).
  * **Daily Hormone & Body Insight Card (Dark Purple Card):**
    * Background `#3B0066` with white body text (`15px` radius, flex row with icon).
    * Explains rising estrogen levels, expected cervical mucus changes, and physical energy shifts.
  * **Bottom Navigation Bar:** Active on **Today / Cycle** tab.

---

### Screen 05: Interactive Menstrual & Fertility Calendar (`/calendar`)
* **Purpose:** Comprehensive monthly/yearly view showing predicted periods, ovulation windows, and historical logs.
* **Layout Structure:**
  * **Header:** Month/Year selector (`"September 2026"`) with view toggle (`Month` vs `6-Month View`).
  * **Calendar Grid:**
    * 7-column grid (Sun–Sat).
    * **Visual Legend:** Solid purple `#3B0066` dots for Period Days, lavender `#E0D4EA` fills for Fertile Window, coral `#FFB7B2` for Predicted Ovulation Day. Day cells are `30x30` circles.
    * Small symbols inside cells indicate logged data: drops for bleeding, hearts for intimacy, thermometers for BBT entry.
  * **Selected Date Summary Panel (Bottom Half):**
    * Shows full breakdown for selected date: Phase name, logged symptoms, BBT reading, and LH test result.
    * Action CTA: `"Edit Health Log for Sept 14"`.

---

### Screen 06: Daily Biometric & Symptom Log (`/check-in`)
* **Purpose:** Efficient, friction-free daily data entry for all reproductive health biometrics.
* **Layout Structure:**
  * **Header:** Title `"Daily Health Log"` with date selector and save button.
  * **Menstrual Flow Section:** 4 droplet icon buttons (`Spotting`, `Light`, `Medium`, `Heavy`) + Flow color selector.
  * **Basal Body Temperature (BBT) Input:**
    * Digital temperature display (`"36.45 °C"`) with quick `+/-` adjustment buttons and decimal keypad trigger.
    * Time-taken timestamp (`"Logged at 07:15 AM"`).
  * **Cervical Mucus / Fluid Selector:**
    * Horizontal scroll chips: `Dry`, `Sticky`, `Creamy`, `Watery`, `Eggwhite (Peak Fertility)`.
  * **Ovulation / Pregnancy Test Reader:**
    * Selector: `LH Negative`, `LH High`, `LH Peak`, `Pregnancy Positive/Negative`.
  * **Symptoms & Mood Multi-Select Grid:**
    * Categorized chips: *Cramps*, *Headache*, *Bloating*, *Breast Tenderness*, *High Libido*, *Fatigue*, *Brain Fog*.
  * **Bottom Sticky Action:** `"Save Daily Biometrics"` (`#3B0066`).

---

### Screen 07: Cycle Trends & Length Analytics (`/insights/overview`)
* **Purpose:** Longitudinal analysis of cycle regularity, period duration variation, and luteal phase stability.
* **Layout Structure:**
  * **Header:** Title `"Cycle Statistics"` with time range toggle (`6 Months`, `1 Year`, `All Time`).
  * **Cycle Regularity Distribution Bar Chart:**
    * Displays variation in cycle lengths over time (e.g., historical bars ranging between `27–30 days`).
    * Reference line indicating user's rolling average (`28.4 days`).
  * **Key Biometric Metric Cards (2-Column Grid):**
    * Left: `"Average Cycle: 28 Days"` (with irregularity variance `±1.2 days`).
    * Right: `"Average Luteal Phase: 13 Days"` (crucial indicator for fertility/progesterone health).
  * **Symptom Frequency Distribution:**
    * Horizontal progress bars ranking most frequent premenstrual symptoms over the past 6 cycles.

---

### Screen 08: Basal Body Temperature (BBT) & Ovulation Charting (`/insights/bbt-chart`)
* **Purpose:** Advanced clinical-grade BBT graphing to visually confirm ovulation via biphasic temperature shifts.
* **Layout Structure:**
  * **Header:** Title `"Basal Body Temperature"` with cycle selector dropdown (`"Cycle 14: Aug 18 – Sep 15"`).
  * **Interactive Biphasic BBT Line Graph:**
    * X-Axis: Cycle days (Days 1 to 30).
    * Y-Axis: Temperature range (`36.0°C – 37.2°C` or Fahrenheit equivalent).
    * **Coverline (Horizontal Coral Line `#FFB7B2`):** Auto-calculated line separating lower follicular temperatures from elevated luteal temperatures.
    * **Ovulation Marker:** Vertical purple `#3B0066` dashed line highlighting confirmed ovulation day after three consecutive elevated temperature readings.
    * **Chart Bars:** Solid `#3B0066` bars with `5px` top radius on white `#FFFFFF` card (`15px` radius).
  * **Biometric Legend & Overlays:**
    * Toggles to overlay LH test results and cervical mucus peak days onto the temperature curve.
  * **Clinical Interpretation Box:** `"Ovulation confirmed on Day 14. Your luteal phase temperature shift is strong (+0.38°C average)."`

---

### Screen 09: Fertility & Ovulation Window Predictor (`/fertility/window`)
* **Purpose:** Dedicated view for users Trying to Conceive (TTC), highlighting peak conception probability days.
* **Layout Structure:**
  * **Header:** Title `"Fertility Window"` with conception probability meter.
  * **7-Day Conception Window Bar:**
    * Horizontal timeline highlighting the 5 days before ovulation, ovulation day (Peak), and 1 day post-ovulation.
    * Percentage chance of conception displayed above each day (`e.g., Day 12: 25%, Day 13: 40%, Day 14 (Peak): 33%`).
  * **Intimacy & Insemination Logger:**
    * Quick-toggle buttons to record intercourse or insemination dates.
  * **Fertility Scorecard:**
    * Analyzes alignment of BBT shift, LH positive test, and egg-white cervical mucus to provide a daily `"Conception Index"`.

---

### Screen 10: Pregnancy & Gestational Tracker (`/pregnancy/dashboard`)
* **Purpose:** Replaces the standard cycle dashboard when Pregnancy Mode is enabled; tracks fetal development and maternal health.
* **Layout Structure:**
  * **Header:** Title `"Pregnancy Journey"` with Due Date countdown (`"154 Days to Go"`).
  * **Gestational Hero Ring:**
    * Large radial progress bar showing current progress (`"Week 18 • Day 4"` out of 40 weeks).
    * Center graphic shows illustrated celestial representation of baby's current size (`"Size of a Sweet Potato"`).
  * **Maternal Vitals & Milestone Cards (2-Column Grid):**
    * Left: `"Trimester 2: Week 14–27"`.
    * Right: `"Next Prenatal Appointment: Sept 12"`.
  * **Weekly Fetal Development Summary:**
    * Detailed, empathetic breakdown of neurological and physical developments occurring during the current week.

---

### Screen 11: Holistic Wellness & Cycle-Syncing Library (`/wellness/library`)
* **Purpose:** Provide medically sound, holistic self-care, nutritional, and herbal guidance tailored to the current menstrual cycle phase.
* **Layout Structure:**
  * **Header & Search:**
    * Title `"Cycle-Synced Wellness"` with search bar (`"Search nutrition, cramps, sleep..."`).
  * **Phase Filter Tabs:**
    * Selectable tabs: `Menstrual`, `Follicular`, `Ovulatory`, `Luteal`, `Pregnancy`, `Postpartum`.
  * **Wellness Resource Cards (Grid Layout):**
    * **Card 1 (Nutrition):** `"Luteal Phase Nourishment"` — Magnesium-rich foods to curb sugar cravings and stabilize mood.
    * **Card 2 (Movement):** `"Gentle Menstrual Yoga"` — 15-minute low-impact stretching to relieve pelvic floor tension.
    * **Card 3 (Herbal):** `"Red Raspberry Leaf & Nettle Infusions"` — Evidence-based overview of uterine-supporting teas.

---

### Screen 12: Educational Guide & Clinical Reference Detail (`/wellness/detail`)
* **Purpose:** Long-form reading interface for evidence-based reproductive health articles and clinical guides.
* **Layout Structure:**
  * **Hero Header:** Full-width illustration with article title `"Understanding Luteal Phase Defect & Progesterone"`.
  * **Clinical Review Badge:** `"Reviewed by Dr. Elena Vance, MD, OB/GYN • August 2026"`.
  * **Article Body:**
    * Clean typography (`type-body-l`, 1.6 line height) breaking down hormonal pathways, common symptoms, and when to consult a physician.
  * **Key Takeaway Box:**
    * Soft lavender container `#E0D4EA` summarizing bullet points for quick scanning.
  * **Related Reading / Source Citations:** Links to peer-reviewed gynecology and reproductive endocrinology studies.

---

### Screen 13: Health Integration & Wearables (`/settings/health`)
* **Purpose:** Manage synchronization with external health ecosystems and smart temperature wearables.
* **Layout Structure:**
  * **Header:** Title `"Health Sync & Wearables"`.
  * **Platform Integration Group:**
    * Row 1: `"Apple Health / HealthKit"` (Toggle: ON — Syncs periods, BBT, and cervical mucus).
    * Row 2: `"Google Health Connect"` (Toggle: OFF).
  * **Smart Wearable Sensors:**
    * Row 1: `"Oura Ring Temperature Sync"` (Status: Connected — Imports nocturnal skin temperature deviations).
    * Row 2: `"Apple Watch Wrist Temperature"` (Status: Connected).
  * **Biometric Sync Preferences:**
    * Toggles to select which specific data points are read vs. written to external health stores.

---

### Screen 14: Zero-Knowledge Privacy & Data Protection (`/settings/privacy`)
* **Purpose:** Ensure complete user control, transparency, and clinical-grade security over sensitive reproductive health data.
* **Layout Structure:**
  * **Header:** Title `"Privacy & Security"`.
  * **Data Storage Architecture Group:**
    * Row 1: `"Local-Only Storage Mode"` (Toggle: OFF/ON — Disables cloud backup; data resides exclusively on device).
    * Row 2: `"End-to-End Encrypted Cloud Backup"` (Status: Enabled — Encrypted using user-held cryptographic key).
  * **Security Controls:**
    * Row 1: `"Require FaceID / Biometric Passcode on Open"` (Toggle: ON).
    * Row 2: `"Incognito Mode"` (Hides identifying period/fertility labels in push notifications).
  * **Data Export & Deletion:**
    * Action 1: `"Export Complete Health Record (PDF / CSV)"`.
    * Action 2: `"Permanently Erase All Reproductive Data"`.

---

## 5. Interaction Patterns, Animations & Accessibility

### 5.1 Cycle Clock Illumination & Phase Transition
* **Trigger:** Loading the Daily Dashboard screen.
* **Animation:** Outer segmented cycle ring smoothly animates from Day 1 to the current cycle day (`e.g., Day 14`) over `800ms` using `cubic-bezier(0.4, 0, 0.2, 1)`. Fertile-window state uses lavender `#E0D4EA` fill with subtle purple glow (`box-shadow: 0 0 16px rgba(59, 0, 102, 0.25)`).

### 5.2 Accessibility (a11y) & Clinical Readability
* **Color Contrast & Independence:** Never rely solely on color to distinguish menstrual phases. Menstruation days use dotted fills alongside purple `#3B0066`, while fertile windows use diagonal striping alongside lavender `#E0D4EA` + coral `#FFB7B2` for ovulation.
* **Screen Reader Descriptive Labels (`aria-label`):**
  * Cycle clock reports full clinical context: `"Current status: Day 14 of 28-day cycle, Ovulation Day, peak fertility probability"`.
  * BBT interactive charts announce temperature shifts explicitly: `"August 14, Day 14: Temperature 36.45 degrees Celsius, 0.38 degree rise from previous day"`.
* **Touch Target & Precision Input:** All logging checkboxes, symptom pills, and temperature adjusters maintain a minimum touch target of **`48x48 pt/dp`** to accommodate effortless logging during uncomfortable symptoms.
