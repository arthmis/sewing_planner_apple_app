//
//  ProjectDetails.swift
//  Sewing Planner
//
//  Created by Art on 9/12/24.
//

import SwiftUI

struct ProjectDetails: View {
    @ObservedObject var project: ProjectData
    @ObservedObject var projectSections: ProjectSections
    @Binding var projectsNavigation: [Project]

    var body: some View {
//        ScrollView {
        VStack(alignment: .leading) {
            HStack {
                ProjectName(project: project)
                Spacer()
                Button("Save") {
                    print("saving project")
                }.accessibilityIdentifier("SaveButton")
            }
            .frame(maxWidth: .infinity)
//                ScrollView {

            VStack(alignment: .leading) {
                ForEach(projectSections.sections, id: \.id) { section in
                    SectionView(data: section)
                }
            }
            .frame(maxWidth: .infinity)
//                }
            Button {
                projectSections.addSection()
            } label: {
                Image(systemName: "plus")
            }
        }
        .padding(50)
//        }
    }
}

// #Preview {
//    ProjectDetails(project: ProjectData(
//    data: Project(id: 2, name: "Project Name", completed: false, createDate: Date(), updateDate: Date())), projectSections: ProjectSections(), projectsNavigation: [Project()])
// }
