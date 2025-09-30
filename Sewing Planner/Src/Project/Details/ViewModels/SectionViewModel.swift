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
    var items: [SectionItem] = []
    var id: UUID
    var deletedItems: [SectionItemRecord] = []
    var selectedItems: Set<Int64> = []
    private let db: AppDatabase = .db()

    init(id: UUID, name: String) {
        section = SectionRecord(name: name)
        self.id = id
    }

    init(section: SectionRecord, items: [SectionItem], id: UUID) {
        self.section = section
        self.items = items
        self.id = id
    }

    func addItem(text: String, note: String?) throws {
        try db.getWriter().write { db in
            // TODO: do this in a transaction or see if the write is already a transaction
            let order = Int64(items.count)
            var record = SectionItemRecord(text: text.trimmingCharacters(in: .whitespacesAndNewlines), order: order)
            record.sectionId = section.id!
            try record.save(db)

            if let noteText = note {
                var noteRecord = SectionItemNoteRecord(text: noteText.trimmingCharacters(in: .whitespacesAndNewlines), sectionItemId: record.id!)
                try noteRecord.save(db)
                let sectionItem = SectionItem(record: record, note: noteRecord)
                items.append(sectionItem)
            } else {
                let sectionItem = SectionItem(record: record, note: nil)
                items.append(sectionItem)
            }
        }
    }

    func updateItem(id: Int64) throws {
        try db.getWriter().write { db in
            for var item in items {
                if let itemId = item.record.id {
                    if itemId == id {
                        try item.record.save(db)
                        try item.note?.save(db)
                    }
                }
            }
        }
    }

    func saveOrder() throws {
        try db.getWriter().write { db in
            for case (let i, var item) in items.enumerated() {
                item.record.order = Int64(i)
                try item.record.save(db)
            }
        }
    }

    // TODO: investigate updateText and updateItem redundancy
    func updateText(id: Int64, newText: String, newNoteText: String?) throws {
        try db.getWriter().write { db in
            if let i = items.firstIndex(where: { $0.record.id == id }) {
                var item = items[i]

                item.record.text = newText.trimmingCharacters(in: .whitespacesAndNewlines)
                try item.record.save(db)
                items[i].record = item.record

                if let noteText = newNoteText {
                    if noteText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                        return
                    }

                    if var itemNote = item.note {
                        itemNote.text = noteText.trimmingCharacters(in: .whitespacesAndNewlines)
                        try itemNote.save(db)
                        items[i].note = itemNote
                    } else {
                        item.note = SectionItemNoteRecord(text: noteText, sectionItemId: item.record.id!)
                        try item.note?.save(db)
                        items[i].note = item.note
                    }
                }
            }
        }
    }

    func deleteSelection() throws {
        try db.getWriter().write { db in
            for id in selectedItems {
                let maybeIndex = items.firstIndex { val in
                    if let valId = val.record.id {
                        return valId == id
                    }
                    return false
                }
                if let index = maybeIndex {
                    var deletedItem = items.remove(at: index)
                    deletedItem.record.isDeleted = true
                    try deletedItem.record.update(db)
                }
            }
        }
    }

    func updateCompletedState(id: Int64) throws {
        try db.getWriter().write { db in
            if var item = items.first(where: { $0.record.id! == id }) {
                item.record.isComplete.toggle()
                try item.record.save(db)
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
