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
        VStack {
            ProjectName(project: project)
            VStack {
                ForEach(projectSections.sections, id: \.id) { section in
                    SectionView(data: section)
                }
            }
            Button {
                projectSections.addSection()
            } label: {
                Image(systemName: "plus")
            }.padding(40)
        }
    }
}

//#Preview {
//    ProjectDetails()
//}
