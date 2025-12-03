# Task Completion Checklist

When completing a task in the Sewing Planner project, follow this checklist to ensure quality and consistency.

## Before Committing Code

### 1. Format Code
Run swift-format on modified files:
```bash
swift-format format --in-place --recursive "Sewing Planner/Src"
```

For Rust code in sync_server:
```bash
cd sync_server && cargo fmt
```

### 2. Check for Linting Issues

#### Swift
Run swift-format lint to check for issues:
```bash
swift-format lint --recursive "Sewing Planner/Src"
```

Note: swiftlint is not installed/used in this project.

#### Rust
```bash
cd sync_server && cargo clippy
```

### 3. Build the Project
Ensure the project builds without errors:

#### iOS App
```bash
xcodebuild -project "Sewing Planner.xcodeproj" -scheme "Sewing Planner" -configuration Debug build
```

#### Rust Server
```bash
cd sync_server && cargo build
```

### 4. Run Tests

#### All iOS Tests
```bash
xcodebuild test -project "Sewing Planner.xcodeproj" -scheme "Sewing Planner" -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest'
```

#### Specific Test Suites
Unit tests:
```bash
xcodebuild test -project "Sewing Planner.xcodeproj" -scheme "Sewing Planner" -only-testing:"Sewing PlannerUnitTests" -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest'
```

UI tests:
```bash
xcodebuild test -project "Sewing Planner.xcodeproj" -scheme "Sewing Planner" -only-testing:"Sewing PlannerUITests" -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest'
```

#### Rust Tests
```bash
cd sync_server && cargo test
```

### 5. Review Changes
- Check git diff to review all changes
- Ensure no unintended files are being committed
- Verify debug code and print statements are removed

```bash
git status
git diff
```

### 6. Update Documentation
- Update comments if function signatures or behavior changed
- Add notes to `notes.md` if you discovered important patterns or gotchas
- Update memory files if architectural decisions changed

## Specific Considerations

### Database Changes
If you modified database schema:
- [ ] Added a new migration in `AppDatabase.swift`
- [ ] Tested migration on clean database
- [ ] Tested migration from previous schema version
- [ ] Updated model structs to match new schema
- [ ] Considered impact on sync_server schema if relevant

### UI Changes
If you modified SwiftUI views:
- [ ] Tested on different screen sizes (iPhone SE, iPhone 15, iPad)
- [ ] Verified dark mode appearance
- [ ] Tested with VoiceOver if accessibility is important
- [ ] Avoided conditional view modifiers
- [ ] Ensured proper focus management for TextFields

### State Management
If you modified Store or ViewModels:
- [ ] Verified `@Observable` is used correctly
- [ ] Checked for memory leaks or retain cycles
- [ ] Ensured thread safety for database operations
- [ ] Tested error handling paths

### Share Extension Changes
If you modified SharedExtensionFiles:
- [ ] Tested data sharing between app and extension
- [ ] Verified App Group entitlements are correct
- [ ] Tested on actual device (extensions behave differently)

### Sync Server Changes
If you modified the Rust backend:
- [ ] Updated event versioning if schema changed
- [ ] Tested WebSocket connections
- [ ] Verified authentication flow
- [ ] Checked database migrations in event_database and app_db
- [ ] Updated API documentation if endpoints changed

## Common Pitfalls to Check

- [ ] No force unwraps (`!`) without proper justification
- [ ] Date comparisons use appropriate granularity
- [ ] Soft deletes properly implemented (isDeleted flag)
- [ ] No List views with string arrays for editable TextFields
- [ ] Only one alert per view
- [ ] TextFields are not focused when being deleted from Lists
- [ ] Images are properly resized before storage
- [ ] Navigation state is properly managed

## Git Commit

After all checks pass:
```bash
git add <files>
git commit -m "Brief description of changes"
```

### Commit Message Guidelines
- Use present tense ("Add feature" not "Added feature")
- First line should be concise (50 chars or less)
- Include more details in body if needed
- Reference issue numbers if applicable

## Deployment Considerations

Before releasing:
- [ ] Increment version number in project settings
- [ ] Update build number
- [ ] Test on physical devices
- [ ] Verify all environment variables are set correctly
- [ ] Check App Store metadata is up to date
- [ ] Test sync server deployment configuration
- [ ] Verify SSL certificates and security
