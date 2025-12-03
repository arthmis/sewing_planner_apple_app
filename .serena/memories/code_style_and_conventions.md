# Code Style and Conventions

## Swift Code Style

### Formatting Tool
- **Tool**: swift-format (installed at `/usr/local/bin/swift-format`)
- **Configuration File**: `.swift-format` in project root

### swift-format Configuration
```json
{
    "lineBreakBeforeEachArgument": true,
    "indentSwitchCaseLabels": true
}
```

### Key Conventions

#### Naming Conventions
- **Files**: PascalCase with descriptive names (e.g., `Sewing_PlannerApp.swift`, `AppDatabase.swift`)
- **Classes/Structs**: PascalCase (e.g., `Store`, `AppDatabase`, `ProjectMetadata`)
- **Functions/Methods**: camelCase (e.g., `addProject()`, `getWriter()`)
- **Variables**: camelCase (e.g., `selectedProject`, `appError`)
- **Constants**: camelCase for regular constants, UPPER_SNAKE_CASE for UserDefaults keys (e.g., `UserCreatedOneProject`)

#### File Headers
All Swift files include a standard header:
```swift
//
//  FileName.swift
//  Sewing Planner
//
//  Created by Art on MM/DD/YY.
//
```

#### Type Annotations
- Use explicit type annotations when it improves clarity
- Let type inference work for obvious cases
- Example: `var projects: ProjectsViewModel`

#### Observable Pattern
- Use `@Observable` macro for classes that need reactive state
- Use `@State` for local SwiftUI view state
- Use `@Environment` for dependency injection
- Use `@Binding` for two-way data binding in custom views

Example:
```swift
@Observable
class Store {
  var projects: ProjectsViewModel
  var navigation: [ProjectMetadata] = []
  var selectedProject: ProjectViewModel?
}
```

#### Error Handling
- Use typed throws with custom error types: `throws(AppError)`
- Prefer do-catch blocks for database operations
- Store errors in observable state for UI display

Example:
```swift
func addProject() throws(AppError) {
  do {
    try db.getWriter().write { db in
      // database operations
    }
  } catch {
    throw AppError.addProject
  }
}
```

#### SwiftUI Views
- Keep view logic clean and delegate to ViewModels
- Use environment values for shared dependencies
- Avoid conditional view modifiers (causes animation issues)

#### Comments
- Use `//` for single-line comments
- Document complex logic and edge cases
- Include `TODO:` comments for future work
- Reference issue numbers or notes.md sections when relevant

### Database Conventions (GRDB)

#### Model Definitions
- Use `Codable`, `FetchableRecord`, `PersistableRecord` protocols
- Include timestamps: `createDate`, `updateDate`
- Soft deletes: Use `isDeleted: Bool` field
- Primary keys: Auto-incrementing integers named `id`

#### Migrations
- Use DatabaseMigrator with named migrations
- Create tables with `.ifNotExists` option
- Index frequently queried columns
- Use foreign keys with `belongsTo`

Example:
```swift
migrator.registerMigration("projects") { db in
  try db.create(table: "project", options: [.ifNotExists]) { table in
    table.autoIncrementedPrimaryKey("id")
    table.column("name", .text).notNull().indexed()
    table.column("completed", .boolean).notNull().indexed()
    table.column("isDeleted", .boolean).notNull()
    table.column("createDate", .datetime).notNull()
    table.column("updateDate", .datetime).notNull()
  }
}
```

### Typography & Fonts
Custom fonts are used:
- Cooper Hewitt (Book, Medium, Semibold)
- Source Sans 3 (Regular, Bold)

Potential alternatives mentioned in notes: Roboto, Montserrat, Josefin

## Rust Code Style (sync_server)

### Formatting
- Use `cargo fmt` for automatic formatting
- Follow standard Rust conventions

### Naming
- Modules: snake_case
- Structs/Enums: PascalCase
- Functions/Variables: snake_case
- Constants: UPPER_SNAKE_CASE

### Patterns
- Use workspace organization for related crates
- Async/await with actix-web and diesel-async
- Error handling with `anyhow` and `snafu`
- Dependency management via workspace.dependencies

## Testing Conventions

### Unit Tests
- Located in `Sewing PlannerUnitTests/`
- Use XCTest framework and Testing framework
- Mock dependencies when possible
- Test database operations with in-memory or test databases

### UI Tests
- Located in `Sewing PlannerUITests/`
- Use XCTest UI testing framework
- Can record tests using Xcode's UI test recorder
- Use Accessibility Inspector for debugging

### Test Organization
- `setUp()` for initialization
- `tearDown()` for cleanup
- Descriptive test names: `testFunctionName()`
- Group related tests in the same test class

## Git Conventions

### Ignored Files (from .gitignore)
- Xcode build artifacts and user data
- Rust target/ directory
- Database files (*.db)
- Environment files (*.env)
- Bruno API client files (bruno.json, *.bru)
- Build server integration (buildServer.json)

## Important Notes and Gotchas

### SwiftUI Warnings
1. **List Focus Issues**: Don't mix list views with empty string arrays as backing data in editable text fields
2. **Alert Limitations**: May only support one alert per view
3. **Conditional View Modifiers**: Avoid them - they cause bad animations and state loss
4. **Delete Crashes**: Deleting a focused TextField in a List can crash - ensure TextField is not focused before deletion

### Database Considerations
1. **Date Comparisons**: Compare dates with specific granularity due to accuracy limitations
2. **Soft Deletes**: Use time-based full sync fallback for old soft deletes
3. **Versioning**: Events include database version to handle schema migrations across devices

### Debugging Tools
- UI Test Recorder (red circle button in test)
- Accessibility Inspector (Xcode > Open Developer Tool)
- Breakpoints with `po` commands in lldb console
