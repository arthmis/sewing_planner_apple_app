# Codebase Structure

## Workspace Organization
This is a Cargo workspace with the following structure:

```
sync_server/
├── Cargo.toml              # Root workspace manifest
├── Cargo.lock              # Dependency lock file
├── sessions.db             # SQLite session database
├── src/
│   └── main.rs            # Main application entry point
├── api/                   # API endpoints and HTTP handlers
│   ├── Cargo.toml
│   └── src/
│       ├── lib.rs         # Signup, login, websocket endpoints
│       ├── db.rs          # Database trait and implementation
│       └── events.rs      # Event deserialization and handling
├── app_db/                # Application database schemas
│   ├── Cargo.toml
│   ├── diesel.toml        # Diesel configuration
│   ├── migrations/        # Database migrations
│   └── src/
│       └── schema.rs      # Generated Diesel schema (users, projects)
├── auth_utils/            # Authentication utilities
│   ├── Cargo.toml
│   └── src/
│       └── lib.rs         # Password hashing and verification
├── event_database/        # Event database operations
│   ├── Cargo.toml
│   └── src/
│       └── lib.rs         # Event database trait and operations
└── sqlite_session_store/  # SQLite-based session storage
    ├── Cargo.toml
    ├── diesel.toml
    └── src/
        └── schema.rs      # Session schema
```

## Workspace Members

### 1. **api** (API Layer)
- **Purpose**: HTTP request handlers and business logic
- **Key exports**: `signup_endpoint`, `login`, `websocket_connection`
- **Dependencies**: auth_utils, app_db, event_database, actix-web, diesel-async
- **Key types**:
  - `Email`: Custom wrapper around EmailAddress with Diesel integration
  - `SignupCredentials`: Signup request payload
  - `UserLogin`: Login request payload
  - `User`: Database user model
  - `UserInput`: Insertable user for database
  - `SignupError`, `LoginError`: Error types with ResponseError implementations

### 2. **app_db** (Application Database)
- **Purpose**: PostgreSQL schema definitions and migrations
- **Tables**:
  - `users`: id, email, password_hash, created_at, updated_at
  - `projects`: id, user_id, project_id, title, completed, created_at, updated_at
- **Migrations**: Located in `app_db/migrations/`
- **Diesel CLI**: Configured to generate schema at `src/schema.rs`

### 3. **auth_utils** (Authentication Utilities)
- **Purpose**: Password hashing and verification
- **Key functions**:
  - `generate_password_hash(password: &str) -> Result<String, GenerateHashError>`: Uses Argon2
  - `compare_passwords(password: &str, password_hash: &str) -> PasswordVerify`
- **Security**: Uses Argon2 with random salt generation (OsRng)

### 4. **event_database** (Event Storage)
- **Purpose**: Handle event-based synchronization operations
- **Dependencies**: diesel-async, app_db
- **Key trait**: `EventDatabase` (likely defining event storage operations)

### 5. **sqlite_session_store** (Session Management)
- **Purpose**: SQLite-based session storage implementation
- **Database**: Local SQLite file (sessions.db)
- **Features**: Automatic expired session cleanup

## Main Application (src/main.rs)

### Initialization Flow
1. Load environment variables from `.env` file
2. Decode Base64-encoded cookie secret key
3. Initialize SQLite session store
4. Spawn background task for session cleanup (runs every 100 seconds)
5. Create PostgreSQL connection pool (max 10 connections)
6. Start HTTP server with configured middleware

### Middleware Stack
1. SessionMiddleware (SQLite-backed, 24-hour session TTL)
2. CORS (permissive on Windows, default on Linux)

### Routes
- `POST /signup` → `api::signup_endpoint`
- `POST /login` → `api::login`
- `GET /ws` → `api::websocket_connection` (WebSocket upgrade)

## Database Setup
- **PostgreSQL**: Primary application database (users, projects)
- **SQLite**: Session storage (local file)
- **Migrations**: Managed by Diesel CLI (use `diesel migration run`)
- **Connection Pooling**: Deadpool-based async pool with 10 max connections