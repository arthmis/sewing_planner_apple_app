# Architecture and Design Patterns

## Overall Architecture

The Sewing Planner project follows a client-server architecture with an iOS app and Rust backend.

### High-Level Components

```
┌─────────────────────────────────────┐
│       iOS App (SwiftUI)             │
│  ┌───────────────────────────────┐  │
│  │  Views (SwiftUI Components)   │  │
│  └─────────────┬─────────────────┘  │
│                │                     │
│  ┌─────────────▼─────────────────┐  │
│  │  ViewModels (@Observable)     │  │
│  └─────────────┬─────────────────┘  │
│                │                     │
│  ┌─────────────▼─────────────────┐  │
│  │   Store (State Management)    │  │
│  └─────────────┬─────────────────┘  │
│                │                     │
│  ┌─────────────▼─────────────────┐  │
│  │  AppDatabase (GRDB/SQLite)    │  │
│  └───────────────────────────────┘  │
└────────────────┬────────────────────┘
                 │
                 │ Sync Events
                 │ (WebSocket/HTTP)
                 │
┌────────────────▼────────────────────┐
│     Rust Sync Server (Actix)        │
│  ┌───────────────────────────────┐  │
│  │    API Endpoints & WebSocket  │  │
│  └─────────────┬─────────────────┘  │
│                │                     │
│  ┌─────────────▼─────────────────┐  │
│  │  Event Database (Postgres)    │  │
│  │  App Database (Postgres)      │  │
│  │  Session Store (SQLite)       │  │
│  └───────────────────────────────┘  │
└─────────────────────────────────────┘
```

## iOS App Architecture

### MVVM Pattern with Observable

The app uses a modern SwiftUI architecture with the Observable macro:

#### Views (V)
- Pure SwiftUI components
- Minimal logic, delegate to ViewModels
- Use environment values for dependency injection
- Examples: `ProjectsView`, `ImagesView`, `ItemView`

#### ViewModels (VM)
- Marked with `@Observable` for reactive updates
- Contain business logic and state
- Communicate with Store or Database
- Examples: `ProjectViewModel`, `ProjectsViewModel`, `ImageViewModel`

#### Models (M)
- Data structures conforming to GRDB protocols
- Examples: `ProjectMetadata`, `ProjectImage`, `SectionModel`

### State Management with Store

The `Store` class is the central state container:

```swift
@Observable
class Store {
  var projects: ProjectsViewModel
  var navigation: [ProjectMetadata] = []
  var selectedProject: ProjectViewModel?
  var appError: AppError?
  let db: AppDatabase
}
```

**Responsibilities:**
- Centralized app state
- Coordinates between ViewModels
- Manages navigation state
- Handles global errors
- Provides database access

### Dependency Injection via Environment

Uses SwiftUI's Environment system:

```swift
extension EnvironmentValues {
  @Entry var db = AppDatabase.db
  @Entry var appLogger = AppLogger(label: "app logger")
}

// Custom environment value
extension EnvironmentValues {
  var settings: UserSettings {
    get { self[SettingsKey.self] }
    set { self[SettingsKey.self] = newValue }
  }
}
```

**Pattern Benefits:**
- Testable (can inject mock dependencies)
- Loosely coupled components
- Easy to access throughout view hierarchy

### Database Layer (GRDB)

#### AppDatabase Wrapper
Encapsulates all database operations:
- Migration management
- Read/write access control
- Type-safe queries
- Transaction support

#### Repository Pattern
Database operations are methods on `AppDatabase`:
```swift
func addProject(project: inout ProjectMetadataInput) throws -> ProjectMetadata
func getWriter() -> any DatabaseWriter
```

#### Migration Strategy
Sequential migrations with named versions:
```swift
migrator.registerMigration("projects") { db in
  // Create tables
}
migrator.registerMigration("add_column_x") { db in
  // Alter tables
}
```

### Share Extension Architecture

**Problem**: Need to share data between main app and share extension

**Solution**: 
- App Groups for shared container
- `SharedPersistence` class for file-based sharing
- JSON encoding of shared data structures
- Separate targets with shared code in `SharedExtensionFiles/`

## Synchronization Architecture

### Event-Based Sync

The sync strategy uses an event-driven approach:

#### Lazy Sync
- Triggered on navigation to specific screens
- Checks if data needs syncing
- May perform full table sync if needed
- Resumable for large data transfers (especially images)

#### Eager Sync (WebSocket)
- Real-time bidirectional communication
- Client pushes events to server
- Server updates database and broadcasts to other clients
- Events stored persistently for replay
- Acknowledgment-based reliability

### Versioning Strategy

**Problem**: Multiple devices with different app versions

**Solution**:
- Each event includes database schema version
- Clients ignore events from newer schema versions
- Server maintains backwards compatibility
- Soft deprecation of old columns/tables

