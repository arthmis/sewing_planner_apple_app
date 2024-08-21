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
    
    //    static func setup(for application: UIApplication) throws {
    //        try migrator.migrate(dbWriter)
    //    }
    
    private let dbWriter: any DatabaseWriter
}

extension AppDatabase {
    func addProject(name: String) throws -> Int64 {
        try dbWriter.write { db in
            let now = Date()
            try db.execute(sql: "INSERT INTO project (name, completed, createDate, updateDate) VALUES (?, ?, ?, ?)", arguments: [name, false, now, now])
            return db.lastInsertedRowID
        }
    }
    
    func updateProjectName(name: String, projectId: Int64) throws {
        try dbWriter.write { db in
            try print(db.columns(in: "project").map(\.name))
            try db.execute(sql: "UPDATE project SET name = ? WHERE id = ?", arguments: [name, projectId])
        }
    }
    
    func saveProject(project: inout Project, projectSteps: [ProjectStep], materialData: [MaterialRecord]) throws {
        print(project)
        print(materialData)
        print(projectSteps)
        try dbWriter.write { db in
            // save project
//            try project.save(db)
            try project.save(db)
            print(project)
            print("creating project with id: \(project.id)")

            // save materials
            for var material in materialData {
                material.projectId = project.id!
                try material.save(db)
            }
            
            // save project steps
            for var step in projectSteps {
                step.data.projectId = project.id!
                try step.data.save(db)
            }
        }
    }
    
    func getProject(projectId: Int64) throws {
        try dbWriter.read { db in
            let value = try db.execute(sql: "SELECT * FROM project LEFT JOIN projectStep ON project.id = projectStep.projectId LEFT JOIN projectMaterials ON project.id = projectMaterials.projectId WHERE project.id = ?", arguments: [projectId])
            print(value)
        }
    }
}

extension AppDatabase {
    private var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()
        
        migrator.registerMigration("projects") { db in
            try db.create(table: "project", options: [.ifNotExists]) { table in
                table.autoIncrementedPrimaryKey("id")
                table.column("name", .text).notNull()
                table.column("completed", .boolean).notNull()
                table.column("createDate", .datetime).notNull()
                table.column("updateDate", .datetime).notNull()
            }
            
            try db.create(table: "projectStep", options: [.ifNotExists]) { table in
                table.autoIncrementedPrimaryKey("id")
                table.belongsTo("project").notNull()
                table.column("text", .text).notNull()
                table.column("completed", .boolean).notNull()
                table.column("createDate", .datetime).notNull()
                table.column("updateDate", .datetime).notNull()
            }
            
            try db.create(table: "projectMaterials", options: [.ifNotExists]) { table in
                table.autoIncrementedPrimaryKey("id")
                table.belongsTo("project").notNull()
                table.column("text", .text).notNull()
                table.column("link", .text).notNull()
                table.column("completed", .boolean).notNull()
                table.column("createDate", .datetime).notNull()
                table.column("updateDate", .datetime).notNull()
            }
        }
        
#if DEBUG
        migrator.eraseDatabaseOnSchemaChange = true
#endif
        
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
