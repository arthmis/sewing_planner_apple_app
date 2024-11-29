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
    var createDate: Date = .init()
    var updateDate: Date = .init()
    static let databaseTableName = "sectionItem"

    mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }

    init(text: String) {
        self.text = text
        isComplete = false
        let now = Date()
        createDate = now
        updateDate = now
    }
    
    init(id: Int64, text: String) {
        self.id = id
        self.text = text
        isComplete = false
        let now = Date()
        createDate = now
        updateDate = now
    }
}
