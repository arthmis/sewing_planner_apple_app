//
//  ProjectDetailsView.swift
//  Sewing Planner
//
//  Created by Art on 9/12/24.
//

import SwiftUI

struct ProjectDataView: View {
  @Environment(ProjectViewModel.self) var project
  @Environment(\.db) var db

  var body: some View {
    @Bindable var projectBinding = project
    VStack(alignment: .leading) {
      HStack {
        ProjectTitle(
          projectData: projectBinding.projectData.data,
          bindedName: projectBinding.projectData.bindedName,
        )
        Spacer()
      }
      .frame(maxWidth: .infinity)
      .padding(.bottom, 25)
      if project.projectData.sections.isEmpty {
        EmptyProjectCallToActionView()
        Spacer()
      } else {
        ScrollView {
          VStack(alignment: .leading) {
            ForEach($projectBinding.projectData.sections, id: \.id) {
              $section in
              SectionView(model: $section)
                .padding(.bottom, 16)
            }
          }
        }
        .frame(maxHeight: .infinity)
      }
    }
    .padding([.leading, .trailing], 8)
    .confirmationDialog(
      "Delete Section",
      isPresented: $projectBinding.projectData.showDeleteSectionDialog
    ) {
      Button("Delete", role: .destructive) {
        Task {
          await project.handleEffect(
            effect: project.deleteSection(
              selectedSection: project.projectData
                .selectedSectionForDeletion
            ),
            db: db
          )
        }
      }
      Button("Cancel", role: .cancel) {
        project.projectData.cancelDeleteSection()
      }
    } message: {
      if let section = project.projectData.selectedSectionForDeletion {
        Text("Delete \(section.name)")
      }
    }
  }

  struct EmptyProjectCallToActionView: View {
    @Environment(ProjectViewModel.self) var project

    var body: some View {
      VStack(alignment: .leading, spacing: 0) {
        Image(systemName: "list.bullet.rectangle")
          .font(.system(size: 32, weight: .light))
        Text("Sections")
          .font(.system(size: 20, weight: .semibold))
          .padding(.top, 20)

        Text(
          "Create sections to organize and define the important tasks and details of your project."
        )
        .frame(maxWidth: .infinity, alignment: .leading)
        .font(.system(size: 16))
        .padding(.top, 8)
        Button("Create new section") {
          project.addSection()
        }
        .buttonStyle(PrimaryButtonStyle(fontSize: 16))
        .padding(.top, 28)
      }
    }

  }
}

#Preview {
  let viewModel = ProjectViewModel(
    data: ProjectData(
      data: ProjectMetadata(
        id: 1,
        name: "Project Name",
        completed: false,
        createDate: Date(),
        updateDate: Date()
      )
    ),
    projectsNavigation: [],
    projectImages: ProjectImages(projectId: 1)
  )
  ProjectDataView()
    .environment(viewModel)

}
