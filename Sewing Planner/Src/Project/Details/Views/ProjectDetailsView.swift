//
//  ProjectDetails.swift
//  Sewing Planner
//
//  Created by Art on 9/12/24.
//

import SwiftUI

struct ProjectDetailsView: View {
    @Binding var project: ProjectMetadataViewModel
    @Binding var projectSections: ProjectSections

    private var isProjectValid: Bool {
        !project.data.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                ProjectTitle(project: $project)
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
        }
    }
}

// #Preview {
//    ProjectDetails(project: ProjectData(
//    data: Project(id: 2, name: "Project Name", completed: false, createDate: Date(), updateDate: Date())), projectSections: ProjectSections(), projectsNavigation: [Project()])
// }
