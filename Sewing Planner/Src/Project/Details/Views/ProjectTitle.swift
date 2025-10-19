//
//  ProjectName.swift
//  Sewing Planner
//
//  Created by Art on 7/23/24.
//

import GRDB
import SwiftUI

struct ProjectTitle: View {
    @Binding var project: ProjectMetadataViewModel
    @State var isEditing = false
    @FocusState var headerFocus: Bool
    @State var isHovering = false

    var body: some View {
        HStack {
            if isEditing {
                TextField("", text: $project.bindedName)
                    .onSubmit {
                        // add a popup telling user that name can't be empty

                        let sanitizedName = project.bindedName.trimmingCharacters(in: .whitespacesAndNewlines)
                        guard !sanitizedName.isEmpty else { return }

                        do {
                            try project.updateName(name: sanitizedName)
                        } catch {
                            fatalError("\(error)")
                        }
                        isEditing = false
                    }
                    .focused($headerFocus)
                    .onChange(of: headerFocus) { _, newFocus in
                        if !newFocus {
                            let sanitizedName = project.data.name.trimmingCharacters(in: .whitespacesAndNewlines)
                            guard !sanitizedName.isEmpty else { return }

                            do {
                                try project.updateName(name: sanitizedName)
                            } catch {
                                fatalError("\(error)")
                            }
                            isEditing = false
                        }
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
                    project.data.name = project.bindedName
                    isEditing = false
                }
            } else {
                Text(project.data.name)
                    .font(.custom("SourceSans3-Medium", size: 14))
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .contentShape(Rectangle())
                    .onTapGesture {
                        if !isEditing {
                            project.bindedName = project.data.name
                            isEditing.toggle()
                            headerFocus = true
                        }
                    }
                    .onHover { hover in
                        isHovering = hover
                    }
                    .overlay(Rectangle()
                        .fill(Color(hex: 0x131944, opacity: isHovering ? 1 : 0))
                        .frame(maxWidth: .infinity, maxHeight: 2),
                        alignment: .bottom)
                    .accessibilityIdentifier("ProjectName")
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.top, 16)
        .onAppear {
            if project.data.name != "" {
                project.bindedName = project.data.name
            }
        }
    }
}

// #Preview {
//    ProjectName(project: ProjectMetadataViewModel(data: ProjectMetadata(id: 2, name: "Project Name", completed: false, createDate: Date(), updateDate: Date())))
//        .frame(width: 300, height: 300)
//        .background(Color.white)
// }
