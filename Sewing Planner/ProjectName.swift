//
//  ProjectName.swift
//  Sewing Planner
//
//  Created by Art on 7/23/24.
//

import AppKit
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
    @Published var bindedName = ""

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
    @FocusState var headerFocus: Bool

    var body: some View {
        HStack {
            if isEditing {
                TextField("", text: $project.bindedName)
                    .onSubmit {
                        // add a popup telling user that name can't be empty

                        let sanitizedName = project.bindedName.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !sanitizedName.isEmpty else { return }
                        
                        project.updateName(name: sanitizedName)
                        isEditing = false
                    }
                    .focused($headerFocus)
                    .onChange(of: headerFocus) { _, newFocus in
                        if !newFocus {
                            let sanitizedName = project.data.name.trimmingCharacters(in: .whitespacesAndNewlines)
                            guard !sanitizedName.isEmpty else { return }

                            project.updateName(name: sanitizedName)
                            isEditing = false
                        }
                    }
                    .textFieldStyle(.plain)
                    .padding(.bottom, 5)
                    .overlay(Rectangle()
                        .fill(.gray)
                        .frame(maxWidth: .infinity, maxHeight: 5),
                        alignment: .bottom)
                    .font(.custom("SourceSans3-Medium", size: 20))
                    .accessibilityIdentifier("ProjectNameTextfield")
                Button("Cancel") {
                    project.data.name = project.bindedName
                    isEditing = false
                }
            } else {
                Text(project.data.name)
                    .onTapGesture {
                        if !isEditing {
                            project.bindedName = project.data.name
                            isEditing.toggle()
                            headerFocus = true
                        }
                    }
                    .font(.custom("SourceSans3-Medium", size: 20))
            }
        }
        .onAppear {
            if project.data.name != "" {
                project.bindedName = project.data.name
            }
        }
    }
}

#Preview {
    ProjectName(project: ProjectData(data: Project(id: 2, name: "Project Name", completed: false, createDate: Date(), updateDate: Date())))
        .frame(width: 300, height: 300)
        .background(Color.white)
}
