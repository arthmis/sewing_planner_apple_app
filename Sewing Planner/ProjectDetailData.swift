//
//  ProjectDetailData.swift
//  Sewing Planner
//
//  Created by Art on 10/11/24.
//

import Foundation
import SwiftUI
import GRDB

struct SectionRecord: Hashable, Identifiable, Codable, EncodableRecord, FetchableRecord, MutablePersistableRecord, TableRecord {
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

struct SectionItemRecord: Hashable, Identifiable, Codable, EncodableRecord, FetchableRecord, MutablePersistableRecord, TableRecord {
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

class Section: ObservableObject {
    @Published var section: SectionRecord = SectionRecord()
    @Published var items: [SectionItemRecord] = []
    var deletedItems: [SectionItemRecord] = []

    func addItem(text: String) {
        items.append(SectionItemRecord(text: text))
    }
    
    func deleteItem(index: Int) {
        let deletedItem = items.remove(at: index)
        deletedItems.append(deletedItem)
    }
    
    func updateSectionName(with name: String) {
        section.name = name
    }
}

class ProjectSections: ObservableObject {
    @Published var sections: [Section] = []
    
    func addSection() {
        print("in add section function")
        sections.append(Section())
        print(sections.count)
    }
}

class ProjectDetailData: ObservableObject {
    var project = ProjectData()
    var projectSections: ProjectSections = ProjectSections()
    @Published var projectImages: [ProjectImage] = []
    @Published var deletedImages: [ProjectImage] = []
}

class ProjectData: ObservableObject {
    @Published var data = Project()
    
    func updateName(name: String) {
        data.name = name
    }
    
}
