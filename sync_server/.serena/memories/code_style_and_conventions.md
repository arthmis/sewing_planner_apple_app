# Code Style and Conventions

## Language Version
- **Rust Edition**: 2024
- **Target**: Recent stable Rust compiler supporting edition 2024 features

## Naming Conventions

### Types and Structs
- **PascalCase** for types: `User`, `SignupCredentials`, `UserLogin`, `EmailAddress`
- **Descriptive names** that clearly indicate purpose
- Error types end with `Error`: `SignupError`, `LoginError`, `GenerateHashError`

### Functions and Methods
- **snake_case** for functions: `generate_password_hash`, `create_user_from_signup`, `get_user`
- Async functions prefixed naturally: `async fn login(...)`, `async fn get_user(...)`
- Public API functions clearly exported with `pub` keyword

### Variables
- **snake_case** for all variables: `database_url`, `secret_key`, `session_store`
- Descriptive names over abbreviations: `user_id` not `uid`

### Constants
- **SCREAMING_SNAKE_CASE** for constants and statics: `GLOBAL` (for allocator)

## Module Organization

### Visibility
- Use `pub` explicitly for public API exports
- Keep internal implementation details private by default
- Use `pub(crate)` for workspace-internal visibility when needed

### Module Structure
- One module per file: `mod db;`, `mod events;`
- Place submodules in separate files within `src/` directory
- Use `lib.rs` for library crates, `main.rs` for binaries

## Type Annotations

### Explicit Types
- Type aliases for readability: `type DbPool = Pool<AsyncPgConnection>;`
- Explicit type annotations for function parameters
- Return types explicitly specified for all public functions

### Trait Bounds
- Use clear trait bounds: `impl Database`, `impl ResponseError`
- Derive macros grouped logically:
  ```rust
  #[derive(Debug, Clone, Serialize, Deserialize)]
  ```

## Error Handling

### Error Types
- **SNAFU** library for error handling with context
- All errors implement proper Display and context tracking
- Location tracking with `#[snafu(implicit)]` for debugging

### Error Patterns
```rust
#[derive(Debug, Snafu)]
pub enum SignupError {
    #[snafu(display("Invalid email"))]
    InvalidEmail {
        #[snafu(implicit)]
        location: Location,
        source: email_address::Error,
    },
    #[snafu(display("Invalid password"))]
    InvalidPassword,
}
```

### Error Propagation
- Use `.context(ErrorVariantSnafu {})` for context attachment
- Convert errors with `?` operator when appropriate
- Implement `ResponseError` trait for HTTP error responses

## Actix-web Patterns

### Request Handlers
- Async functions with `#[post("/route")]` or `#[get("/route")]` macros
- Use extractors: `web::Data<DbPool>`, `web::Json<T>`, `Session`
- Return `actix_web::Result<T, E>` where E implements ResponseError

### Error Responses
- Implement `ResponseError` trait for custom error types
- Set appropriate `status_code()` for each error variant
- Provide clear error messages in `error_response()`
- Use `mime::TEXT_PLAIN_UTF_8` for content type

## Diesel Patterns

### Schema Generation
- Auto-generated schemas with `// @generated automatically by Diesel CLI`
- Do not manually edit generated schema files
- Use `diesel::table!` macro for table definitions

### Models
- Derive `Queryable`, `Selectable`, `Insertable` as needed
- Use `#[diesel(table_name = ...)]` attribute
- Separate types for queries (`User`) and inserts (`UserInput`)

### Custom SQL Types
- Implement `FromSql` and `ToSql` for custom types (e.g., `Email`)
- Use `#[diesel(sql_type = ...)]` for type mapping
- Derive `AsExpression` and `FromSqlRow` for custom SQL types

### Queries
- Use query builder DSL: `users.filter(email.eq(...)).select(...).first(...)`
- Prefer type-safe queries over raw SQL
- Use `.await?` for async queries

## Async/Await Patterns

### Async Functions
- Mark functions with `async fn` when they perform async operations
- Use `.await` on futures
- Handle async database operations with diesel-async

### Runtime
- Use `#[actix_web::main]` for main function
- Spawn background tasks with `actix_web::rt::spawn`
- Use `actix_web::rt::time::sleep` for delays

## Database Connections

### Connection Pooling
- Use connection pools: `web::Data<DbPool>`
- Get connections with `.get().await.unwrap()`
- Pool size configured at startup (max 10)

### Transaction Pattern
- Get mutable connection: `let mut conn = db_pool.get().await.unwrap();`
- Pass `&mut conn` to database operations
- Use database trait abstraction for testability

## Documentation

### Comments
- Use `//` for line comments
- TODO comments marked clearly: `// TODO: log the error`
- Explain non-obvious logic or business rules

### Module Documentation
- Currently minimal, could be improved with `//!` module docs
- No rustdoc comments on public APIs yet

## Dependencies Management

### Workspace Dependencies
- Shared dependencies defined in `[workspace.dependencies]`
- Workspace members reference with `{ workspace = true }`
- Internal crates referenced by path: `{ path = "./api" }`

### Feature Flags
- Diesel features: `["postgres_backend", "chrono"]`
- Platform-specific features: conditional CORS configuration

## Security Practices

### Password Handling
- Never log or display passwords
- Use Argon2 for password hashing with random salts
- Compare passwords with constant-time operations

### Session Management
- Use secure session keys (Base64-encoded)
- 24-hour session TTL
- Automatic cleanup of expired sessions
- Cookie security settings (currently `cookie_secure(false)` for development)

## Code Quality

### Unwrap Usage
- `.unwrap()` used in initialization code where failure is fatal
- TODO comments where proper error handling should be added
- Consider replacing with proper error propagation in production code

### Clone Usage
- `.clone()` used for connection pool and session store sharing
- Reasonable for Arc-wrapped types

## Testing
- Test infrastructure present (testcontainers in event_database)
- Currently minimal test coverage
- Uses `#[cfg(test)]` and test utilities when needed