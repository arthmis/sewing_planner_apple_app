//
//  Sewing_PlannerApp.swift
//  Sewing Planner
//
//  Created by Art on 5/9/24.
//

import GRDB
import PhotosUI
import SwiftUI

@main
struct Sewing_PlannerApp: App {
    @State private var store = Store()
    @State private var settings: UserSettings
    let db: AppDatabase = .db()

    // runs before app launch
    // register initial UserDefaults values every launch
    init() {
        let logger = AppLogger(label: "app_logger")
        settings = UserSettings(settingsDirectory: "App Settings", logger: logger)
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.appDatabase, db)
                .environment(\.store, store)
                .environment(\.settings, settings)
        }
    }
}

extension EnvironmentValues {
    var settings: UserSettings {
        get { self[SettingsKey.self] }
        set { self[SettingsKey.self] = newValue }
    }
}

private struct SettingsKey: EnvironmentKey {
    static let defaultValue: UserSettings = .init(settingsDirectory: "App Settings",  logger: AppLogger(label: "app_logger"))
}

extension EnvironmentValues {
    var store: Store {
        get { self[StoreKey.self] }
        set { self[StoreKey.self] = newValue }
    }
}

private struct StoreKey: EnvironmentKey {
    static let defaultValue: Store = .init()
}

@Observable
class Store {
    var projects: ProjectsViewModel
    var navigation: [ProjectMetadata] = []
    var selectedProject: ProjectViewModel?
    var appError: AppError?
    let db: AppDatabase = .db()

    init() {
        projects = ProjectsViewModel()
    }

    func addProject() throws(AppError) {
        do {
            try db.getWriter().write { db in
                var newProjectInput = ProjectMetadataInput()
                try newProjectInput.save(db)

                let newProject = ProjectMetadata(from: newProjectInput)
                navigation.append(newProject)

                try updateShareExtensionProjectList(project: newProject)
            }
        } catch {
            throw AppError.addProject
        }
    }

    private func updateShareExtensionProjectList(project: ProjectMetadata) throws {
        let fileData = try SharedPersistence().getFile(fileName: "projects")
        guard let data = fileData else {
            let projectsList = [SharedProject(id: project.id, name: project.name)]
            let encoder = JSONEncoder()
            let updatedProjectsList = try encoder.encode(projectsList)
            try SharedPersistence().writeFile(data: updatedProjectsList, fileName: "projects")

            return
        }

        let decoder = JSONDecoder()
        guard var projectsList = try? decoder.decode([SharedProject].self, from: data) else {
            throw ShareError.emptyFile("Couldn't get shared projects list file")
        }

        projectsList.append(SharedProject(id: project.id, name: project.name))
        let encoder = JSONEncoder()
        let updatedProjectsList = try encoder.encode(projectsList)
        try SharedPersistence().writeFile(data: updatedProjectsList, fileName: "projects")
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

enum AppError: Error {
    case projectCards
    case loadProject
    case addProject
    case unexpectedError
}
