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
        VStack(alignment: .leading) {
            HStack {
                ProjectName(project: project)
                Spacer()
                Button(project.data.id != nil ? "Save Changes" : "Save Project") {
                    print("saving project")
                }
                .buttonStyle(SaveProjectButtonStyle())
                .accessibilityIdentifier("SaveButton")
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 25)
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach(projectSections.sections, id: \.id) { section in
                        SectionView(data: section)
                            .padding(.bottom, 20)
                    }
                }
            }
            .frame(maxHeight: .infinity)
            Spacer()
            Button {
                projectSections.addSection()
            } label: {
                Image(systemName: "plus")
            }
            .frame(maxWidth: .infinity, alignment: .trailing)
        }
        .padding([.leading, .trailing], 50)
        .padding([.top, .bottom], 20)
    }
}

// #Preview {
//    ProjectDetails(project: ProjectData(
//    data: Project(id: 2, name: "Project Name", completed: false, createDate: Date(), updateDate: Date())), projectSections: ProjectSections(), projectsNavigation: [Project()])
// }
