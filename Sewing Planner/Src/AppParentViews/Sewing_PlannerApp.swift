//
//  Sewing_PlannerApp.swift
//  Sewing Planner
//
//  Created by Art on 5/9/24.
//

import GRDB
import SwiftUI
import PhotosUI

@main
struct Sewing_PlannerApp: App {
    @State private var store = Store()
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.appDatabase, .db())
                .environment(\.store, store)
        }
    }
}

extension EnvironmentValues {
    var store: Store {
        get { self[StoreKey.self] }
        set { self[StoreKey.self] = newValue }
    }
}

private struct StoreKey: EnvironmentKey {
    static let defaultValue: Store = Store()
}

@Observable
class Store {
    var projects: ProjectsViewModel
    var selectedProject: ProjectViewModel?

    init() {
        self.projects = ProjectsViewModel()

    }
}

class ProjectViewModel {
    var model: ProjectDetailData
    var projectsNavigation: [ProjectMetadata]
    // let fetchProjects: () -> Void
    var currentView = CurrentView.details
    var name = ""
    var showAddTextboxPopup = false
    var doesProjectHaveName = false
    var isLoading = true
    private var pickerItem: PhotosPickerItem?
    private var photosAppSelectedImage: Data?
    private var showPhotoPicker = false

    init(data: ProjectDetailData, projectsNavigation: [ProjectMetadata]) {
        self.model = data
        self.projectsNavigation = projectsNavigation
    }

    static func getProject(projectId: Int64, db: AppDatabase) throws -> ProjectViewModel {
        let projectData = try! ProjectDetailData.getProject(with: projectId, from: db)
        return ProjectViewModel(data: projectData!, projectsNavigation: [])
    }
}

private struct AppDatabaseKey: EnvironmentKey {
    static var defaultValue: AppDatabase { .db() }
}

extension EnvironmentValues {
    var appDatabase: AppDatabase {
        get { self[AppDatabaseKey.self] }
        set { self[AppDatabaseKey.self] = newValue }
    }
}
