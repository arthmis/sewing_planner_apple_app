//
//  SwiftUIView.swift
//  Sewing Planner
//
//  Created by Art on 7/9/24.
//

import SwiftUI

struct ProjectsView: View {
    @Environment(\.appDatabase) private var appDatabase
    @State var model = ProjectsViewModel()
    let columns = [GridItem(.adaptive(minimum: 200, maximum: 300))]

    func fetchProjects() {
        do {
            print("fetching projects")
            model.projectsDisplay = try appDatabase.fetchProjectsAndProjectImage()
        } catch {
            fatalError("error: \(error)")
        }
    }

    var body: some View {
        NavigationStack(path: $model.projects) {
            VStack {
                HStack {
                    Button("New Project") {
                        do {
                            try model.addProject()
                        } catch {
                            fatalError("\(error)")
                        }
                    }
                    .accessibilityIdentifier("AddNewProjectButton")
                }

                ScrollView {
                    LazyVGrid(columns: columns) {
                        ForEach($model.projectsDisplay, id: \.self.project.id) { $project in
                            ProjectDisplayView(
                                projectData: project, projects: $model.projects
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
                    ProjectView(projectsNavigation: $model.projects, fetchProjects: fetchProjects)
                }
            }
        }
        .navigationTitle("Projects")
        .frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity)
        .background(Color.white)
    }
}

struct ProjectDisplayView: View {
    var projectData: ProjectDisplay
    @Binding var projects: [ProjectMetadata]

    var body: some View {
        VStack {
            MaybeProjectImageView(projectImage: projectData.image)
            Text(projectData.project.name)
                .accessibilityIdentifier("ProjectName")
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
    let projectImage: ProjectDisplayImage?

    var body: some View {
        if let imageData = projectImage {
            if let image = imageData.image {
                Image(uiImage: image)
                    .resizable()
                    .interpolation(.high)
                    .scaledToFit()
                    .frame(width: 120, height: 120, alignment: .center)
            }
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
