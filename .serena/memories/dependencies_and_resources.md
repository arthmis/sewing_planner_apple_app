# Dependencies and External Resources

## iOS App Dependencies

### Swift Package Manager

The project uses Swift Package Manager (SPM) for dependency management. Dependencies are resolved in:
- `Sewing Planner.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved`

### Primary Dependencies

#### GRDB.swift
- **Repository**: https://github.com/groue/GRDB.swift.git
- **Version**: master branch (commit: 3ecb5c5)
- **Purpose**: SQLite database toolkit for Swift
- **Features Used**:
  - Database migrations
  - Type-safe queries
  - Record protocols (Codable, FetchableRecord, PersistableRecord)
  - Transactions
  - Indexing
  - Foreign keys
- **Documentation**: https://github.com/groue/GRDB.swift/blob/master/README.md

#### swift-log
- **Repository**: https://github.com/apple/swift-log
- **Version**: 1.6.4
- **Purpose**: Logging API for Swift
- **Usage**: `AppLogger` wrapper for application-wide logging
- **Documentation**: https://github.com/apple/swift-log/blob/main/README.md

### Apple Frameworks

#### SwiftUI
- **Purpose**: UI framework
- **Version**: Swift 6.0 / iOS SDK
- **Key Features Used**:
  - Declarative UI
  - State management (@State, @Binding, @Environment)
  - Navigation
  - Lists and Forms

#### PhotosUI
- **Purpose**: Photo picker and management
- **Usage**: Image selection for projects

#### GRDB (as mentioned above)

### Development Tools

#### swift-format
- **Location**: `/usr/local/bin/swift-format`
- **Purpose**: Code formatting and linting
- **Installation**: `brew install swift-format`
- **Configuration**: `.swift-format` file in project root
- **Settings**:
  ```json
  {
    "lineBreakBeforeEachArgument": true,
    "indentSwitchCaseLabels": true
  }
  ```

#### Xcode
- **Version**: Latest (supporting Swift 6.0)
- **Build System**: xcodebuild
- **Required for**: Building, testing, debugging iOS app

## Rust Backend Dependencies

### Cargo Workspace

The sync_server uses a Cargo workspace with multiple crates. Main dependencies are defined in `sync_server/Cargo.toml`.

### Web Framework

#### actix-web
- **Version**: 4.x
- **Purpose**: HTTP web framework
- **Features**: Async, middleware support, routing
- **Documentation**: https://actix.rs/docs/

#### actix-ws
- **Version**: 0.3.0
- **Purpose**: WebSocket support for actix-web
- **Usage**: Real-time sync events

#### actix-session
- **Version**: 0.11.0
- **Purpose**: Session management middleware
- **Usage**: User session tracking

#### actix-cors
- **Version**: 0.7.1
- **Purpose**: CORS middleware
- **Usage**: Cross-origin API access

### Database

#### diesel
- **Version**: 2.2.0
- **Features**: postgres_backend, chrono
- **Purpose**: ORM and query builder
- **Documentation**: https://diesel.rs/

#### diesel-async
- **Version**: 0.7.0
- **Features**: postgres, pool, deadpool
- **Purpose**: Async database operations
- **Pool**: deadpool for connection pooling

### Serialization

#### serde
- **Version**: 1.0.228
- **Purpose**: Serialization framework
- **Usage**: JSON serialization for API

#### serde_json
- **Version**: 1.0.145
- **Purpose**: JSON support for serde
- **Usage**: API request/response handling

### Utilities

#### anyhow
- **Version**: 1.0.100
- **Purpose**: Flexible error handling
- **Usage**: Application-level error handling

#### snafu
- **Version**: 0.8.9
- **Features**: rust_1_81, alloc
- **Purpose**: Error type creation
- **Usage**: Library-level custom errors

#### chrono
- **Version**: 0.4
- **Features**: serde
- **Purpose**: Date and time handling
- **Usage**: Timestamps for records

#### uuid
- **Version**: 1.x
- **Features**: v4
- **Purpose**: UUID generation
- **Usage**: Unique identifiers

#### async-lock
- **Version**: 3.4.1
- **Purpose**: Async synchronization primitives
- **Usage**: Concurrent access control

#### futures-util
- **Version**: 0.3.31
- **Purpose**: Async utilities
- **Usage**: Stream handling, async helpers

### Security

#### argon2
- **Version**: 0.5.3
- **Features**: std
- **Purpose**: Password hashing
- **Usage**: Secure password storage

