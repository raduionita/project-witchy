# AGENTS.md — Period Tracker Flutter App Project

This document provides context, guidelines, and project structure information to help AI assistants understand and contribute effectively to this Dart + Flutter period tracking application.

---

## Project Overview

**Project Name**: Witchy 
**Description**: A comprehensive period tracker and reproductive health app built with Flutter/Dart, similar to Flo.  
**Target Users**: Individuals tracking menstrual cycles, fertility, pregnancy, and reproductive health.
**Platform**: Mobile-first (iOS, Android, Web via Flutter)

### Core Mission
Provide users with **private, accurate, and empowering reproductive health tracking** with a focus on user privacy and evidence-based health information.

---

## Rules

- NO Firebase, keep data local
- `shared_preferences` and `provider` for storage and state management
- Do NOT bundle multiple models, provides, widgets, screens, components into a single file, each in its own file.
- `build()` methods stay at the bottom of the class

---

## Technology Stack
**Flutter** - Cross-platform mobile UI framework
**Dart** - Programming language for Flutter
**Provider** - State management
**Authentication** - Google and Apple Sign-In, (NO Firebase)

---

## File Structure Conventions

### Naming Conventions
- **Files**: `snake_case.dart` (e.g., `period_tracker_screen.dart`)
- **Classes**: `PascalCase` (e.g., `PeriodTrackerScreen`)
- **Functions/Variables**: `camelCase` (e.g., `calculateCycleLength()`)
- **Constants**: `kPascalCase` (e.g., `kDefaultCycleLength`)
- **Private members**: Leading underscore (e.g., `_internalValue`)

### Import Organization
```dart
// Dart imports
import 'dart:async';
import 'dart:convert';

// Flutter imports
import 'package:flutter/material.dart';

// Package imports
import 'package:provider/provider.dart';

// Relative imports
import '../models/period_cycle.dart';
import '../services/period_tracking_service.dart';
```

---

## Running the App

```bash
flutter pub get
flutter run
```
