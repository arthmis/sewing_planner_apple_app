//
//  SectionModel.swift
//  Sewing Planner
//
//  Created by Art on 10/30/24.
//

import GRDB
import SwiftUI

struct SectionRecord: Hashable, Identifiable, Codable, EncodableRecord, FetchableRecord, MutablePersistableRecord, TableRecord {
    var id: Int64?
    var projectId: Int64?
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
    var id: Int64?
    var sectionId: Int64?
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

    init(text: String, order: Int64) {
        self.text = text
        isComplete = false
        let now = Date()
        createDate = now
        updateDate = now
        self.order = order
    }

    init(id: Int64, text: String, order: Int64) {
        self.id = id
        self.text = text
        isComplete = false
        let now = Date()
        createDate = now
        updateDate = now
        self.order = order
    }
}

extension SectionItemRecord {
    static let notes = hasOne(SectionItemNoteRecord.self)
    var notes: QueryInterfaceRequest<SectionItemNoteRecord> {
        request(for: SectionItemRecord.notes)
    }
}

struct SectionItemNoteRecord: Hashable, Identifiable, Codable, EncodableRecord, FetchableRecord, MutablePersistableRecord, TableRecord {
    var id: Int64?
    var sectionItemId: Int64
    var text: String = ""
    var createDate: Date = .init()
    var updateDate: Date = .init()
    static let databaseTableName = "sectionItemNote"
    
    static let sectionItem = belongsTo(SectionItemRecord.self).forKey("sectionItem")

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
