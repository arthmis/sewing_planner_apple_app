# Task Completion Checklist

When completing a development task on the sync_server project, follow this checklist to ensure code quality and proper integration.

## Pre-Commit Checklist

### 1. Code Formatting
```bash
# Format all code
cargo fmt

# Verify formatting
cargo fmt -- --check
```
**Action**: Ensure all code follows Rust standard formatting rules.

### 2. Linting
```bash
# Run Clippy linter
cargo clippy

# Run with warnings as errors (stricter)
cargo clippy -- -D warnings
```
**Action**: Address all Clippy warnings and errors. Common issues:
- Unused imports
- Unnecessary clones
- Missing error handling (unwrap usage)
- Type complexity issues

### 3. Build Verification
```bash
# Build entire workspace
cargo build

# Build in release mode to catch optimization issues
cargo build --release
```
**Action**: Ensure clean build with no errors or warnings.

### 4. Type Checking
```bash
# Fast type checking without code generation
cargo check
```
**Action**: Verify type correctness across all workspace members.

### 5. Run Tests
```bash
# Run all tests
cargo test

# Run with output for debugging
cargo test -- --nocapture
```
**Action**: Ensure all existing tests pass. Add new tests for new functionality.

### 6. Database Migrations (if applicable)
```bash
# Check if new migrations need to be run
cd app_db
diesel migration list
diesel migration run
cd ..
```
**Action**: If you modified database schema:
- Create migration with `diesel migration generate <name>`
- Write both `up.sql` and `down.sql`
- Test migration with `diesel migration run`
- Test rollback with `diesel migration revert`
- Regenerate schema: `diesel print-schema > src/schema.rs`

## Code Review Checklist

### Security
- [ ] No passwords or sensitive data logged
- [ ] Input validation on all user inputs
- [ ] Proper error handling (no unwrap() in production paths)
- [ ] SQL injection prevention (use Diesel query builder)
- [ ] Session handling secure and proper

### Error Handling
- [ ] All errors properly typed with SNAFU
- [ ] Error contexts provide meaningful information
- [ ] HTTP status codes appropriate for each error
- [ ] No silent failures (log or return errors)
- [ ] Location tracking included for debugging

### Database Operations
- [ ] Connection pooling used correctly
- [ ] Async operations properly awaited
- [ ] Transactions used where needed
- [ ] Migrations are reversible
- [ ] Schema.rs regenerated if needed

### API Design
- [ ] Endpoints follow RESTful conventions
- [ ] Request/response types properly serialized
- [ ] Authentication checked where needed
- [ ] CORS configured appropriately
- [ ] WebSocket messages validated

### Code Quality
- [ ] No compiler warnings
- [ ] No Clippy warnings
- [ ] Proper type annotations
- [ ] Function signatures clear and documented
- [ ] Module organization logical

### Performance
- [ ] No unnecessary clones
- [ ] Efficient database queries (avoid N+1)
- [ ] Connection pool size appropriate
- [ ] Background tasks don't block main thread

## Documentation Updates

### When Adding New Features
- [ ] Update relevant memory files if architecture changes
- [ ] Add TODO comments for incomplete features
- [ ] Document new environment variables if added
- [ ] Update API endpoint list if changed

### When Fixing Bugs
- [ ] Document the issue and fix in commit message
- [ ] Consider adding test to prevent regression
- [ ] Update comments if implementation changed

## Integration Testing

### Manual Testing Steps
1. **Build and Run**
   ```bash
   cargo build
   cargo run
   ```

2. **Test Signup Endpoint**
   ```bash
   # Using curl or HTTP client
   POST http://localhost:8080/signup
   Body: {"email": "test@example.com", "password": "securepassword"}
   ```

3. **Test Login Endpoint**
   ```bash
   POST http://localhost:8080/login
   Body: {"email": "test@example.com", "password": "securepassword"}
   # Verify session cookie is set
   ```

4. **Test WebSocket Connection**
   ```bash
   # Connect to ws://localhost:8080/ws
   # Verify connection established
   # Send test event and verify handling
   ```

5. **Verify Database State**
   - Check PostgreSQL for user records
   - Check sessions.db for active sessions
   - Verify timestamps are correct

### Load Testing (Optional)
```bash
# Use tools like wrk, ab, or vegeta for load testing
# Example: Test concurrent connections
```

## Deployment Checklist

### Before Deployment
- [ ] All tests passing
- [ ] Release build successful: `cargo build --release`
- [ ] Environment variables documented
- [ ] Database migrations ready
- [ ] Cookie secret key securely generated
- [ ] CORS settings appropriate for production
- [ ] Session cookie settings (set `cookie_secure(true)` for HTTPS)

### Environment Configuration
- [ ] PostgreSQL database URL configured
- [ ] Cookie secret key set (use secure random generation)
- [ ] Database initialized with migrations
- [ ] Session cleanup interval appropriate

## Git Workflow

### Commit Messages
Use clear, descriptive commit messages:
```
feat: Add project deletion endpoint
fix: Resolve session cleanup memory leak
refactor: Extract user validation logic
docs: Update API documentation
test: Add integration tests for login flow
```

### Before Push
```bash
# Final verification
cargo fmt -- --check
cargo clippy -- -D warnings
cargo test
cargo build --release
```

## Common Issues and Solutions

### Issue: Diesel connection errors
**Solution**: Verify PostgreSQL is running and DATABASE_URL is correct

### Issue: Session not persisting
**Solution**: Check cookie_secure setting and HTTPS configuration

### Issue: WebSocket connection fails
**Solution**: Verify session middleware is not interfering (see commented code)

### Issue: Build fails with linking errors
**Solution**: Check OpenSSL dependencies, may need `vendored` feature

### Issue: Migration fails
**Solution**: Check migration syntax, verify database state with `diesel migration list`