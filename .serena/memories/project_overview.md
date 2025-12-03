# Sewing Planner - Project Overview

## Purpose
Sewing Planner is an iOS application designed to help users plan and manage their sewing projects. The app allows users to:
- Create and manage sewing projects
- Track project details, materials, and steps
- Store project images with thumbnails
- Mark projects as completed or deleted (soft deletes)
- Share data between app and extensions via shared persistence
- Sync data with a backend server

## Tech Stack

### iOS Application (Swift)
- **Language**: Swift 6.0
- **Framework**: SwiftUI
- **Database**: GRDB.swift (SQLite wrapper) - manages local project data with migrations
- **Architecture**: Observable pattern (@Observable) with Store-based state management
- **Platform**: iOS (iphoneos)
- **Dependencies**:
  - GRDB.swift (master branch from GitHub)
  - swift-log 1.6.4
  - PhotosUI (for image handling)

### Backend Sync Server (Rust)
- **Language**: Rust (2024 edition)
- **Framework**: Actix-web 4.x
- **Database**: PostgreSQL (via diesel-async)
- **Session Store**: SQLite-based custom session store
- **Features**:
  - WebSocket support (actix-ws) for real-time sync
  - Event-based synchronization
  - Authentication with argon2 password hashing
  - CORS support
- **Workspace Structure**: Multi-crate workspace with:
  - `sync_server` (main)
  - `auth_utils`
  - `event_database`
  - `app_db`
  - `sqlite_session_store`
  - `api`

## Project Structure

```
Sewing Planner/
├── Sewing Planner/               # Main iOS app
│   ├── Assets.xcassets/
│   ├── Fonts/                    # Custom fonts (Cooper Hewitt, Source Sans 3)
│   ├── Src/
│   │   ├── AppParentViews/       # App entry point and root views
│   │   ├── AppLibraries/         # Core utilities (Database, Logger, Settings, Files)
│   │   ├── Store/                # State management (Store.swift)
│   │   ├── Project/              # Project-related views and view models
│   │   │   ├── ViewModels/
│   │   │   ├── Images/
│   │   │   ├── Details/
│   │   │   └── Views/
│   │   ├── ProjectsDisplay/      # Projects list view
│   │   ├── Styling/              # App styling and themes
│   │   └── Utils/                # Utility extensions
│   └── TimestampedRecord.swift
├── Sewing PlannerTests/          # UI Tests
├── Sewing PlannerUnitTests/      # Unit Tests
├── ReceiveImage/                 # Share extension for receiving images
├── SharedExtensionFiles/         # Shared code between app and extensions
├── sync_server/                  # Rust backend (ignored in Serena)
└── notes.md                      # Development notes and learnings

```

## Key Features & Patterns

### Database (GRDB)
- Migration-based schema management
- Soft deletes (isDeleted flag)
- Timestamped records (createDate, updateDate)
- Foreign key relationships
- Support for querying, inserting, and updating with type-safe Swift models

### State Management
- Uses `@Observable` for reactive state
- Store pattern for centralized state management
- Environment values for dependency injection

### Syncing Strategy
- **Lazy Syncing**: Triggered when navigating to specific screens
- **Eager Syncing**: Real-time via WebSockets
- Event-based synchronization with versioning
- Soft deletes with time-based full sync fallback

### Share Extension
- Allows receiving images from other apps
- Maintains shared project list via `SharedPersistence`
- Uses App Groups for data sharing

## Development Notes
- Date comparisons require specific granularity due to database accuracy limitations
- List views with string arrays can have focus issues with empty TextFields
- Alert limitations: SwiftUI may only support one alert per view
- Conditional view modifiers can cause animation issues and state loss
- Focus management: Custom implementation needed to dismiss keyboard
