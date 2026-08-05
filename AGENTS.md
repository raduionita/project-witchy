# AGENTS.md — Period Tracker Flutter App Project

This document provides context, guidelines, and project structure information to help AI assistants understand and contribute effectively to this Dart + Flutter period tracking application.

---

## Project Overview

**Project Name**: Witchy 
**Description**: A comprehensive period tracker and reproductive health app built with Flutter/Dart, similar to Flo.  
**Target Users**: Individuals tracking menstrual cycles, fertility, pregnancy, and reproductive health.
**Platform**: Mobile-first (iOS & Android via Flutter)

### Core Mission
Provide users with **private, accurate, and empowering reproductive health tracking** with a focus on user privacy and evidence-based health information.

---

## Technology Stack
**Flutter** - Cross-platform mobile UI framework
**Dart** - Programming language for Flutter
**Provider** - State management

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
import 'package:hive/hive.dart';

// Relative imports
import '../models/period_cycle.dart';
import '../services/period_tracking_service.dart';
