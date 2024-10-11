## Tables
```sql
    project (
        id int,
        name text,
        updateDate datetime,
        createDate datetime
    )
```
```sql
    section (
        id int,
        projectId int,
        name text,
        updateDate datetime,
        createDate datetime
    )
```
```sql
    sectionItem (
        id int,
        sectionId int,
        text text,
        isCompleted boolean,
        updateDate datetime,
        createDate datetime
    )
```

All Sections View
- array of sections data
```swift
    struct Section {
        id: Int64?
        projectId: Int64
        name: String
        items: SectionItem[]
    }
```

```swift
    struct SectionItem {
        id: Int64?
        sectionId: Int64
        text: String
        isCompleted: Bool 
    }
```