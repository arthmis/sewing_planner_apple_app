# Development Guidelines

## General Principles

1. **Swift Concurrency**: Use Swift 6.0 concurrency features properly
2. **Type Safety**: Leverage Swift's type system for compile-time safety
3. **Immutability**: Prefer `let` over `var` when possible
4. **Error Handling**: Use typed throws and proper error propagation
5. **Testing**: Write tests for new functionality
6. **Documentation**: Comment complex logic and add notes for gotchas

## SwiftUI Development Guidelines

### View Construction

**DO:**
```swift
struct MyView: View {
  @Environment(\.db) var db
  let viewModel: MyViewModel
  
  var body: some View {
    VStack {
      // Simple, declarative UI
    }
  }
}
```

**DON'T:**
```swift
struct MyView: View {
  var body: some View {
    if condition {
      VStack { /* one thing */ }
    } else {
      VStack { /* similar thing */ }
    }
  }
}
```
❌ Conditional view modifiers cause state loss and animation issues

### State Management

**DO:**
- Use `@Observable` for ViewModels
- Use `@State` for local view state
- Use `@Binding` for two-way communication
- Use `@Environment` for dependency injection

**DON'T:**
- Mix `@StateObject` with `@Observable` (use one pattern)
- Put business logic directly in views
- Create state in computed properties

### List and ForEach

**DO:**
```swift
ForEach(items) { item in
  ItemRow(item: item)
}
.onDelete { indexSet in
  // Ensure TextField is not focused
  deleteItems(at: indexSet)
}
```

**DON'T:**
```swift
// Using string arrays for editable fields
ForEach(stringArray, id: \.self) { string in
  TextField("", text: $string)  // ❌ Focus issues
}
```
❌ Empty strings have same ID, causing focus jumping

### Alerts

**Limitation**: SwiftUI may only support one `.alert()` modifier per view

**Workaround**:
- Use a single alert with enum-based state
- Show different content based on alert type
- See: https://www.hackingwithswift.com/quick-start/swiftui/how-to-show-multiple-alerts-in-a-single-view

### Navigation

**DO:**
```swift
NavigationLink(value: item) {
  Text(item.name)
}
```
❌ If you use a destination view directly, it's created immediately

**Lazy Loading**: Use value-based navigation for lazy view creation (see notes.md, lesson 43)

### Animation Guidelines

- Avoid conditional view modifiers (cause animation issues)
- Use explicit animations: `.animation(.default, value: someState)`
- Test animations on device (simulator can be misleading)

### Focus Management

**Problem**: No built-in way to dismiss keyboard on tap outside

**Solution**: Custom implementation (see notes.md)
- https://gist.github.com/arthmis/92c46c46dd448b5a527e68c13a1bc715

### Images

**Best Practices**:
- Create thumbnails for list views
- Store file paths, not image data in database
- Resize images before saving: `.resizable().aspectRatio(contentMode: .fit)`
- Use `PhotosUI` for image picking

## Database Development (GRDB)

### Model Definition

**Required Protocols**:
```swift
struct MyModel: Codable, FetchableRecord, PersistableRecord {
  var id: Int64?
  var name: String
  var isDeleted: Bool
  var createDate: Date
  var updateDate: Date
}
```

**Coding Keys** (if needed):
```swift
enum CodingKeys: String, CodingKey {
  case id, name, isDeleted, createDate, updateDate
}
```

### Migrations

**Guidelines**:
1. Never modify existing migrations
2. Use descriptive migration names
3. Always use `.ifNotExists` for tables
4. Index frequently queried columns
5. Test migrations both ways (up and down if supported)

**Example**:
```swift
migrator.registerMigration("add_project_notes") { db in
  try db.alter(table: "project") { table in
    table.add(column: "notes", .text)
  }
}
```

### Queries

**Type-Safe Queries**:
```swift
// Fetch all
let projects = try Project.all().fetchAll(db)

// Filter
let active = try Project
  .filter(Column("isDeleted") == false)
  .fetchAll(db)

// Order
let sorted = try Project
  .order(Column("createDate").desc)
  .fetchAll(db)
```

### Transactions

**Always use transactions for multiple operations**:
```swift
try db.write { db in
  try project.save(db)
  try image.save(db)
  // Both succeed or both fail
}
```

### Date Handling

**⚠️ Important**: Compare dates with specific granularity
```swift
// DON'T: Direct comparison
if date1 == date2 { }  // ❌ Precision issues

// DO: Compare with granularity
if Calendar.current.isDate(date1, inSameDayAs: date2) { }  // ✅
```

See: https://github.com/groue/GRDB.swift/issues/492

## Rust Backend Guidelines

### Error Handling

**Use anyhow for application errors**:
```rust
use anyhow::{Result, Context};

fn do_something() -> Result<()> {
    let data = load_data()
        .context("Failed to load data")?;
    Ok(())
}
```

**Use snafu for library errors**:
```rust
use snafu::{Snafu, ResultExt};

#[derive(Debug, Snafu)]
pub enum MyError {
    #[snafu(display("Database error: {}", source))]
    Database { source: diesel::result::Error },
}
```

### Async/Await

