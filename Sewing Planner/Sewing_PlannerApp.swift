//
//  Sewing_PlannerApp.swift
//  Sewing Planner
//
//  Created by Art on 5/9/24.
//

import GRDB
import SwiftUI

@main
struct Sewing_PlannerApp: App {
  var body: some Scene {
    WindowGroup {
      ContentView().environment(\.appDatabase, .db)
            .frame(minWidth: 350, minHeight: 350)
    }.windowResizability(.contentSize)
  }
}

private struct AppDatabaseKey: EnvironmentKey {
  static var defaultValue: AppDatabase { .db }
}

extension EnvironmentValues {
  var appDatabase: AppDatabase {
    get { self[AppDatabaseKey.self] }
    set { self[AppDatabaseKey.self] = newValue }
  }
}
