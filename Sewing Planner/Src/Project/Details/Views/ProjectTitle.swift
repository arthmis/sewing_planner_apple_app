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
  @State private var size: CGFloat = 0

  private func sanitize(_ val: String) -> String {
    return val.trimmingCharacters(in: .whitespacesAndNewlines)
  }

  private func saveNewName() {
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
  var body: some View {
    HStack {
      Text(projectData.name)
        .font(.custom("SourceSans3-Medium", size: 18))
        .frame(maxWidth: .infinity, alignment: .leading)
        .contentShape(Rectangle())
        .onTapGesture {
          if !isEditing {
            bindedName = projectData.name
            isEditing.toggle()
          }
        }
        .sheet(isPresented: $isEditing) {
          print("is canceling editing")
          isEditing = false
        } content: {
          VStack {
            HStack {
              Spacer()
              Button {
                isEditing = false
              } label: {
                Image(systemName: "xmark.circle.fill")
                  .font(.system(size: 32))
                  .foregroundStyle(.gray)
              }
              .padding(.top, 12)
            }
            TextField("Project Name", text: $bindedName)
              .onSubmit {
                saveNewName()
              }
              .textFieldStyle(.automatic)
              .padding(.vertical, 12)
              .font(.custom("SourceSans3-Medium", size: 20))
              .accessibilityIdentifier("ProjectNameTextfield")
              .overlay(
                Rectangle()
                  .frame(maxWidth: .infinity, maxHeight: 1)
                  .foregroundStyle(Color.gray.opacity(0.5)),
                alignment: .bottom
              )
            Button("Save") {
              saveNewName()
            }
            .buttonStyle(SheetPrimaryButtonStyle())
            .font(.system(size: 20))
            .padding(.top, 12)
          }
          .padding(12)
          .onGeometryChange(for: CGFloat.self) { proxy in
            proxy.size.height
          } action: { newValue in
            size = newValue
          }
          .presentationDetents([.height(size)])
        }
        .accessibilityIdentifier("ProjectName")
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

//  #Preview {
//      @Previewable @State var project = ProjectViewModel(
//        data: ProjectData(
//          data: ProjectMetadata(
//            id: 1, name: "Project Name", completed: false, createDate: Date(), updateDate: Date())),
//        projectsNavigation: [], projectImages: ProjectImages(projectId: 1, images: []))
// //     @Environment(\.appDatabase) var db
//      @Previewable @State var bindedName = "Project Name"
//      @Previewable @State var isEditing = true
//      let projectData = ProjectMetadata(
//            id: 1, name: "Project Name", completed: false, createDate: Date(), updateDate: Date())

//      ProjectTitle(projectData: projectData, bindedName: bindedName, isEditing: isEditing)
//          .environment(project)
//          .frame(
//            maxWidth: .infinity,
//            maxHeight: .infinity,
//          )
//          .background(.white)
//  }
