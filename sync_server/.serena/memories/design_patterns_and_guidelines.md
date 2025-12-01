# Design Patterns and Guidelines

## Architectural Patterns

### Workspace Architecture
The project follows a **modular workspace pattern** where functionality is separated into focused, reusable crates:
- **api**: HTTP layer (handlers, routing, validation)
- **app_db**: Database schema and migrations
- **auth_utils**: Authentication utilities
- **event_database**: Event storage abstraction
- **sqlite_session_store**: Session management
- **sync_server (root)**: Application composition and startup

**Benefits**:
- Clear separation of concerns
- Reusable components
- Easier testing (can test crates independently)
- Parallel compilation

### Repository Pattern
Database operations use a **trait-based repository pattern**:

```rust
pub trait Database {
    async fn create_user(&mut self, user: UserInput) -> Result<(), Error>;
    // other methods...
}

// Implementation for production
struct DB<'a> { conn: &'a mut AsyncPgConnection }

// Mock implementation for tests
struct MockDB { /* test data */ }
```

**Benefits**:
- Testability (can inject mock implementations)
- Abstraction over database details
- Easy to swap implementations

### Error Handling Pattern
Uses **SNAFU for structured error handling**:

```rust
#[derive(Debug, Snafu)]
pub enum SignupError {
    #[snafu(display("Invalid email"))]
    InvalidEmail {
        #[snafu(implicit)]
        location: Location,
        source: email_address::Error,
    },
}

// Usage with context
let email = EmailAddress::parse(&value)
    .context(InvalidEmailSnafu {})?;
```

**Benefits**:
- Automatic error conversion
- Location tracking for debugging
- Rich error context
- Type-safe error handling

### Type Wrapper Pattern
Custom types wrapped for domain validation:

```rust
pub struct Email(EmailAddress);

impl Email {
    pub fn new(email: &str) -> Result<Self, Error> {
        EmailAddress::parse_with_options(email, Options::default())
            .map(Email)
    }
}
```

