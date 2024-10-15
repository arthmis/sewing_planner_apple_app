//
//  ProjectDetailData.swift
//  Sewing Planner
//
//  Created by Art on 10/11/24.
//

import Foundation
import SwiftUI
import GRDB

struct Section: Hashable, Identifiable, Codable, EncodableRecord, FetchableRecord, MutablePersistableRecord, TableRecord {
    var id: Int64?
    var projectId: Int64?
    var name: String = ""
    var createDate: Date = Date()
    var updateDate: Date = Date()
    static let databaseTableName = "section"
    
    mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }
    
}

struct SectionItem: Hashable, Identifiable, Codable, EncodableRecord, FetchableRecord, MutablePersistableRecord, TableRecord {
    var id: Int64?
    var sectionId: Int64?
    var text: String = ""
    var isComplete: Bool = false
    var createDate: Date = Date()
    var updateDate: Date = Date()
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
}

struct SectionData {
    var section: Section = Section()
    var items: [SectionItem] = []
    var deletedItems: [SectionItem] = []

    mutating func addItem(text: String) {
        items.append(SectionItem(text: text))
    }
}

class ProjectDetailData: ObservableObject {
    var project = ProjectData()
    @Published var sectionData: [SectionData] = []
    @Published var projectSteps: [ProjectStep] = []
    @Published var deletedProjectSteps: [ProjectStep] = []
    @Published var projectImages: [ProjectImage] = []
    @Published var deletedImages: [ProjectImage] = []
    
    func addSection() {
        sectionData.append(SectionData())
    }
}

class ProjectData: ObservableObject {
    @Published var data = Project()
    
    func updateName(name: String) {
        data.name = name
    }
    
}
