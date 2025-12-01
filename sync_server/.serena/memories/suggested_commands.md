# Suggested Commands for Development

## System Information
- **Platform**: Windows
- **Shell**: PowerShell/CMD compatible commands
- **Rust toolchain**: Cargo available at `C:\Users\Lloyd\.cargo\bin\cargo.exe`
- **Diesel CLI**: Available at `C:\Users\Lloyd\.cargo\bin\diesel.exe`

## Building and Running

### Build Commands
```bash
# Build the entire workspace
cargo build

# Build in release mode (optimized)
cargo build --release

# Build a specific workspace member
cargo build -p api
cargo build -p app_db
cargo build -p auth_utils
cargo build -p event_database
cargo build -p sqlite_session_store

# Check code without building
cargo check
```

### Run Commands
```bash
# Run the server (development mode)
cargo run

# Run with release optimizations
cargo run --release

# Run with environment variables
$env:DATABASE_URL="postgres://postgres:postgres@localhost:7777"; cargo run
$env:COOKIE_SECRET_KEY="<base64-encoded-key>"; cargo run
```

## Database Management

### Diesel CLI Commands
```bash
# Run pending migrations (app_db - PostgreSQL)
cd app_db
diesel migration run

# Revert last migration
diesel migration revert

# Redo last migration (revert + run)
diesel migration redo

# Generate new migration
diesel migration generate <migration_name>

# Check migration status
diesel migration list

# Regenerate schema.rs from database
diesel print-schema > src/schema.rs

# Return to root
cd ..
```

### Database Setup
```bash
# Ensure PostgreSQL is running on localhost:7777
# Create database if needed (via psql or pg_admin)

# Run migrations to set up schema
cd app_db
diesel migration run
cd ..

# SQLite session database will be created automatically at ./sessions.db
```

## Testing

### Test Commands
```bash
# Run all tests in workspace
cargo test

# Run tests for specific package
cargo test -p api
cargo test -p event_database

# Run with output shown
cargo test -- --nocapture

# Run specific test
cargo test <test_name>

# Run tests with specific features
cargo test --features <feature_name>
```

## Code Quality

### Formatting
```bash
# Format all code in workspace
cargo fmt

# Check if code is formatted (CI mode)
cargo fmt -- --check

# Format specific package
cargo fmt -p api
```

### Linting
```bash
# Run Clippy linter on workspace
cargo clippy

# Run with all warnings as errors
cargo clippy -- -D warnings

# Run on specific package
cargo clippy -p api

# Fix automatically fixable issues
cargo clippy --fix
```

### Documentation
```bash
# Build documentation for workspace
cargo doc

# Build and open docs in browser
cargo doc --open

# Document private items
cargo doc --document-private-items

# Check for broken documentation links
cargo doc --no-deps
```

## Dependency Management

### Update Dependencies
```bash
# Check for outdated dependencies
cargo outdated

# Update dependencies (respect Cargo.toml constraints)
cargo update

# Update specific dependency
cargo update -p <package_name>
```

### Dependency Tree
```bash
# Show dependency tree
cargo tree

# Show dependencies for specific package
cargo tree -p api

# Show reverse dependencies
cargo tree -i <package_name>
```

## Cleaning

### Clean Build Artifacts
```bash
# Remove target directory
cargo clean

# Remove specific package build artifacts
cargo clean -p api
```

## Useful System Commands (Windows)

### File Operations
```powershell
# List directory contents
dir
Get-ChildItem  # PowerShell equivalent

# Find files
Get-ChildItem -Recurse -Filter "*.rs"

# Search in files
Select-String -Path "src\*.rs" -Pattern "pattern"
findstr /s /i "pattern" *.rs
```

### Process Management
```powershell
# Find process on port 8080
netstat -ano | findstr :8080

# Kill process by PID
taskkill /PID <pid> /F

# List cargo/rust processes
tasklist | findstr cargo
```

### Git Commands
```bash
# Common git operations
git status
git add .
git commit -m "message"
git push
git pull

# View changes
git diff
git log --oneline
```

## Environment Setup

### Required Environment Variables
```powershell
# Set environment variables (PowerShell)
$env:DATABASE_URL = "postgres://postgres:postgres@localhost:7777"
$env:COOKIE_SECRET_KEY = "<base64-encoded-secret>"

# Set permanently (PowerShell - User level)
[System.Environment]::SetEnvironmentVariable("DATABASE_URL", "postgres://postgres:postgres@localhost:7777", "User")

# Or create .env file in project root:
# DATABASE_URL=postgres://postgres:postgres@localhost:7777
# COOKIE_SECRET_KEY=<base64-encoded-secret>
```

### Generate Cookie Secret Key
```powershell
# Generate random base64 key (PowerShell)
$bytes = New-Object byte[] 64
(New-Object Security.Cryptography.RNGCryptoServiceProvider).GetBytes($bytes)
[Convert]::ToBase64String($bytes)
```

## Running the Server

### Prerequisites
1. PostgreSQL running on `localhost:7777`
2. `.env` file configured with required variables
3. Database migrations applied

### Start Server
```bash
# Standard startup
cargo run

# The server will:
# - Load .env file
# - Connect to PostgreSQL at localhost:7777
# - Create/open sessions.db SQLite file
# - Start HTTP server on localhost:8080
# - Run with 1 worker thread
```

### API Endpoints
- `POST http://localhost:8080/signup` - User registration
- `POST http://localhost:8080/login` - User login
- `GET http://localhost:8080/ws` - WebSocket connection (upgrade)