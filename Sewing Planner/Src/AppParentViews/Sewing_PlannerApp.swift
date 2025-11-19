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
  @Environment(\.db) var db
  @State private var settings: UserSettings

  // runs before app launch
  // register initial UserDefaults values every launch
  init() {
    let logger = AppLogger(label: "app_logger")
    settings = UserSettings(settingsDirectory: "App Settings", logger: logger)
  }

  var body: some Scene {
    WindowGroup {
      ContentView(store: Store(db: db))
        .environment(\.settings, settings)
    }
  }
}

extension EnvironmentValues {
  @Entry var db = AppDatabase.db()
  @Entry var appLogger = AppLogger(label: "app logger")
}

extension EnvironmentValues {
  var settings: UserSettings {
    get { self[SettingsKey.self] }
    set { self[SettingsKey.self] = newValue }
  }
}

private struct SettingsKey: EnvironmentKey {
  static let defaultValue: UserSettings = .init(
    settingsDirectory: "App Settings",
    logger: AppLogger(label: "app_logger")
  )
}
