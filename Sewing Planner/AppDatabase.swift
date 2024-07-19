//
//  AppDatabase.swift
//  Sewing Planner
//
//  Created by Art on 7/18/24.
//

import Foundation
import GRDB
import os.log

struct AppDatabase {
  init(_ dbWriter: any DatabaseWriter) throws {
    self.dbWriter = dbWriter
    try migrator.migrate(dbWriter)
  }

  private let dbWriter: any DatabaseWriter
}

extension AppDatabase {
  private var migrator: DatabaseMigrator {
    var migrator = DatabaseMigrator()

    migrator.registerMigration("projects") { db in
      try db.create(table: "project") { table in
        table.autoIncrementedPrimaryKey("id")
        table.column("name", .text)
        table.column("create_date", .datetime)
        table.column("update_date", .datetime)
      }

      try db.create(table: "project_step") { table in
        table.autoIncrementedPrimaryKey("id")
        table.column("project_id", .integer)
        table.column("text", .text)
        table.column("create_date", .datetime)
        table.column("update_date", .datetime)
      }
    }
    return migrator
  }
}

extension AppDatabase {
  var reader: DatabaseReader {
    dbWriter
  }
}

extension AppDatabase {
  static func empty() -> AppDatabase {
    let dbQueue = try! DatabaseQueue()
    return try! AppDatabase(dbQueue)
  }
}

extension AppDatabase {
  static let db = makeDb()

    private static func makeDb() -> AppDatabase {
        do {
            // create the "Application Support/Database" directory if needed
            let fileManager = FileManager.default
            let appSupportUrl = try fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let directoryUrl = appSupportUrl.appendingPathComponent("Database", isDirectory: true)
            
            // create database folder
            try fileManager.createDirectory(at: directoryUrl, withIntermediateDirectories: true)
            
            
            // open or create database
            let databaseUrl  = directoryUrl.appendingPathComponent("db.sqlite")
            let dbQueue = try DatabaseQueue(path: databaseUrl.path)
            
            // create AppDatabase
            let appDatabase = try AppDatabase(dbQueue)
            
            return appDatabase
        } catch {
            fatalError("Some error happened: \(error)")
        }
    }
}