**Benefits**:
- Type safety (can't mix raw strings with validated emails)
- Validation at construction
- Clear domain semantics
- Integration with Diesel (FromSql/ToSql)

## Actix-web Patterns

### Extractor Pattern
Request data extracted with type-safe extractors:

```rust
async fn handler(
    db_pool: web::Data<DbPool>,           // Shared state
    web::Json(data): web::Json<Input>,    // JSON body
    session: Session,                     // Session data
    request: HttpRequest,                 // Raw request
) -> Result<Response, Error>
```

**Best Practices**:
- Use `web::Data` for shared state (Arc-wrapped automatically)
- Validate JSON with strongly-typed structs
- Extract only what you need

### Middleware Composition
Middleware applied in order:

```rust
App::new()
    .wrap(SessionMiddleware::builder(...).build())
    .wrap(cors)
    .app_data(web::Data::new(pool))
    .service(api::signup_endpoint)
```

**Order matters**:
1. Session middleware (for authentication)
2. CORS (for cross-origin requests)
3. Then routes and services

### Error Response Pattern
Implement `ResponseError` for custom errors:

```rust
impl ResponseError for SignupError {
    fn status_code(&self) -> StatusCode {
        match self {
            SignupError::InvalidEmail { .. } => StatusCode::BAD_REQUEST,
            SignupError::CreateUserFailed { .. } => StatusCode::INTERNAL_SERVER_ERROR,
        }
    }

    fn error_response(&self) -> HttpResponse {
        HttpResponseBuilder::new(self.status_code())
            .insert_header((header::CONTENT_TYPE, mime::TEXT_PLAIN_UTF_8))
            .body(self.to_string())
    }
}
```

**Benefits**:
- Consistent error responses
- Automatic status code mapping
- Clean handler code (just return errors)

## Async Patterns

### Async/Await Best Practices
```rust
// ✅ Good: Await database operations
let user = get_user(&email, &mut conn).await?;

// ✅ Good: Spawn background tasks
actix_web::rt::spawn(async move {
    loop {
        cleanup_sessions().await;
        actix_web::rt::time::sleep(Duration::from_secs(100)).await;
    }
});

// ❌ Bad: Blocking operation in async context
// std::thread::sleep(Duration::from_secs(100));
```

### Connection Pool Pattern
```rust
// Get connection from pool
let mut conn = db_pool.get().await.unwrap();

// Pass mutable reference to avoid cloning
process_data(&mut conn).await?;
```

**Important**:
- Get connections only when needed
- Release connections quickly (drop after use)
- Use connection pooling for concurrent requests

## WebSocket Patterns

### WebSocket Handler Pattern
```rust
pub async fn websocket_connection(
    request: HttpRequest,
    stream: web::Payload,
) -> Result<HttpResponse, Error> {
    // Upgrade connection
    let (res, mut ws_session, stream) = actix_ws::handle(&request, stream)?;
    
    // Spawn handler task
    actix_web::rt::spawn(async move {
        while let Some(msg) = stream.next().await {
            // Handle messages
        }
    });
    
    // Return response immediately
    Ok(res)
}
```

**Key Points**:
- Upgrade happens synchronously
- Message handling in separate task
- Response returned immediately
- Long-lived connection managed in background

### Message Aggregation
```rust
let mut stream = stream
    .aggregate_continuations()
    .max_continuation_size(2_usize.pow(20)); // 1MiB
```

**Purpose**: Handle fragmented WebSocket messages up to size limit

## Diesel Patterns

### Type-Safe Queries
```rust
// ✅ Preferred: Query builder
use app_db::schema::users::dsl::*;

users
    .filter(email.eq(user_email))
    .select(User::as_select())
    .first(conn)
    .await?
```

### Separate Insert/Query Types
```rust
// For inserting
#[derive(Insertable)]
struct UserInput { ... }

// For querying
#[derive(Queryable, Selectable)]
struct User { ... }
```

**Rationale**:
- Insert types may not have IDs or timestamps
- Query types always have all fields
- Clear intent in code

### Custom SQL Types
```rust
#[derive(AsExpression, FromSqlRow)]
#[diesel(sql_type = Text)]
pub struct Email(EmailAddress);

impl FromSql<Text, Pg> for Email { ... }
impl ToSql<Text, Pg> for Email { ... }
```

**Use cases**:
- Domain types (Email, PhoneNumber)
- Validation on deserialization
- Type safety in queries

## Security Patterns

### Password Handling
```rust
// ✅ Good: Hash passwords before storage
let hash = auth_utils::generate_password_hash(&password)?;

// ✅ Good: Constant-time comparison
let result = auth_utils::compare_passwords(&input, &stored_hash);

// ❌ Bad: Never store plain text passwords
// let password = credentials.password;
```

### Session Management
```rust
// Store minimal data in session
session.insert("user_id", user.id)?;

// Don't store sensitive data
// ❌ session.insert("password", ...);
// ❌ session.insert("password_hash", ...);
```

### Input Validation
```rust
// Validate at entry points
let credentials = UserCredentials::try_from(raw_input)?;

// Use validated types throughout
async fn create_user(email: Email, ...) { ... }
```

## Testing Patterns

### Trait-Based Mocking
```rust
// Production code uses trait
async fn create_user(db: impl Database) -> Result<(), Error> {
    db.create_user(user).await?;
}

// Tests use mock implementation
#[tokio::test]
async fn test_create_user() {
    let mut mock_db = MockDatabase::new();
    create_user(&mut mock_db).await.unwrap();
}
```

### Test Containers (Integration Tests)
```rust
#[cfg(test)]
mod tests {
    use testcontainers_modules::postgres::Postgres;
    
    #[tokio::test]
    async fn test_with_real_db() {
        let container = Postgres::default();
        // Use real PostgreSQL for integration tests
    }
}
```

## Code Organization Guidelines

### File Structure
- One module per file
- Related functionality grouped
- Public API in lib.rs
- Internal modules private by default

### Import Organization
```rust
// Standard library
use std::io::Write;

// External crates
use actix_web::{web, HttpResponse};
use diesel::prelude::*;

// Workspace crates
use auth_utils::generate_hash;
use app_db::schema::users;

// Local modules
use crate::db::Database;
```

### Function Size
- Keep functions focused 
- Extract complex logic into helper functions
- extract logic into a function if it is used/copied at least 3 times

### Naming Conventions
- Descriptive over concise: `create_user_from_signup` not `create_usr`
- Verb prefixes for actions: `get_`, `create_`, `update_`, `delete_`
- Boolean predicates: `is_`, `has_`, `can_`

## Performance Considerations

### Connection Pooling
- Pool size: 10 connections (configured)
- Get connections only when needed
- Use async operations throughout

### Memory Allocation
- Uses MiMalloc for performance
- Minimize clones (use references)
- Stream large data instead of loading all at once

### WebSocket Messages
- Size limit: 1MiB for aggregated messages
- Process messages asynchronously
- Don't block the WebSocket handler

## Configuration Patterns

### Environment Variables
```rust
// With fallback defaults
let database_url = std::env::var("DATABASE_URL")
    .unwrap_or("postgres://postgres:postgres@localhost:7777".to_string());

// Without fallback (must be set)
let secret_key = std::env::var("COOKIE_SECRET_KEY")
    .expect("COOKIE_SECRET_KEY must be set");
```

### Platform-Specific Code
```rust
#[cfg(target_os = "linux")]
let cors = actix_cors::Cors::default();

#[cfg(target_os = "windows")]
let cors = actix_cors::Cors::permissive();
```

**Use**: Different behavior for development (Windows) vs production (Linux)

## Future Improvements (TODOs in Code)

### Identified Areas for Enhancement
1. **Logging**: Add proper logging instead of `eprintln!`
2. **Error Handling**: Replace `.unwrap()` with proper error propagation
3. **Session Cleanup**: Hold handle to shutdown cleanup task with server
4. **WebSocket Auth**: Implement proper session-based authentication for WebSocket
5. **Documentation**: Add rustdoc comments to public APIs
6. **Testing**: Expand test coverage across all modules
