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
  @Environment(\.appDatabase) var db
  var projectData: ProjectMetadata
  @State var bindedName: String
  @State var isEditing = false

  private func sanitize(_ val: String) -> String {
    return val.trimmingCharacters(in: .whitespacesAndNewlines)
  }
  var body: some View {
    HStack {
      if isEditing {
        TextField("", text: $bindedName)
          .onSubmit {
            let sanitizedName = sanitize(bindedName)
            guard !sanitizedName.isEmpty else {
              // show an error message
              return
            }

            let event = project.handleEvent(event: .UpdatedProjectTitle(sanitizedName))
            Task {
              await project.handleEffect(effect: event, db: db)
            }
            isEditing = false
          }
          .textFieldStyle(.plain)
          .padding(.bottom, 5)
          .overlay(
            Rectangle()
              .fill(Color(hex: 0x131944, opacity: 0.9))
              .frame(maxWidth: .infinity, maxHeight: 5),
            alignment: .bottom
          )
          .font(.custom("SourceSans3-Medium", size: 14))
          .accessibilityIdentifier("ProjectNameTextfield")
        Button("Cancel") {
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
          .overlay(
            Rectangle()
              // .fill(Color(hex: 0x131944, opacity: isHovering ? 1 : 0))
              .frame(maxWidth: .infinity, maxHeight: 2),
            alignment: .bottom
          )
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
