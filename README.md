# GymTracker

A SwiftUI iOS app for tracking gym workouts, built with SwiftData.

## Features

- **Exercise Library** — 50+ built-in exercises categorized by muscle group, with rep-range tagging (strength / hypertrophy / endurance)
- **Custom Exercises** — Create your own exercises with custom muscle group, equipment, and rep-range
- **Workout Templates** — 12 built-in routines: Full Body, Upper/Lower, Push Pull Legs, Bro Split, and Hypertrophy programs. Create and customize your own.
- **Active Workout Logging** — Log sets with reps, weight, RPE, and warmup markers. Navigate between exercises mid-session.
- **Rest Timer** — Configurable countdown timer between sets with haptic feedback
- **History** — Browse past workout sessions with full set-by-set breakdown
- **Progress Charts** — Volume over time, muscle group distribution, personal records, and per-exercise progress graphs using Swift Charts
- **Widget** — Last workout summary on your home screen
- **Live Activity** — Dynamic Island support showing current exercise and progress during an active workout

## Requirements

- iOS 18.0+
- Xcode 16.0+
- Swift 6.0

## Getting Started

1. Open `GymTracker.xcodeproj` in Xcode
2. Select an iOS 18+ simulator or connected device
3. Build and run (⌘R)

The app seeds exercise data and built-in templates automatically on first launch.

## Project Structure

```
GymTracker/
├── App/                  # Entry point and root view
├── Models/               # SwiftData @Model classes
├── Views/
│   ├── Workout/          # Active workout flow
│   ├── Library/          # Exercise browser
│   ├── Templates/        # Routine management
│   ├── History/          # Past sessions
│   ├── Progress/         # Charts and stats
│   ├── Settings/         # App configuration
│   └── Components/       # Reusable UI components
├── Services/             # WorkoutManager, RestTimer, SeedData
├── Extensions/           # Color palette, date formatters
└── Resources/            # exercises.json, asset catalog
```

## Tech Stack

- SwiftUI with programmatic navigation (`NavigationStack`)
- SwiftData for persistence
- Swift Charts for progress visualization
- WidgetKit for home screen widgets
- ActivityKit for Live Activities
- XcodeGen for project generation

## Screenshots

Add screenshots to `Screenshots/` and link them below:

| Feature | Preview |
|---|---|
| Workout | ![Workout](Screenshots/workout.png) |
| Library | ![Library](Screenshots/library.png) |
| Progress | ![Progress](Screenshots/progress.png) |
