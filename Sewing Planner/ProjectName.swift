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
    @Environment(\.appDatabase) private var appDatabase
    @Binding var project: Project
    @State var projectName: String = ""
    @State var isEditing = false
    
    var body: some View {
        HStack {
            Text(project.name)
            if isEditing {
                TextField("Enter project name", text: $projectName).onSubmit {
                    print("\(project.name)")
                    // add a popup telling user that name can't be empty
                    guard !projectName.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
                    project.name = projectName
                    isEditing = false
                }.accessibilityIdentifier("ProjectNameTextfield")
            }
            Button("Edit") {
                projectName = project.name
                isEditing.toggle()
            }
        }.onAppear {
            if project.name.isEmpty {
                isEditing = true
            }
        }
    }
}
//
//#Preview {
//    ProjectName()
//}