#### base64
- **Version**: 0.22.1
- **Purpose**: Base64 encoding/decoding
- **Usage**: Cookie secret key encoding

### Other

#### email_address
- **Version**: 0.2.9
- **Purpose**: Email validation
- **Usage**: User email validation

#### dotenvy
- **Version**: 0.15.7
- **Purpose**: .env file loading
- **Usage**: Environment configuration

#### mimalloc
- **Version**: 0.1
- **Purpose**: High-performance allocator
- **Usage**: Global allocator for better performance

## Database Systems

### SQLite (iOS App)
- **Purpose**: Local data storage
- **Library**: GRDB.swift
- **Location**: App documents directory
- **Features**: 
  - ACID compliance
  - Full-text search (if needed)
  - Migrations

### PostgreSQL (Sync Server)
- **Purpose**: Server-side data storage
- **Library**: diesel-async
- **Features**:
  - ACID compliance
  - Advanced querying
  - Concurrent access
  - Event storage
  - Application data

### SQLite (Session Store)
- **Purpose**: Server session storage
- **Library**: Custom implementation (sqlite_session_store)
- **Features**:
  - Persistent sessions
  - Automatic expiration cleanup

## External Services & APIs

### Potential Cloud Services
(Based on project structure, though not explicitly configured in current files)
- iCloud (for app data backup)
- CloudKit (for sync between user's devices)
- Push notifications (for sync updates)

## Development Environment

### Required Software

#### macOS
- **OS**: macOS (Darwin)
- **Required**: Xcode Command Line Tools

#### Swift Development
- Swift 6.0 or later
- Xcode (latest version supporting Swift 6.0)
- swift-format (`brew install swift-format`)

#### Rust Development
- Rust toolchain (install via rustup)
- cargo (comes with Rust)
- Optional: cargo-watch (`cargo install cargo-watch`)

#### Database
- PostgreSQL server (for backend development)
- psql client (optional, for database management)

### Optional Tools

#### Development Utilities
- Git (version control)
- Bruno API client (for API testing, .bru files in gitignore)
- Zed editor (buildServer.json for integration)

#### Debugging
- Xcode Instruments (performance profiling)
- Accessibility Inspector (UI testing)
- lldb (Xcode integrated debugger)

## Environment Variables

### Backend (.env file)
Required environment variables for sync_server:

```bash
DATABASE_URL=postgres://postgres:postgres@localhost:7777
COOKIE_SECRET_KEY=<base64-encoded-secret>
# Other configuration as needed
```

### iOS App
- Uses UserDefaults for app settings
- App Groups for extension sharing
- Info.plist for app configuration

## Font Resources

### Custom Fonts (included in project)
Located in `Sewing Planner/Fonts/`:
- **Cooper Hewitt**: Book, Medium, Semibold (.otf files)
- **Source Sans 3**: Regular, Bold (.ttf files)

Registered in `Sewing-Planner-Info.plist` under `UIAppFonts`

### Potential Alternative Fonts (from notes)
- Roboto
- Montserrat
- Josefin

## Learning Resources

### Official Documentation
- **Swift**: https://swift.org/documentation/
- **SwiftUI**: https://developer.apple.com/documentation/swiftui
- **GRDB**: https://github.com/groue/GRDB.swift
- **Actix**: https://actix.rs/
- **Diesel**: https://diesel.rs/
- **Rust**: https://doc.rust-lang.org/

### Referenced in notes.md
- Hacking with Swift tutorials (various lessons referenced)
- Stack Overflow solutions for specific problems
- GitHub issues and discussions

## Version Requirements

### Minimum Versions
- **Swift**: 6.0
- **iOS**: Target specified in Xcode project (likely iOS 15+)
- **Rust**: Edition 2024
- **Xcode**: Version supporting Swift 6.0

### Compatibility Notes
- The project uses Swift 6.0 concurrency features
- Rust edition 2024 may require recent Rust version
- Some dependencies specify minimum Rust version (1.81+)

## Package Management Commands

### Swift Package Manager
```bash
# Update dependencies
xcodebuild -resolvePackageDependencies

# Reset packages
rm -rf ~/Library/Developer/Xcode/DerivedData
```

### Cargo
```bash
# Update dependencies
cargo update

# Add new dependency
cargo add <package>

# Check for outdated dependencies
cargo outdated  # requires cargo-outdated plugin
```
