//
//  ProjectName.swift
//  Sewing Planner
//
//  Created by Art on 7/23/24.
//

import SwiftUI
import GRDB

//struct Project: Hashable, Codable, FetchableRecord, PersistableRecord, TableRecord {
struct Project: Hashable, Codable, EncodableRecord, FetchableRecord, MutablePersistableRecord, TableRecord {
    var id: Int64?
    var name: String
    var completed: Bool
    var createDate: Date
    var updateDate: Date
    static let databaseTableName = "project"
    
    mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }
    
    init(id: Int64?, name: String, completed: Bool, createDate: Date, updateDate: Date) {
        self.id = id
        self.name = name
        self.completed = completed
        self.createDate = createDate
        self.updateDate = updateDate
    }

    init() {
        name = ""
        completed = false
        let now = Date()
        createDate = now
        updateDate = now
    }
}

struct ProjectName: View {
    @ObservedObject var project: ProjectData
    @State var projectName: String = ""
    @State var isEditing = false
    
    var body: some View {
        HStack {
            Text(project.data.name)
            if isEditing {
                TextField("Enter project name", text: $projectName).onSubmit {
                    // add a popup telling user that name can't be empty
                    
                    let sanitizedName = projectName.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !sanitizedName.isEmpty else { return }
                    
                    project.updateName(name: sanitizedName)
                    isEditing = false
                }.accessibilityIdentifier("ProjectNameTextfield")
            }
            Button("Edit") {
                projectName = project.data.name
                isEditing.toggle()
            }
        }.onAppear {
            if project.data.name.isEmpty {
                isEditing = true
            }
        }
    }
}
//
//#Preview {
//    ProjectName()
//}
