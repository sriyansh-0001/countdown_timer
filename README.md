# Modern Countdown Timer Application ⏱️

[![Flutter](https://img.shields.io/badge/Flutter-3.47.5-02569B?logo=flutter)](https://flutter.dev)
[![Dart](https://img.shields.io/badge/Dart-3.13.4-0175C2?logo=dart)](https://dart.dev)
[![Material Design](https://img.shields.io/badge/Material%203-Enabled-7B1FA2)](https://m3.material.io)
[![Tests](https://img.shields.io/badge/Tests-19%2F19%20Passing-success)](https://flutter.dev)

A modern, high-precision, responsive mobile countdown timer developed using Flutter and Material 3 design guidelines. Designed for students, professionals, and productivity enthusiasts to manage focus sessions, workouts, study sprints, and daily tasks with reliability and elegance.

---

## 🎓 Academic Project Information

- **Institution:** ACE Engineering College (An Autonomous Institution, Affiliated to JNTUH)
- **Department:** Department of Computer Science & Engineering
- **Program:** Bachelor of Technology (B.Tech), 3rd Year, Semester 1
- **Course / Lab:** Mobile Application Development Lab (Flutter 2026 Curriculum)
- **Student Name:** Sriyansh
- **Roll Number:** `24AG1A05585`
- **Academic Year:** 2026

---

## 🌟 Key Features

1. **High-Precision Time Engine:**
   - Calculations rely on absolute target timestamps (`targetEndTime.difference(DateTime.now())`), completely eliminating timer drift caused by periodic loop execution delays.
   - Smooth 200ms tick updates for responsive UI rendering.

2. **App Lifecycle & Crash Recovery:**
   - Subscribed to `WidgetsBindingObserver` to detect app state transitions (`didChangeAppLifecycleState`).
   - Automatically synchronizes remaining duration when waking from background or inactive states.
   - Persists running and paused states in local device storage (`SharedPreferences`) to restore active sessions if the app is terminated by the OS.

3. **Material 3 Visual Design & Theming:**
   - Premium Slate and Deep Navy palette (`#0F172A`, `#0B1120`) paired with Cyan and Teal accents (`#06B6D4`, `#14B8A6`).
   - Full support for **Light**, **Dark**, and **System** themes with zero-restart instant switching.
   - Monospaced digital countdown typography (`HH:MM:SS`) to eliminate numerical jitter during countdowns.
   - State-aware dynamic circular progress ring (`CircularTimerProgress`) with glowing ambient stroke.

4. **Presets & Custom Duration Management:**
   - 8 built-in quick presets:
     - ⚡ Quick Test (1 min)
     - ☕ Short Break (5 min)
     - 🫖 Tea Break (10 min)
     - 🛌 Power Nap (15 min)
     - 🎓 Study Session (25 min)
     - 🏋️ Workout (30 min)
     - 📖 Reading Time (45 min)
     - 🧠 Deep Work (60 min)
   - Interactive **Custom Duration Dialog** incorporating Flutter Form Validation (`Form`, `GlobalKey<FormState>`, `TextFormField`) with numerical limits and name tagging.
   - User-created custom presets with full persistence and deletion support.
   - Quick time-bump buttons (`+1 min`, `+5 min`) during active or paused timers.

5. **Multi-Sensory Alerts & Feedback:**
   - Audio chime looped alert upon completion using valid PCM audio.
   - Tactile haptic vibration for button taps and alarm notifications.
   - Modal completion dialog with one-tap dismissal and instant session restart.

6. **History Logging & Analytics:**
   - Automatically logs completed timer sessions with duration, session name, and formatted timestamp.
   - Dedicated Session History screen (`/history`) with empty-state handling and complete history clearing.

---

## 🏗️ Architecture & Directory Structure

The application adopts a **Service-Oriented Architecture (SOA)** combined with the **Provider** pattern for reactive state management, adhering to the ACE Engineering College Flutter Lab standards:

```
sriyanshantigravity/
├── assets/
│   └── sounds/
│       └── timer_beep.wav          # PCM audio alarm asset
├── lib/
│   ├── models/
│   │   ├── timer_preset.dart       # Preset data model & serialization
│   │   └── timer_history_item.dart # Completed session history model
│   ├── screens/
│   │   ├── custom_timer_dialog.dart# Form & validated duration input
│   │   ├── history_screen.dart     # Logged sessions list
│   │   ├── home_screen.dart        # Main responsive timer dashboard
│   │   └── settings_screen.dart    # Theme, sound, and student info
│   ├── services/
│   │   ├── audio_service.dart      # Sound & haptic vibration manager
│   │   ├── storage_service.dart    # SharedPreferences local persistence
│   │   └── timer_service.dart      # Core ChangeNotifier business engine
│   ├── theme/
│   │   └── app_theme.dart          # Material 3 light & dark configurations
│   └── main.dart                   # Application entry point & route registration
├── test/
│   ├── unit/
│   │   ├── model_test.dart         # Data serialization & formatting tests
│   │   └── timer_service_test.dart # Business logic & drift calculation tests
│   └── widget_test.dart            # UI widget rendering and interaction tests
└── pubspec.yaml                    # Package dependencies and asset declarations
```

---

## 🧪 Automated Testing Suite

All unit and widget tests are fully automated and verified:

```bash
flutter test
```

### Test Coverage Highlights:
- **`model_test.dart` (4 tests):** Default presets integrity, JSON serialization/deserialization, `fromDuration` factory, and relative date formatting.
- **`timer_service_test.dart` (10 tests):** Initial state verification, preset selection, target-based time calculation, pause/resume continuity, reset restoration, +1m/+5m time extension, custom duration configuration, and custom preset storage operations.
- **`widget_test.dart` (5 tests):** Home screen component rendering, Start/Pause/Resume button transitions, dynamic time bumping, preset selection UI updates, and navigation to the Academic Project Profile in Settings.

**Results:** 19/19 tests passing (100% pass rate).

---

## 🚀 Getting Started & Execution

### Prerequisites
- Flutter SDK `^3.47.5` or later
- Dart SDK `^3.13.4` or later
- Android Studio / VS Code / Flutter CLI
- Physical device or Emulator / Chrome Browser / Windows Desktop

### Installation
1. Clone or navigate to the workspace directory:
   ```bash
   cd C:\Users\harin\Desktop\sriyanshantigravity
   ```
2. Retrieve dependencies:
   ```bash
   flutter pub get
   ```
3. Run static analysis:
   ```bash
   flutter analyze
   ```
4. Run automated test suite:
   ```bash
   flutter test
   ```
5. Launch the app on your preferred target:
   ```bash
   flutter run
   ```

---

## 📄 Academic Project Report

A complete 16-section vacation project report structured exactly according to the ACE Engineering College format (`Project_Report_Format (during vacation).docx`) is available in the repository root at:
👉 **[`ACE_ENGINEERING_COLLEGE_PROJECT_REPORT.md`](./ACE_ENGINEERING_COLLEGE_PROJECT_REPORT.md)**

---
*Developed by Sriyansh (Roll No: 24AG1A05585), ACE Engineering College, 2026.*
