# WITCHY: Mobile Design System & UI/UX Specification
**Document Version:** 2.0.0  
**Product Name:** Witchy — Comprehensive Menstrual, Fertility & Reproductive Health Tracker  
**Target Platforms:** iOS & Android (Cross-Platform Mobile App)  
**Primary Aesthetic:** Empowered Femtech / Warm Celestial Minimal / Clinical Clarity  

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
`#2D1B4E` |  Deep Plum       | (Hero Cards, Primary Branding, Navigation)
`#D95368` |  Terracotta Rose | (Menstruation Days, Flow Logs, Cycle Alerts)
`#4EA685` |  Sage Green      | (Fertile Window, Cervical Mucus Peak, Ovulation)
`#F4C430` |  Mystical Gold   | (Ovulation Peak, Pregnancy Trimesters, Highlights)
`#FAF6F8` |  Warm Blush      | (App Canvas Background, Soft Card Separators)

### 2.1 Color Palette & Design Tokens
Witchy uses a warm, reassuring palette anchored by **Deep Plum** for primary actions and contrast containers, paired with **Terracotta Rose** for menstruation/flow indicators, **Sage Green** for peak fertility/ovulation windows, and **Mystical Gold** for milestones and pregnancy highlights.

| Token Name | Hex Value | RGB / Opacity | Usage & Application | Contrast vs. Surface |
| :--- | :--- | :--- | :--- | :--- |
| `color-primary-dark` | `#2D1B4E` | `rgb(45, 27, 78)` | Primary buttons, hero dark cards, navigation headers | 13.8:1 (AAA) |
| `color-primary-mid` | `#5A3D77` | `rgb(90, 61, 119)` | Secondary buttons, active icons, interactive toggles | 7.6:1 (AAA) |
| `color-cycle-period` | `#D95368` | `rgb(217, 83, 104)` | Period flow days, menstruation alerts, cycle start markers | 4.8:1 (AA) |
| `color-cycle-fertile`| `#4EA685` | `rgb(78, 166, 133)` | Fertile window dates, LH surge indicators, ovulation day | 3.5:1 (AA-Large) |
| `color-accent-gold` | `#F4C430` | `rgb(244, 196, 48)` | Ovulation peak day, pregnancy milestones, streak badges | 1.8:1 (Dark Bg: 9.2:1) |
| `color-surface-base` | `#FFFFFF` | `rgb(255, 255, 255)` | Primary screen backgrounds, standard card containers | Base Ref |
| `color-surface-tint` | `#FAF6F8` | `rgb(250, 246, 248)` | App background canvas, alternating list sections | Base Ref |
| `color-text-primary` | `#1E1333` | `rgb(30, 19, 51)` | Primary headings, body copy, card titles | 16.4:1 (AAA) |
| `color-text-secondary`| `#6B5E82` | `rgb(107, 94, 130)` | Subtitles, captions, unselected tab items | 5.8:1 (AA) |
| `color-border-subtle` | `#E8DCE4` | `rgb(232, 220, 228)` | Input borders, card dividers, calendar grid lines | Decorative |


### 2.2 Typography System
The typography hierarchy balances an editorial serif for empowering cycle headers with a clean, high-legibility geometric sans-serif for health data, temperatures, and dates.

* **Primary Display/Heading Font:** `Cinzel` or `Cormorant Garamond` (Empowering, holistic elegance)
* **UI/Body Sans-Serif Font:** `Plus Jakarta Sans` or `Inter` (High legibility for numeric health data)