**Actix-web is async by default**:
```rust
async fn handler(
    pool: web::Data<Pool>,
    data: web::Json<MyData>,
) -> Result<HttpResponse, Error> {
    let mut conn = pool.get().await?;
    let result = do_db_operation(&mut conn).await?;
    Ok(HttpResponse::Ok().json(result))
}
```

### Database Access

**Use connection pooling**:
```rust
let config = AsyncDieselConnectionManager::<AsyncPgConnection>::new(database_url);
let pool = Pool::builder()
    .build(config)
    .await?;
```

**Queries**:
```rust
use diesel::prelude::*;

let results = projects::table
    .filter(projects::is_deleted.eq(false))
    .load::<Project>(&mut conn)
    .await?;
```

### WebSocket Handling

**Pattern for WebSocket connections**:
```rust
async fn websocket_handler(
    req: HttpRequest,
    stream: web::Payload,
) -> Result<HttpResponse, Error> {
    let (res, mut session, mut msg_stream) = actix_ws::handle(&req, stream)?;
    
    actix_web::rt::spawn(async move {
        while let Some(Ok(msg)) = msg_stream.next().await {
            // Handle message
        }
    });
    
    Ok(res)
}
```

### Session Management

**Use the custom SQLite session store**:
```rust
let session_store = sqlite_session_store::SqliteSessionStore::new(conn);
let session_middleware = SessionMiddleware::builder(session_store, secret_key)
    .cookie_secure(true)  // Production only
    .build();
```

## Testing Guidelines

### Unit Tests (Swift)

**Structure**:
```swift
import XCTest
@testable import Sewing_Planner

final class MyTests: XCTestCase {
    override func setUpWithError() throws {
        // Setup before each test
    }
    
    override func tearDownWithError() throws {
        // Cleanup after each test
    }
    
    func testFeature() throws {
        // Arrange
        let input = createTestData()
        
        // Act
        let result = performOperation(input)
        
        // Assert
        XCTAssertEqual(result, expectedValue)
    }
}
```

### UI Tests

**Use accessibility identifiers**:
```swift
// In View
Text("Submit")
    .accessibilityIdentifier("submitButton")

// In Test
let submitButton = app.buttons["submitButton"]
XCTAssertTrue(submitButton.exists)
submitButton.tap()
```

**Record tests**: Use UI Test Recorder (red circle button) to generate test code

### Rust Tests

**Unit tests**:
```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_feature() {
        let result = my_function();
        assert_eq!(result, expected);
    }
}
```

**Async tests**:
```rust
#[actix_web::test]
async fn test_async_feature() {
    let result = async_function().await;
    assert!(result.is_ok());
}
```

## Code Review Checklist

Before submitting code for review:

- [ ] Code follows project style guidelines
- [ ] swift-format applied (Swift) or cargo fmt (Rust)
- [ ] No compiler warnings
- [ ] Tests added for new functionality
- [ ] Tests pass locally
- [ ] No debug print statements left in
- [ ] Comments added for complex logic
- [ ] Error handling properly implemented
- [ ] Database migrations tested
- [ ] No force unwraps without justification
- [ ] Accessibility considered (if UI changes)

## Common Anti-Patterns to Avoid

### Swift
1. Force unwrapping optionals unnecessarily: `value!`
2. Implicitly unwrapped optionals without good reason: `var value: String!`
3. Large view bodies (extract to separate views/components)
4. Business logic in views (belongs in ViewModels)
5. Forgetting to mark async functions with `async`
6. Not using proper error propagation (catching and ignoring errors)

### Rust
1. Using `unwrap()` or `expect()` in production code
2. Blocking operations in async contexts
3. Not using `?` operator for error propagation
4. Manual error conversion (use `.context()` instead)
5. Ignoring clippy warnings without good reason

## Performance Considerations

### iOS
- Use `.task` modifier for async work in views
- Lazy load views in navigation
- Use virtual scrolling (LazyVStack/LazyHStack) for large lists
- Thumbnail images for lists, full resolution only when needed
- Profile with Instruments for memory leaks

### Backend
- Use connection pooling (already configured)
- Index database columns used in WHERE clauses
- Batch database operations when possible
- Use WebSocket for real-time updates (more efficient than polling)
- Consider implementing pagination for large datasets

## Debugging Tools

### iOS
1. **Xcode Debugger**: Breakpoints and lldb `po` commands
2. **Instruments**: Memory, CPU, and network profiling
3. **View Hierarchy Debugger**: Visual debugging of view layout
4. **Accessibility Inspector**: Test accessibility and inspect elements
5. **UI Test Recorder**: Generate UI test code automatically

### Rust
1. **cargo check**: Fast compilation checks
2. **cargo clippy**: Linting and suggestions
3. **RUST_BACKTRACE=1**: Full error backtraces
4. **RUST_LOG=debug**: Enable debug logging
5. **cargo-watch**: Auto-rebuild on changes

## Resources

### Swift/SwiftUI
- notes.md: Project-specific learnings
- Hacking with Swift: SwiftUI tutorials
- Apple Documentation: SwiftUI and Swift
- GRDB Documentation: https://github.com/groue/GRDB.swift

### Rust
- The Rust Book: https://doc.rust-lang.org/book/
- Actix Web Guide: https://actix.rs/docs/
- Diesel Guide: https://diesel.rs/guides/
