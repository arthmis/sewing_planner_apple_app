//
//  SwiftUIView.swift
//  Sewing Planner
//
//  Created by Art on 7/9/24.
//

import SwiftUI

struct ProjectsView: View {
    @Environment(\.appDatabase) private var appDatabase
    @State var data: [ProjectStepPreviewData]
    @State var projects: [Project] = []
    var body: some View {
        NavigationStack(path: $projects) {
            HStack {
                Button("New Project") {
                    projects.append(Project())
                }
                .navigationDestination(for: Project.self) { project in
                    NewProjectView(projectsNavigation: $projects)
                    //                    NavigationLink(value: NewProjectView(isAddingProject: $isAddingProject), isActive: $isAddingProject)  {
                    //                    NewProjectView(
                    //                }
                }
                .accessibilityIdentifier("AddNewProjectButton")
//                NavigationLink("New Project", value: Project())
                //                NavigationLink(value: NewProjectView(isAddingProject: $isAddingProject), isActive: $isAddingProject)  {
                //                    Text("New Project")
                //                }
            }
            
            //                NavigationLink {
            //                    NewProjectView()
            //                } label: {
            //                    Text("New Project")
            //                }.accessibilityIdentifier("AddNewProjectButton")
            HStack {
                Image("Landscape_4")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 300)
                UnfinishedSteps(projectSteps: data)
                
            }.overlay(
                RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/)
                    .stroke(Color.blue, lineWidth: 1)
            )
            .frame(width: 300, height: 300)
            .navigationTitle("Projects")
        }
        .navigationTitle("Projects")
    }
}


#Preview {
    ProjectsView(data: [])
}