### Conflict Resolution
- Timestamps on all records (createDate, updateDate)
- Soft deletes with time-based garbage collection
- Last-write-wins for most operations
- Full sync fallback for edge cases

## Rust Backend Architecture

### Workspace Organization

Multi-crate workspace for modularity:
- `sync_server`: Main binary, HTTP server setup
- `api`: API endpoint definitions
- `app_db`: Application database models (Diesel)
- `event_database`: Event storage and replay
- `auth_utils`: Authentication and session management
- `sqlite_session_store`: Custom session store implementation

### Actix-Web Structure

**Middleware Stack**:
1. CORS (actix-cors)
2. Session management (actix-session)
3. Request routing
4. WebSocket upgrade handling

**Async Design**:
- Uses Tokio runtime via actix-web
- Diesel-async for non-blocking database operations
- Connection pooling with deadpool

### Session Management

Custom SQLite-based session store:
- Persistent sessions across server restarts
- Background cleanup task for expired sessions
- Cookie-based with secret key encryption

## Design Patterns Used

### Event-Driven State Management (ProjectViewModel)
The `ProjectViewModel` uses an event-driven architecture for handling state updates and side effects:

**Event Pattern:**
```swift
enum ProjectEvent {
  case UpdatedProjectTitle(String)
  case UpdateSectionName(section: SectionRecord, oldName: String)
  case markSectionForDeletion(SectionRecord)
  case RemoveSection(Int64)
  case ProjectError(ProjectError)
}
```

**Effect Pattern:**
```swift
enum Effect: Equatable {
  case deleteSection(section: SectionRecord)
  case updateProjectTitle(projectData: ProjectMetadata)
  case updateSectionName(section: SectionRecord, oldName: String)
  case doNothing
}
```

**Flow:**
1. **Views call `project.send(event:db:)`** - Initiates state change
2. **`handleEvent(_ event:)`** - Updates local state optimistically, returns Effect
3. **`handleEffect(effect:db:)`** - Performs async database operations
4. **Error handling** - On failure, sends ProjectError event to rollback state

**Benefits:**
- Optimistic UI updates (immediate feedback)
- Centralized state management
- Testable business logic
- Clear separation of sync/async operations
- Automatic error handling and rollback

**Example Usage:**
```swift
// In SectionView.swift
project.send(
  event: .UpdateSectionName(section: section, oldName: model.section.name),
  db: db
)

// ProjectViewModel handles the state update and database sync
```

### Observable Pattern
Swift's `@Observable` macro for reactive state updates in ViewModels and Store.

### Repository Pattern
`AppDatabase` acts as repository, abstracting database access from business logic.

### Dependency Injection
Environment values provide dependencies to views without tight coupling.

### Event Sourcing (Partial)
Sync events are stored persistently and can be replayed, though not full event sourcing.

### Soft Delete Pattern
Records marked as deleted rather than removed, allowing sync and recovery.

### Factory Pattern
`AppDatabase.db` singleton instance for thread-safe database access (GRDB handles concurrency internally).

### Extension Pattern
Swift extensions add functionality to types without modifying original definitions.

## Testing Strategies

### Unit Testing
- Test ViewModels in isolation
- Mock database for deterministic tests
- Test business logic without UI

### UI Testing
- Full integration tests with UI interactions
- Use accessibility identifiers
- Test user flows end-to-end

### Testing Utilities
Located in `Sewing PlannerUnitTests/`:
- `TestEffects.swift`: Test helpers
- `DatabaseTest.swift`: Database testing utilities
- `AppSettingsTest.swift`: Settings testing

## Security Considerations

### iOS App
- Sandboxed file access
- Entitlements for camera/photo library
- App Groups for controlled data sharing
- UserDefaults for non-sensitive settings

### Backend
- Argon2 password hashing
- Session-based authentication
- HTTPS/TLS in production (implied)
- Environment variables for secrets (.env files)
- CORS configuration for API access

## Performance Optimizations

### iOS
- Lazy loading in navigation (see notes.md)
- Virtual scrolling with LazyHStack/LazyVStack
- Image thumbnails for list views
- GRDB indexed columns for fast queries

### Backend
- MiMalloc allocator for Rust (faster than system allocator)
- Database connection pooling
- Async I/O throughout
- WebSocket for efficient real-time updates

## Known Limitations & Trade-offs

1. **SwiftUI Alert Limitation**: Only one alert per view (workaround needed for multiple alerts)
2. **Soft Delete TTL**: Old soft deletes require full sync
3. **Backwards Compatibility**: Server must maintain old schemas
4. **Focus Management**: Custom implementation needed for proper keyboard dismissal
5. **Date Precision**: Database date accuracy limitations affect comparisons
