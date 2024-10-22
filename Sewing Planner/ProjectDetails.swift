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
    var modelSaveProject: () throws -> Int64
    @Binding var projectsNavigation: [Project]

    private var isProjectValid: Bool {
        !project.data.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func saveProject() {
        guard isProjectValid else {
            return
        }

        do {
            let projectId = try modelSaveProject()
        } catch {
            fatalError(
                "error adding steps and materials for project id: \(project.data.id)\n\n\(error)")
        }
        projectsNavigation.removeLast()
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                ProjectName(project: project)
                Spacer()
                Button("Save Project") {
                    saveProject()
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
            .buttonStyle(AddNewSectionButtonStyle())
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
