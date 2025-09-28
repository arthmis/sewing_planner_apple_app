//
//  ProjectDetails.swift
//  Sewing Planner
//
//  Created by Art on 9/12/24.
//

import SwiftUI

struct ProjectDetails: View {
    @Binding var project: ProjectMetadataViewModel
    @Binding var projectSections: ProjectSections
    @Binding var projectsNavigation: [ProjectMetadata]

    private var isProjectValid: Bool {
        !project.data.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                ProjectName(project: $project)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 25)
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach($projectSections.sections, id: \.id) { $section in
                        SectionView(data: $section)
                            .padding(.bottom, 16)
                    }
                }
            }
            .frame(maxHeight: .infinity)
        }
        .padding([.leading, .trailing], 8)
        .toolbar {
            ToolbarItemGroup(placement: .bottomBar) {
                Button {
                    do {
                        try projectSections.addSection(projectId: project.data.id!)
                    } catch {
                        fatalError("\(error)")
                    }
                } label: {
                    Image(systemName: "plus")
                }
//                .buttonStyle(AddNewSectionButtonStyle())
                .accessibilityIdentifier("AddNewSectionButton")
//                .frame(maxWidth: .infinity, alignment: .trailing)
                Button {} label: {
                    Image(systemName: "photo.artframe")
                }
            }
//            ToolbarItem(placement: .bottomBar) {
//            }
        }
    }
}

// #Preview {
//    ProjectDetails(project: ProjectData(
//    data: Project(id: 2, name: "Project Name", completed: false, createDate: Date(), updateDate: Date())), projectSections: ProjectSections(), projectsNavigation: [Project()])
// }