| Style Token | Font Family | Weight | Size (pt/dp) | Line Height | Letter Spacing | Usage Examples |
| :--- | :--- | :--- | :--- | :--- | :--- | :--- |
| `type-display-l` | Cinzel | 700 Bold | `32pt` | `1.20` | `+0.02em` | Splash logo ("Witchy"), Trimester countdown titles |
| `type-display-m` | Plus Jakarta Sans | 700 Bold | `28pt` | `1.20` | `-0.01em` | Cycle day number ("Day 14"), BBT values ("36.4°C") |
| `type-h1` | Cinzel | 600 SemiBold | `22pt` | `1.30` | `0.00em` | Screen headers ("Cycle Overview", "Fertility Chart") |
| `type-h2` | Plus Jakarta Sans | 700 Bold | `18pt` | `1.35` | `-0.01em` | Section titles ("Today's Symptoms", "BBT Trend") |
| `type-h3` | Plus Jakarta Sans | 600 SemiBold | `16pt` | `1.40` | `0.00em` | Card titles, wellness article titles |
| `type-body-l` | Plus Jakarta Sans | 400 Regular | `15pt` | `1.50` | `0.00em` | Cycle-synced health insights, educational copy |
| `type-body-m` | Plus Jakarta Sans | 400 Regular | `14pt` | `1.50` | `0.00em` | Standard list item text, symptom descriptions |
| `type-button` | Plus Jakarta Sans | 600 SemiBold | `15pt` | `1.00` | `+0.03em` | Primary CTA buttons, logging action buttons |
| `type-caption` | Plus Jakarta Sans | 500 Medium | `12pt` | `1.40` | `+0.04em` | Timestamps, cycle phase tags, ovulation test logs |
| `type-overline` | Plus Jakarta Sans | 700 Bold | `11pt` | `1.30` | `+0.08em` | Overlines ("OVULATION WINDOW", "FOLLICULAR PHASE") |

### 2.3 Spacing, Grid & Layout System
* **Grid Base:** 8pt base grid for structural spacing; 4pt minor grid for fine-tuning charts, badges, and calendar cells.
* **Screen Margins:** Standard horizontal margin of `20pt` (`24pt` on foldables/tablets).
* **Vertical Rhythm:**
  * Component Gap (within card): `8pt` – `12pt`
  * Section Gap: `24pt` – `32pt`
  * Screen Padding Bottom: `96pt` (to account for floating navigation bar).

### 2.4 Corner Radii & Elevation
* **`radius-s` (8pt):** Symptom chips, calendar date indicators, small input controls.
* **`radius-m` (16pt):** Biometric log cards, chart containers, symptom category boxes.
* **`radius-l` (24pt):** Hero cycle cards, pregnancy summary banners, bottom sheets.
* **`radius-pill` (999pt):** Primary action buttons, fertility status badges, filter tabs.
* **`shadow-card`:** `0 6px 24px -4px rgba(45, 27, 78, 0.08)` (Soft elevation for health cards).
* **`shadow-floating`:** `0 12px 36px -6px rgba(45, 27, 78, 0.16)` (Used for logging FABs and modals).

---

## 3. Component Library & UI Patterns

### 3.1 Cycle & Fertility Status Badges
* **Period Day Badge:** Solid Terracotta `#D95368` background, white text, pill radius.
* **Fertile Window Badge:** Solid Sage Green `#4EA685` background, white text, pill radius.
* **Ovulation Peak Badge:** Solid Mystical Gold `#F4C430` background, dark purple `#2D1B4E` text, accompanied by a trailing spark icon.
* **Luteal / Follicular Phase Badge:** Soft purple fill `#E8DFFF`, dark purple `#2D1B4E` text.

### 3.2 Biometric Logging Controls
* **Flow Severity Selector:** 4 rounded cards (Spotting, Light, Medium, Heavy) with liquid droplet iconography.
* **Symptom Multi-Select Pills:** Interactive chips with subtle borders; active state fills with `#2D1B4E` and white text.
* **BBT Quick-Entry Keypad:** Large, high-target decimal keyboard modal with custom standard deviation alerts for unexpected temperature spikes.
* **LH / Ovulation Test Reader Widget:** Photo-upload or toggle control (Negative, High, Peak) with visual line-intensity comparison reference.

