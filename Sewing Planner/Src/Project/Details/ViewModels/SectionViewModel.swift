//
//  SectionViewModel.swift
//  Sewing Planner
//
//  Created by Art on 10/30/24.
//

import SwiftUI

@Observable
class Section {
    var section: SectionRecord = .init()
    var items: [SectionItemRecord] = []
    var id: UUID
    var deletedItems: [SectionItemRecord] = []
    var selectedItems: Set<Int64> = []
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
            let order = Int64(items.count)
            print("order", order)
            var record = SectionItemRecord(text: text.trimmingCharacters(in: .whitespacesAndNewlines), order: order)
            record.sectionId = section.id!
            print("record order", record.order)
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
    
    func saveOrder() throws {
        try db.getWriter().write { db in
            for case (let i, var record) in items.enumerated() {
                record.order = Int64(i)
                try! record.save(db)
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
    
    func deleteSelection() throws {
        try db.getWriter().write { db in
            for id in selectedItems {
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
    }

    func updateCompletedState(id: Int64) throws {
        try db.getWriter().write { db in
            if var record = items.first(where: {$0.id! == id}) {
                record.isComplete.toggle()
                try record.save(db)
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
