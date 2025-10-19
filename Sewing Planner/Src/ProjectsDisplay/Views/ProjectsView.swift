//
//  SwiftUIView.swift
//  Sewing Planner
//
//  Created by Art on 7/9/24.
//

import SwiftUI

//enum Navigation {
//    case allProjects
//    case Project(ProjectViewModel)
//}

struct ProjectsView: View {
    @Environment(\.appDatabase) private var appDatabase
    @Environment(\.store) private var store
    let columns = [
        GridItem(.flexible(minimum: 100, maximum: 400), spacing: 4),
        GridItem(.flexible(minimum: 100, maximum: 400), spacing: 4),
    ]

    func fetchProjects() {
        do {
            print("fetching projects")
            // model.projectsDisplay = try appDatabase.fetchProjectsAndProjectImage()
            let projects = try appDatabase.fetchProjectsAndProjectImage()
            store.projects = ProjectsViewModel(projects: projects)
        } catch {
            fatalError("error: \(error)")
        }
    }

    var body: some View {
        @Bindable var storeBinding = store
        NavigationStack(path: $storeBinding.navigation) {
            VStack {
                ScrollView {
                    LazyVGrid(columns: columns, spacing: 12) {
                        ForEach($storeBinding.projects.projectsDisplay, id: \.self.project.id) { $project in
                            ProjectDisplayView(
                                projectData: project, projects: $storeBinding.navigation
                            )
                        }
                    }
                    .task {
                        fetchProjects()
                    }
                    .padding(.bottom, 12)
                }
            }
            .navigationDestination(for: ProjectMetadata.self) { _ in
                VStack {
                    ProjectView(projectsNavigation: $storeBinding.navigation, fetchProjects: fetchProjects)
                }
            }
            .padding(.horizontal, 8)
            .padding(.bottom, 12)
            .padding(.top, 16)
            .toolbar {
                ToolbarItem(placement: .bottomBar) {
                    HStack {
                        Button("New Project") {
                            do {
                                try store.addProject()
                            } catch {
                                fatalError("\(error)")
                            }
                        }
                        .accessibilityIdentifier("AddNewProjectButton")
                    }
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
    @Environment(\.store) private var store

    var body: some View {
        VStack {
            MaybeProjectImageView(projectImage: projectData.image)
            HStack(alignment: .firstTextBaseline) {
                Text(projectData.project.name)
                    .accessibilityIdentifier("ProjectName")
            }
            .padding([.bottom, .leading], 8)
            .frame(minWidth: 100, maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
        }
        .frame(minWidth: 100, maxWidth: .infinity, minHeight: 200, alignment: .center)
        .background(Color.white)
        .cornerRadius(8)
        .shadow(radius: 2, y: 5)
        .padding(4)
        .onTapGesture {
            projects.append(projectData.project)
        }
    }
}

struct MaybeProjectImageView: View {
    let projectImage: ProjectDisplayImage?

    var body: some View {
        let displayedImage = if let imageData = projectImage {
            imageData.image!
        } else {
            UIImage(named: "black_dress_sketch")
        }
        Image(uiImage: displayedImage!)
            .resizable()
            .interpolation(.high)
            .aspectRatio(contentMode: .fill)
            .clipped()
            .frame(minWidth: 100, maxWidth: .infinity, minHeight: 200, alignment: .center)
//        if let imageData = projectImage {
//            if let image = imageData.image {
//                Image(uiImage: image)
//                    .resizable()
//                    .interpolation(.high)
//                    .aspectRatio(contentMode: .fill)
        ////                    .scaledToFit()
        ////                    .frame(minWidth: 100, maxWidth: .infinity, minHeight: 200, alignment: .center)
//                    .clipped()
//                    .frame(width: 120, height: 120, alignment: .center)
//            }
//        } else {
//            Image("black_dress_sketch")
//                .resizable()
//                .interpolation(.high)
//                .aspectRatio(contentMode: .fill)
        ////                .scaledToFit()
//                .clipped()
//                .frame(width: 120, height: 120, alignment: .center)
//        }
    }
}

#Preview {
    ProjectsView()
}
