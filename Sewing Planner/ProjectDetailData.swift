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

class Section: ObservableObject  {
    @Published var section: SectionRecord = SectionRecord()
    @Published var items: [SectionItemRecord] = []
    var id: UUID
    var deletedItems: [SectionItemRecord] = []

    init(id: UUID, name: String) {
        section = SectionRecord(name: name)
        self.id = id
    }
    
    init(section: SectionRecord, items: [SectionItemRecord], id: UUID) {
        self.section = section
        self.items = items
        self.id = id
    }
    
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
    
    init() {}
    
    init(sections: [Section]) {
        self.sections = sections
    }
    
    func addSection() {
        sections.append(Section(id: UUID(), name: "Section \(sections.count + 1)"))
    }
}

class ProjectDetailData: ObservableObject {
    var project = ProjectData()
    var projectSections: ProjectSections = ProjectSections()
    var projectImages: ProjectImages = ProjectImages()
    var deletedImages: [ProjectImage] = []
    let appDatabase: AppDatabase = AppDatabase.db
    
    func saveProject() throws -> Int64 {
        let projectId = try appDatabase.saveProject(model: self)
        try AppFiles().saveProjectImages(projectId: projectId, images: projectImages.images)
        return projectId
    }
    
    func getProject(with id: Int64) {
        let db = AppDatabase.db
        
        do {
            let project = try db.getProject(id: id)
            let projectData = ProjectData(data: project!)
            self.project = projectData
            print(projectData.data)
            let sections = try db.getSections(projectId: id)
            self.projectSections = sections
            print(sections.sections.count)
            let images = try db.getImages(projectId: id)
            print(images.images.count)
            self.projectImages = images
            
            
        } catch {
            print("error retrieving data: \(error)")
        }
        
    }
}

class ProjectImages: ObservableObject {
    @Published  var images: [ProjectImage] = []
    @Published  var deletedImages: [ProjectImage] = []
    
    init() {}
    
    init(images: [ProjectImage]) {
        self.images = images
    }
}
