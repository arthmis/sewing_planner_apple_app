//
//  SectionViewModel.swift
//  Sewing Planner
//
//  Created by Art on 10/30/24.
//

import SwiftUI

@Observable
class Section {
    var section: SectionRecord
    var items: [SectionItem] = []
    var id: UUID
    var deletedItems: [SectionItemRecord] = []
    var selectedItems: Set<Int64> = []
    private let db: AppDatabase = .db()

    init(id: UUID, name: SectionRecord) {
        section = name
        self.id = id
    }

    init(section: SectionRecord, items: [SectionItem], id: UUID) {
        self.section = section
        self.items = items
        self.id = id
    }

    var hasSelections: Bool {
        !selectedItems.isEmpty
    }

    func addItem(text: String, note: String?) throws {
        try db.getWriter().write { db in
            // TODO: do this in a transaction or see if the write is already a transaction
            let order = Int64(items.count)
            var recordInput = SectionItemInputRecord(text: text.trimmingCharacters(in: .whitespacesAndNewlines), order: order, sectionId: section.id)
            recordInput.sectionId = section.id
            try recordInput.save(db)
            let record = SectionItemRecord(from: recordInput)

            if let noteText = note {
                var noteInputRecord = SectionItemNoteInputRecord(text: noteText.trimmingCharacters(in: .whitespacesAndNewlines), sectionItemId: record.id)
                try noteInputRecord.save(db)
                let noteRecord = SectionItemNoteRecord(from: noteInputRecord)
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
                if item.record.id == id {
                    try item.record.save(db)
                    try item.note?.save(db)
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
    func updateText(id: Int64, consume newText: String, consume newNoteText: String?) throws {
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
                        let trimmedNoteText = noteText.trimmingCharacters(in: .whitespacesAndNewlines)
                        var noteInput = SectionItemNoteInputRecord(text: trimmedNoteText, sectionItemId: item.record.id)
                        try noteInput.save(db)
                        item.note = SectionItemNoteRecord(from: noteInput)
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
                    return val.record.id == id
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
            if var item = items.first(where: { $0.record.id == id }) {
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
