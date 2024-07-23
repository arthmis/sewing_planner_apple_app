//
//  ProjectName.swift
//  Sewing Planner
//
//  Created by Art on 7/23/24.
//

import SwiftUI

struct Project: Hashable {
    var name = "New Project"
    var id: Int64 = 0
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
                    do {
                        try appDatabase.updateProjectName(name: projectName, projectId: project.id)
                    } catch {
                        fatalError("error when updating name: \(projectName) for project id: \(project.id)\n\n\(error)")
                    }
                    project.name = projectName
                    isEditing = false
                }.accessibilityIdentifier("ProjectNameTextfield")
            }
            Button("Edit") {
                if isEditing {
                    projectName = ""
                }
                
                isEditing.toggle()
            }
        }
    }
}
//
//#Preview {
//    ProjectName()
//}
