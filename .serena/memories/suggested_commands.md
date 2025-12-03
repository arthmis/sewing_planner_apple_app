# Suggested Commands for Sewing Planner

## Build Commands

### Build the iOS App
```bash
xcodebuild -project "Sewing Planner.xcodeproj" -scheme "Sewing Planner" -configuration Debug build
```

### Build for Release
```bash
xcodebuild -project "Sewing Planner.xcodeproj" -scheme "Sewing Planner" -configuration Release build
```

### Clean Build
```bash
xcodebuild -project "Sewing Planner.xcodeproj" -scheme "Sewing Planner" clean
```

## Testing Commands

### Run All Tests
```bash
xcodebuild test -project "Sewing Planner.xcodeproj" -scheme "Sewing Planner" -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest'
```

### Run Unit Tests Only
```bash
xcodebuild test -project "Sewing Planner.xcodeproj" -scheme "Sewing Planner" -only-testing:"Sewing PlannerUnitTests" -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest'
```

### Run UI Tests Only
```bash
xcodebuild test -project "Sewing Planner.xcodeproj" -scheme "Sewing Planner" -only-testing:"Sewing PlannerUITests" -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest'
```

### Run Tests with Test Plan
```bash
xcodebuild test -project "Sewing Planner.xcodeproj" -scheme "Sewing Planner" -testPlan "Sewing Planner" -destination 'platform=iOS Simulator,name=iPhone 15,OS=latest'
```

## Formatting Commands

### Format Swift Code
```bash
swift-format format --in-place --recursive "Sewing Planner/Src"
```

### Format Specific File
```bash
swift-format format --in-place "path/to/file.swift"
```

### Check Format (without making changes)
```bash
swift-format lint --recursive "Sewing Planner/Src"
```

## Rust Backend Commands (sync_server)

### Build Rust Server
```bash
cd sync_server && cargo build
```

### Build for Release
```bash
cd sync_server && cargo build --release
```

### Run Rust Server
```bash
cd sync_server && cargo run
```

### Run Rust Tests
```bash
cd sync_server && cargo test
```

### Check Rust Code
```bash
cd sync_server && cargo check
```

### Format Rust Code
```bash
cd sync_server && cargo fmt
```

### Lint Rust Code
```bash
cd sync_server && cargo clippy
```

## macOS System Utilities

### File System Navigation
```bash
ls -la          # List files with details
cd <path>       # Change directory
pwd             # Print working directory
find . -name "*.swift"  # Find Swift files
```

### Search and Grep
```bash
grep -r "pattern" .     # Search recursively
grep -i "pattern" file  # Case-insensitive search
```

### Git Commands
```bash
git status              # Check status
git add .               # Stage all changes
git commit -m "msg"     # Commit changes
git push                # Push to remote
git pull                # Pull from remote
git log                 # View commit history
```

## Xcode Commands

### List Schemes and Targets
```bash
xcodebuild -list -project "Sewing Planner.xcodeproj"
```

### Show Build Settings
```bash
xcodebuild -showBuildSettings -project "Sewing Planner.xcodeproj" -scheme "Sewing Planner"
```

## Environment Setup

### Install swift-format (if not installed)
```bash
brew install swift-format
```

### Install Rust (if not installed)
```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
```

## Notes
- The system is macOS (Darwin), so standard Unix commands apply
- swift-format is installed at: `/usr/local/bin/swift-format`
- The sync_server directory is ignored in Serena configuration but contains a full Rust workspace
- Test runs include the `--test` command line argument (see Sewing Planner.xctestplan)
