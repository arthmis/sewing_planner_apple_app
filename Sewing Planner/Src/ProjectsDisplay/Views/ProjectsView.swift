//
//  SwiftUIView.swift
//  Sewing Planner
//
//  Created by Art on 7/9/24.
//

import SwiftUI

struct ProjectsView: View {
    @Environment(\.appDatabase) private var appDatabase
    @State var projects: [ProjectMetadata] = []
    @State var projectsDisplay: [ProjectDisplay] = []
    let columns = [GridItem(.adaptive(minimum: 200, maximum: 300))]

    var body: some View {
        NavigationStack(path: $projects) {
            VStack {
                HStack {
                    Button("New Project") {
                        projects.append(ProjectMetadata())
                    }
                    .accessibilityIdentifier("AddNewProjectButton")
                }

                ScrollView {
                    LazyVGrid(columns: columns) {
                        ForEach(projectsDisplay, id: \.self.project.id) { project in
                            ProjectDisplayView(
                                projectData: project, projects: $projects
                            )
                        }
                    }
                    .task {
                        fetchProjects()
                    }
                }
            }
            .navigationDestination(for: ProjectMetadata.self) { project in
                VStack {
                    ProjectView(projectId: project.id, projectsNavigation: $projects)
                }
            }
        }
        .navigationTitle("Projects")
        .frame(minWidth: 600, minHeight: 300)
        .background(Color.white)
    }

    func fetchProjects() {
        do {
            projectsDisplay = try appDatabase.fetchProjectsAndProjectImage()
        } catch {
            print("error: \(error)")
        }
    }
}

struct ProjectDisplayView: View {
    var projectData: ProjectDisplay
    @Binding var projects: [ProjectMetadata]

    var body: some View {
        VStack {
            MaybeProjectImageView(projectImage: projectData.image)
            Text(projectData.project.name)
        }
        .padding(10)
        .frame(minWidth: 50, minHeight: 50)
        .background(Color.white)
        .cornerRadius(9)
        .shadow(radius: 4, y: 5)
        // apply a rounded border
        .overlay(
            RoundedRectangle(cornerRadius: 9)
                .strokeBorder(Color.gray, lineWidth: 1)
        )
        .padding(20)
        .onTapGesture {
            projects.append(projectData.project)
        }
    }
}

struct MaybeProjectImageView: View {
    let projectImage: ProjectImage?

    var body: some View {
        if projectImage != nil {
            Image(nsImage: (projectImage?.image)!)
                .resizable()
                .interpolation(.high)
                .scaledToFit()
                .frame(width: 120, height: 120, alignment: .center)
        } else {
            Image("black_dress_sketch")
                .resizable()
                .interpolation(.high)
                .scaledToFit()
                .frame(width: 120, height: 120, alignment: .center)
        }
    }
}

#Preview {
    ProjectsView()
}
