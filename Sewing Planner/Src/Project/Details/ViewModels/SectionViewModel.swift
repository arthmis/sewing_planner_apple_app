//
//  SectionViewModel.swift
//  Sewing Planner
//
//  Created by Art on 10/30/24.
//

import SwiftUI

class Section: ObservableObject {
    @Published var section: SectionRecord = .init()
    @Published var items: [SectionItemRecord] = []
    var id: UUID
    var deletedItems: [SectionItemRecord] = []
    private let db: AppDatabase = .db()

    init(id: UUID, name: String) {
        section = SectionRecord(name: name)
        self.id = id
    }

    init(section: SectionRecord, items: [SectionItemRecord], id: UUID) {
        self.section = section
        self.items = items
        self.id = id
    }

    func addItem(text: String) throws {
        try db.getWriter().write { db in
            var record = SectionItemRecord(text: text)
            record.sectionId = section.id!
            try record.save(db)
            items.append(record)
        }
    }

    func updateItem(id: Int64) throws {
        try db.getWriter().write { db in
            for var record in items {
                if let itemId = record.id {
                    if itemId == id {
                        try record.save(db)
                    }
                }
            }
        }
    }
    
    func updateText(id: Int64, newText: String) throws {
        try db.getWriter().write { db in
            for var record in items {
                if let itemId = record.id {
                    if itemId == id {
                        record.text = newText
                        try record.save(db)
                    }
                }
            }
        }
    }
    
    func deleteItem(id: Int64) throws {
        try db.getWriter().write { db in
            let maybeIndex = items.firstIndex { val in
                if let valId = val.id {
                    return valId == id
                }
                return false
            }
            if let index = maybeIndex {
                var deletedItem = items.remove(at: index)
                deletedItem.isDeleted = true
                try deletedItem.update(db)
            }
        }
    }

    func updateSectionName(with name: String) throws {
        section.name = name
        try db.getWriter().write { db in
            try section.save(db)
        }
    }
}
