//
//  ProjectsView.swift
//  Sewing Planner
//
//  Created by Art on 7/9/24.
//

import SwiftUI

// enum Navigation {
//    case allProjects
//    case Project(ProjectViewModel)
// }

let UserCreatedOneProject: String = "CreatedOneProject"

struct ProjectsView: View {
  @Environment(\.appDatabase) private var appDatabase
  @Environment(\.store) private var store
  @Environment(\.settings) var settings

  func fetchProjects() {
    do {
      print("fetching projects")
      let projects = try appDatabase.fetchProjectsAndProjectImage()
      store.projects = ProjectsViewModel(projects: projects)
    } catch {
      store.appError = AppError.projectCards
    }
  }

  var body: some View {
    @Bindable var storeBinding = store
    if case let .some(error) = store.appError {
      // TODO: do this error handling for how to display the toast message
      // add a transition to the toast to come from the top
      switch error {
      case .projectCards:
        Text(
          "Couldn't load projects. Tap button to try reloading again."
        )
        Button("Load Projects") {
          fetchProjects()
          store.appError = nil
        }
      case .loadProject:
        Text("Couldn't load project. Try again.")
      case .addProject:
        Text("Couldn't add project. Try again.")
      case .unexpectedError:
        Text("Something unexpected happen. Contact developer about this.")
      }
    } else {
      NavigationStack(path: $storeBinding.navigation) {
        VStack {
          if !(settings.getUserCreatedProjectFirstTime() ?? false) {
            VStack {
              Text("Welcome to Fabric Stash!")
                .frame(maxWidth: .infinity, alignment: .leading)
                .font(.system(size: 40))
                .padding(.top, 28)
                .padding(.horizontal, 16)

              Text(
                "Get started with a project by tapping New Project below."
              )
              .frame(maxWidth: .infinity, alignment: .leading)
              .font(.system(size: 16))
              .padding(.top, 8)
              .padding(.horizontal, 16)
              Image(
                "vecteezy_crossed-sewing-needles-with-thread-silhouette_"
              )
              .resizable()
              .aspectRatio(contentMode: .fit)
              .padding([.bottom, .horizontal], 68)
            }
            .padding(.horizontal, 12)
          } else {
            ScrollView {
              LazyVStack(alignment: .center, spacing: 12) {
                ForEach(
                  $storeBinding.projects.projectsDisplay,
                  id: \.self.project.id
                ) { $project in
                  ProjectCardView(
                    projectData: project,
                    projectsNavigation: $storeBinding.navigation
                  )
                }
              }
              .padding(.bottom, 12)
            }
          }
        }
        .navigationDestination(for: ProjectMetadata.self) { _ in
          VStack {
            LoadProjectView(
              projectsNavigation: $storeBinding.navigation,
              fetchProjects: fetchProjects
            )
          }
        }
        .toolbar {
          ToolbarItem(placement: .bottomBar) {
            HStack {
              Button("New Project") {
                do {
                  try store.addProject()
                  if !(settings.getUserCreatedProjectFirstTime() ?? false) {
                    do {
                      try settings.userCreatedProjectFirstTime(val: true)
                    } catch {
                      // TODO: log error
                      print(error)
                    }
                  }
                } catch AppError.addProject {
                  store.appError = .addProject
                } catch {
                  store.appError = .unexpectedError
                  print(error)
                }
              }
              .buttonStyle(PrimaryButtonStyle())
              .padding(.bottom, 24)
              .accessibilityIdentifier("AddNewProjectButton")
            }
          }
        }
        .toolbarBackground(.white, for: .bottomBar)
      }
      .navigationTitle("Projects")
      .frame(
        minWidth: 0,
        maxWidth: .infinity,
        minHeight: 0,
        maxHeight: .infinity
      )
      .background(Color.white)
      .task {
        fetchProjects()
      }
    }
  }
}

struct ProjectCardView: View {
  var projectData: ProjectCardViewModel
  @Binding var projectsNavigation: [ProjectMetadata]
  @Environment(\.store) private var store

  var body: some View {
    HStack {
      if !projectData.error {
        MaybeProjectImageView(projectImage: projectData.image)
          .padding(.horizontal, 2)
        HStack(alignment: .firstTextBaseline) {
          Text(projectData.project.name)
            .accessibilityIdentifier("ProjectName")
        }
        .padding([.bottom, .horizontal], 8)
        .frame(
          minWidth: 100,
          maxWidth: .infinity,
          maxHeight: .infinity,
          alignment: .leading
        )
      } else {
        Text("Error loading project image")
        // TODO: add a button or make the card clickable to retry loading the image
      }
    }
    .frame(
      minWidth: 100,
      maxWidth: .infinity,
      minHeight: 200,
      alignment: .center
    )
    .background(
      RoundedRectangle(cornerRadius: 8)
        .stroke(.gray, lineWidth: 1)
        .fill(.white)
        .shadow(radius: 2, y: 5)
    )
    .padding(8)
    .onTapGesture {
      projectsNavigation.append(projectData.project)
    }
  }
}

struct MaybeProjectImageView: View {
  let projectImage: ProjectDisplayImage?

  var body: some View {
    let displayedImage =
      if let imageData = projectImage {
        if let image = imageData.image {
          image
        } else {
          UIImage(named: "vecteezy_sewing-machine-icon-style_8737393")
        }
      } else {
        UIImage(named: "vecteezy_sewing-machine-icon-style_8737393")
      }
    Image(uiImage: displayedImage!)
      .resizable()
      .interpolation(.high)
      .aspectRatio(contentMode: .fit)
      .clipShape(
        RoundedRectangle(cornerRadius: 8)
      )
      .frame(
        minWidth: 100,
        maxWidth: .infinity,
        minHeight: 200,
        alignment: .center
      )
  }
}

#Preview {
  ProjectsView()
}
