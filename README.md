# PlayHub App 🎮

A SwiftUI mini-game hub for iOS featuring three fast-paced challenges, personal stat tracking, a session map, and daily challenge reminders.

## Overview

The app — pick a game, beat your high score, and track your progress over time. Each play session is logged with a score, timestamp, and your location at the time, so you can see your game history plotted on a map and browse your stats by mode.

## Games

| Game | Description |
|---|---|
| **Tap Frenzy** | A reflex game — tap the moving button as many times as you can before the clock runs out. |
| **Light It Up** | A memory/reaction game — cards light up briefly and you must tap them before they go dark. Difficulty ramps up across 4 levels (more cards, less time to react). |
| **Quiz Rush** | A trivia challenge powered by the [Open Trivia Database](https://opentdb.com) API — answer multiple-choice questions against the clock. |

## Features

- **Play Hub home screen** — quick access to all three games with high scores displayed at a glance
- **Stats tab** — total games played, best score per game mode, and per-mode session history
- **Map tab** — every completed session is pinned to the location it was played (via MapKit + Core Location)
- **Daily Challenge notifications** — optional local notifications reminding you to come back and beat your best score, with a configurable time
- **Persistent local storage** — scores and session history are saved on-device via `UserDefaults`/`AppStorage`, no account or backend required

## Tech Stack

- **SwiftUI** + **Observation framework** (`@Observable`) for state management
- **MapKit** for the session map
- **Core Location** for tagging sessions with coordinates
- **UserNotifications** for daily challenge reminders
- **Swift Charts** for stats visualizations
- **async/await** networking for the Quiz Rush trivia API
- No third-party dependencies

## Project Structure

```
TapFrenzy/
├── Models/
│   ├── GameMode.swift        # Enum defining the 3 game modes
│   ├── GameSession.swift     # A single recorded play session (score, location, timestamp)
│   └── QuizModel.swift       # Trivia API response models + HTML entity decoding
├── ViewModels/
│   ├── QuizViewModel.swift
│   └── StatsViewModel.swift
├── Views/
│   ├── HomePage/ContentView.swift        # Play Hub home screen
│   ├── TapFrenzy/TapFrenzyView.swift     # Tap Frenzy game
│   ├── LighItUp/LighItUpView.swift       # Light It Up game
│   ├── QuizRush/QuizRushView.swift       # Quiz Rush game
│   ├── Tabs/                             # Home, Stats, Map, Settings tabs
│   ├── GameSessionDetail/                # Detail view for a single session
│   ├── GameModeHistory/                  # History list per game mode
│   └── Shared/                           # Reusable components (ScoreBadge, ResultView, MainTabView)
├── Services/
│   ├── SessionStore.swift        # Persists and queries game sessions
│   ├── LocationService.swift     # Requests/tracks user location
│   ├── NotificationService.swift # Schedules daily challenge notifications
│   └── TriviaService.swift       # Fetches questions from opentdb.com
└── TapFrenzyApp.swift             # App entry point
```

## Requirements

- Xcode 15+
- iOS 17+ (uses the `@Observable` macro from the Observation framework)
- No API keys required — Quiz Rush uses the free, public Open Trivia DB API

## Getting Started

1. Clone the repo:
   ```bash
   git clone <repo-url>
   ```
2. Open `TapFrenzy.xcodeproj` in Xcode.
3. Select a simulator or device and hit **Run**.
4. On first launch, grant location permission to enable the Map tab, and notification permission if you want daily challenge reminders (both are optional — the games work without them).

## Notes

- Quiz Rush requires an internet connection to fetch questions.
- Location and notification permissions are requested at runtime and are not required to play — they only power the Map and Daily Challenge features.

