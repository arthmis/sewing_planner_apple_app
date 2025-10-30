//
//  ProjectDetailsView.swift
//  Sewing Planner
//
//  Created by Art on 9/12/24.
//

import SwiftUI

struct ProjectDataView: View {
    @Environment(ProjectViewModel.self) var project
    @Environment(\.appDatabase) var db

    var body: some View {
        @Bindable var projectBinding = project
        VStack(alignment: .leading) {
            HStack {
                ProjectTitle(
                    projectData: $projectBinding.projectData.data,
                    bindedName: $projectBinding.projectData.bindedName,
                    updateName: project.projectData.updateName
                )
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 25)
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
}

// #Preview {
//    ProjectDetails(project: ProjectData(
//    data: Project(id: 2, name: "Project Name", completed: false, createDate: Date(), updateDate: Date())), projectSections: ProjectSections(), projectsNavigation: [Project()])
// }
