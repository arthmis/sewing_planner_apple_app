//
//  AppDatabase.swift
//  Sewing Planner
//
//  Created by Art on 7/18/24.
//

import Foundation
import GRDB
import os.log

/// docs on implementing this struct https://github.com/groue/GRDB.swift/blob/master/Documentation/DemoApps/GRDBDemoiOS/GRDBDemoiOS/AppDatabase.swift
struct AppDatabase {
    private let dbWriter: any DatabaseWriter
    
    init(_ dbWriter: any DatabaseWriter) throws {
        self.dbWriter = dbWriter
        try migrator.migrate(dbWriter)
    }
}

extension AppDatabase {
    func addProject(project: inout Project) throws -> Project {
        try dbWriter.write { db in
            let now = Date()
            try db.execute(sql: "INSERT INTO project (name, completed, createDate, updateDate) VALUES (?, ?, ?, ?)", arguments: [project.name, project.completed, now, now])
            project.id = db.lastInsertedRowID
            project.createDate = now
            project.updateDate = now
            return project
        }
        
    }
    
    func getWriter() -> any DatabaseWriter {
        return dbWriter
    }
    func saveProject(project: inout Project, projectSteps: [ProjectStep], materialData: [MaterialRecord]) throws {
        try dbWriter.write { db in
            
            // save project
            let now = try db.transactionDate
            project.createDate = now
            project.updateDate = now
            try project.insert(db)

            // save materials
            for var material in materialData {
                material.projectId = project.id!
                material.createDate = now
                material.updateDate = now
                try material.save(db)
            }
            
            // save project steps
            for var step in projectSteps {
                step.data.projectId = project.id!
                step.data.createDate = now
                step.data.updateDate = now
                try step.data.save(db)
            }
        }
    }
}

extension AppDatabase {
    private var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()
        
        migrator.registerMigration("projects") { db in
            try db.create(table: "project", options: [.ifNotExists]) { table in
                table.autoIncrementedPrimaryKey("id")
                table.column("name", .text).notNull().indexed()
                table.column("completed", .boolean).notNull().indexed()
                table.column("createDate", .datetime).notNull()
                table.column("updateDate", .datetime).notNull()
            }
            
            try db.create(table: "projectStep", options: [.ifNotExists]) { table in
                table.autoIncrementedPrimaryKey("id")
                table.belongsTo("project").notNull()
                table.column("text", .text).notNull().indexed()
                table.column("completed", .boolean).notNull()
                table.column("createDate", .datetime).notNull()
                table.column("updateDate", .datetime).notNull()
            }
            
            try db.create(table: "projectMaterial", options: [.ifNotExists]) { table in
                table.autoIncrementedPrimaryKey("id")
                table.belongsTo("project").notNull()
                table.column("text", .text).notNull()
                table.column("link", .text)
                table.column("completed", .boolean).notNull()
                table.column("createDate", .datetime).notNull()
                table.column("updateDate", .datetime).notNull()
            }
            
            try db.create(table: "projectImage", options: [.ifNotExists]) { table in
                table.autoIncrementedPrimaryKey("id")
                table.belongsTo("project").notNull()
                table.column("filePath", .text).notNull()
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
            NSLog("Database stored at \(databaseUrl.path)")
            let dbQueue = try DatabaseQueue(path: databaseUrl.path)
            
            // create AppDatabase
            let appDatabase = try AppDatabase(dbQueue)
            
            return appDatabase
        } catch {
            fatalError("Some error happened: \(error)")
        }
    }
}
