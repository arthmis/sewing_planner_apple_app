//
//  ProjectTitle.swift
//  Sewing Planner
//
//  Created by Art on 7/23/24.
//

import GRDB
import SwiftUI

struct ProjectTitle: View {
    @Environment(ProjectViewModel.self) var project
    @Binding var projectData: ProjectMetadata
    @Binding var bindedName: String
    var updateName: (String) throws -> Void
    @State var isEditing = false

    var body: some View {
        HStack {
            if isEditing {
                TextField("", text: $bindedName)
                    .onSubmit {
                        // TODO: add a popup telling user that name can't be empty
                        let sanitizedName = bindedName.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !sanitizedName.isEmpty else { return }

                        do {
                            try updateName(sanitizedName)
                        } catch {
                            project.handleError(error: .renameProject)
                        }
                        isEditing = false
                    }
                    .textFieldStyle(.plain)
                    .padding(.bottom, 5)
                    .overlay(Rectangle()
                        .fill(Color(hex: 0x131944, opacity: 0.9))
                        .frame(maxWidth: .infinity, maxHeight: 5),
                        alignment: .bottom)
                    .font(.custom("SourceSans3-Medium", size: 14))
                    .accessibilityIdentifier("ProjectNameTextfield")
                Button("Cancel") {
                    projectData.name = bindedName
                    isEditing = false
                }
            } else {
                Text(projectData.name)
                    .font(.custom("SourceSans3-Medium", size: 14))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if !isEditing {
                            bindedName = projectData.name
                            isEditing.toggle()
                        }
                    }
                    .overlay(Rectangle()
                        // .fill(Color(hex: 0x131944, opacity: isHovering ? 1 : 0))
                        .frame(maxWidth: .infinity, maxHeight: 2),
                        alignment: .bottom)
                    .accessibilityIdentifier("ProjectName")
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 16)
        .onAppear {
            if projectData.name != "" {
                bindedName = projectData.name
            }
        }
    }
}

// #Preview {
//    ProjectName(project: ProjectMetadataViewModel(data: ProjectMetadata(id: 2, name: "Project Name", completed: false, createDate: Date(), updateDate: Date())))
//        .frame(width: 300, height: 300)
//        .background(Color.white)
// }