### 3.3 Navigation Patterns
* **Fixed Bottom Navigation Bar:**
  * Height: `64pt` (+ safe area padding), background `#FFFFFF`, top border `#E8DCE4`.
  * **5 Core Destinations:**
    1. **Today / Cycle** (Icon: Astrological Sun/Moon Cycle Ring)
    2. **Calendar** (Icon: Full Month Calendar Grid)
    3. **Log Health** (Icon: Central Floating `+` Pill Button in `#D95368` or `#2D1B4E`)
    4. **Analytics & Charts** (Icon: Line Chart / BBT Trend)
    5. **Holistic & Settings** (Icon: Leaf / Profile Gear)

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
  * **Hero Emblem:** Circular emblem (`160x160pt`) with Deep Plum fill `#2D1B4E`, gold border, and a stylized crescent moon enclosing a geometric uterine/ovarian symbol.
  * **Title Section:** Brand name `"Witchy"` (`type-display-l`, bold), centered below emblem, followed by tagline `"Your holistic cycle, fertility, and reproductive health companion"`.
  * **Privacy Trust Badge:** Subtle badge: `"End-to-End Encrypted • Your Health Data Stays Yours"`.
  * **Bottom Actions:**
    * Primary CTA: `"Begin Health Journey"` (`#2D1B4E` pill button).
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
    * Outer Ring: Color-coded segments representing Period (`#D95368`), Follicular (`#E8DFFF`), Fertile Window (`#4EA685`), Ovulation Peak (`#F4C430`), and Luteal Phase.
    * Center Text: Displays `"Day 14"` (`type-display-m`) with subtitle `"Ovulation Day • High Fertility"`.
    * Pregnancy Mode Adaptation: Replaces cycle clock with **Gestational Week Dial** (`"Week 18 • 2nd Trimester"`).
  * **Quick Health Badges (2-Column Grid):**
    * Left Badge: `"Period in 14 Days"` (or `"Peak Fertility Today"`).
    * Right Badge: `"BBT: 36.4°C"` (with up/down trend arrow).
  * **Daily Hormone & Body Insight Card (Dark Plum Card):**
    * Background `#2D1B4E` with gold header `"Follicular Phase Energy"`.
    * Explains rising estrogen levels, expected cervical mucus changes, and physical energy shifts.
  * **Bottom Navigation Bar:** Active on **Today / Cycle** tab.

---

### Screen 05: Interactive Menstrual & Fertility Calendar (`/calendar`)
* **Purpose:** Comprehensive monthly/yearly view showing predicted periods, ovulation windows, and historical logs.
* **Layout Structure:**
  * **Header:** Month/Year selector (`"September 2026"`) with view toggle (`Month` vs `6-Month View`).
  * **Calendar Grid:**
    * 7-column grid (Sun–Sat).
    * **Visual Legend:** Solid red dots for Period Days, green highlight bars for Fertile Window, gold star for Predicted Ovulation Day.
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
  * **Bottom Sticky Action:** `"Save Daily Biometrics"` (`#2D1B4E`).

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
    * **Coverline (Horizontal Gold Line):** Auto-calculated line separating lower follicular temperatures from elevated luteal temperatures.
    * **Ovulation Marker:** Vertical green dashed line highlighting confirmed ovulation day after three consecutive elevated temperature readings.
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
    * Soft lavender container `#E8DFFF` summarizing bullet points for quick scanning.
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
* **Animation:** Outer segmented cycle ring smoothly animates from Day 1 to the current cycle day (`e.g., Day 14`) over `800ms` using `cubic-bezier(0.4, 0, 0.2, 1)`. When crossing into the Fertile Window, a subtle sage-green inner aura pulses gently (`box-shadow: 0 0 16px rgba(78, 166, 133, 0.35)`).

### 5.2 Accessibility (a11y) & Clinical Readability
* **Color Contrast & Independence:** Never rely solely on color to distinguish menstrual phases. Menstruation days use dotted fills alongside red `#D95368`, while fertile windows use diagonal striping alongside green `#4EA685`.
* **Screen Reader Descriptive Labels (`aria-label`):**
  * Cycle clock reports full clinical context: `"Current status: Day 14 of 28-day cycle, Ovulation Day, peak fertility probability"`.
  * BBT interactive charts announce temperature shifts explicitly: `"August 14, Day 14: Temperature 36.45 degrees Celsius, 0.38 degree rise from previous day"`.
* **Touch Target & Precision Input:** All logging checkboxes, symptom pills, and temperature adjusters maintain a minimum touch target of **`48x48 pt/dp`** to accommodate effortless logging during uncomfortable symptoms.
