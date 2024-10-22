//
//  ProjectName.swift
//  Sewing Planner
//
//  Created by Art on 7/23/24.
//

import GRDB
import SwiftUI

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
        name = "Project Name"
        completed = false
        let now = Date()
        createDate = now
        updateDate = now
    }
}

enum ProjectColumns: String, ColumnExpression {
    case id
    case name
    case completed
    case updateDate
    case createDate
}

class ProjectData: ObservableObject {
    @Published var data = Project()
    @Published var tempName = ""

    init() {}

    init(data: Project) {
        self.data = data
    }

    func updateName(name: String) {
        data.name = name
    }
}

struct ProjectName: View {
    @ObservedObject var project: ProjectData
    @State var isEditing = false

    var body: some View {
        HStack {
            if isEditing {
                TextField("Enter project name", text: $project.data.name).onSubmit {
                    // add a popup telling user that name can't be empty

                    let sanitizedName = project.data.name.trimmingCharacters(in: .whitespacesAndNewlines)
                    guard !sanitizedName.isEmpty else { return }

                    project.updateName(name: sanitizedName)
                    isEditing = false
                }.accessibilityIdentifier("ProjectNameTextfield")
                Button("Cancel") {
                    project.data.name = project.tempName
                    isEditing = false
                }
            } else {
                Text(project.data.name)
                    .font(.custom("CooperHewitt-medium", size: 20))
                    .onTapGesture {
                        if !isEditing {
                            project.tempName = project.data.name
                            isEditing.toggle()
                        }
                    }
            }
        }.onAppear {
            if project.data.name != "" {
                project.tempName = project.data.name
            }
        }
    }
}

#Preview {
    ProjectName(project: ProjectData(data: Project(id: 2, name: "Project Name", completed: false, createDate: Date(), updateDate: Date())))
}
