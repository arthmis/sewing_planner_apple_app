//
//  SectionModel.swift
//  Sewing Planner
//
//  Created by Art on 10/30/24.
//

import GRDB
import SwiftUI

struct SectionRecord: Hashable, Identifiable, Codable, EncodableRecord, FetchableRecord, MutablePersistableRecord, TableRecord {
    var id: Int64
    var projectId: Int64
    var name: String = ""
    var isDeleted = false
    var createDate: Date = .init()
    var updateDate: Date = .init()
    static let databaseTableName = "section"

    init(from record: SectionInputRecord) {
        self.id = record.id!
        self.projectId = record.projectId
        self.name = record.name
        self.isDeleted = record.isDeleted
        self.createDate = record.createDate
        self.updateDate = record.updateDate
    }
}

struct SectionInputRecord: Hashable, Identifiable, Codable, EncodableRecord, MutablePersistableRecord, TableRecord {
    var id: Int64?
    var projectId: Int64
    var name: String = ""
    var isDeleted = false
    var createDate: Date = .init()
    var updateDate: Date = .init()
    static let databaseTableName = "section"

    mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }
}

struct SectionItemRecord: Hashable, Identifiable, Codable, EncodableRecord, FetchableRecord, MutablePersistableRecord, TableRecord {
    var id: Int64
    var sectionId: Int64
    var text: String = ""
    var isComplete: Bool = false
    var isDeleted = false
    var order: Int64
    var createDate: Date = .init()
    var updateDate: Date = .init()
    static let databaseTableName = "sectionItem"

    // the "note" in forKey has to match the name of the property in SectionItem struct
    static let note = hasOne(SectionItemNoteRecord.self).forKey("note")
    var notes: QueryInterfaceRequest<SectionItemNoteRecord> {
        request(for: SectionItemRecord.note)
    }

    mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }

    init(from record: SectionItemInputRecord) {
        self.id = record.id!
        self.sectionId = record.sectionId
        self.text = record.text
        self.isComplete = record.isComplete
        self.isDeleted = record.isDeleted
        self.order = record.order
        self.createDate = record.createDate
        self.updateDate = record.updateDate
    }
}

struct SectionItemInputRecord: Hashable, Identifiable, Codable, EncodableRecord, FetchableRecord, MutablePersistableRecord, TableRecord {
    var id: Int64?
    var sectionId: Int64
    var text: String = ""
    var isComplete: Bool = false
    var isDeleted = false
    var order: Int64
    var createDate: Date = .init()
    var updateDate: Date = .init()
    static let databaseTableName = "sectionItem"

    mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }

    init(text: String, order: Int64, sectionId: Int64) {
        self.text = text
        self.sectionId = sectionId
        isComplete = false
        let now = Date()
        createDate = now
        updateDate = now
        self.order = order
    }

    init(id: Int64, text: String, order: Int64, sectionId: Int64) {
        self.id = id
        self.text = text
        self.sectionId = sectionId
        isComplete = false
        let now = Date()
        createDate = now
        updateDate = now
        self.order = order
    }
}

struct SectionItemNoteRecord: Hashable, Identifiable, Codable, EncodableRecord, FetchableRecord, MutablePersistableRecord, TableRecord {
    var id: Int64
    var sectionItemId: Int64
    var text: String = ""
    var createDate: Date = .init()
    var updateDate: Date = .init()
    static let databaseTableName = "sectionItemNote"


    mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }

    init(id: Int64, text: String, sectionItemId: Int64) {
        self.id = id
        self.text = text
        self.sectionItemId = sectionItemId
        let now = Date()
        createDate = now
        updateDate = now
    }
    
    init(from record: SectionItemNoteInputRecord) {
        self.id = record.id!
        self.text = record.text
        self.sectionItemId = record.sectionItemId
        createDate = record.createDate
        updateDate = record.updateDate
    }

}

struct SectionItemNoteInputRecord: Hashable, Identifiable, Codable, EncodableRecord, FetchableRecord, MutablePersistableRecord, TableRecord {
    var id: Int64?
    var sectionItemId: Int64
    var text: String = ""
    var createDate: Date = .init()
    var updateDate: Date = .init()
    static let databaseTableName = "sectionItemNote"


    mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }

    init(text: String, sectionItemId: Int64) {
        self.text = text
        self.sectionItemId = sectionItemId
        let now = Date()
        createDate = now
        updateDate = now
    }

}
