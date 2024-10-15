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
    
//    func saveProject(project: inout Project, projectSteps: [ProjectStep], materialData: [MaterialRecord], projectImages: inout [ProjectImage]) throws -> Int64 {
    func saveProject(model: ProjectDetailData) throws -> Int64 {
        print(model)
        print(model.project.data)
        print(model.projectSections.sections[0].section)
        print(model.projectSections.sections[0].items[0])
        try dbWriter.write { db in
            
            // save project
            let now = try db.transactionDate
            model.project.data.createDate = now
            model.project.data.updateDate = now
            try model.project.data.insert(db)
            let projectId = model.project.data.id!
            

            for section in model.projectSections.sections {
                section.section.createDate = now
                section.section.updateDate = now
                section.section.projectId = projectId
                try section.section.insert(db)
                let sectionId = section.section.id!
                
                for var sectionItem in section.items {
                    sectionItem.createDate = now
                    sectionItem.updateDate = now
                    sectionItem.sectionId = sectionId
                    try sectionItem.insert(db)
                }

            }
            
            for i in 0..<model.projectImages.images.count {
                let projectPhotosFolder = AppFiles().getProjectPhotoDirectoryPath(projectId: projectId)
                print(projectPhotosFolder)
                let originalFileName = model.projectImages.images[i].path.deletingPathExtension().lastPathComponent
                let newFilePath = projectPhotosFolder.appendingPathComponent(originalFileName).appendingPathExtension(for: .png)
                
                var record = ProjectImageRecord(projectId: projectId, filePath: newFilePath, createDate: now, updateDate: now)
                try record.save(db)
                model.projectImages.images[i].record = record
                model.projectImages.images[i].path = newFilePath
            }
        }
        
//        return project.id!
        return 0
    }
}

extension AppDatabase {
    private var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()
        
        migrator.registerMigration("projects") { db in
            try db.create(table: "project", options: [.ifNotExists]) { table in
                table.autoIncrementedPrimaryKey("id")
                table.column("name", .text).notNull().unique().indexed()
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
            
            try db.create(table: "section", options: [.ifNotExists]) { table in
                table.autoIncrementedPrimaryKey("id")
                table.belongsTo("project").notNull()
                table.column("name", .text).notNull().indexed()
                table.column("createDate", .datetime).notNull()
                table.column("updateDate", .datetime).notNull()
            }
            
            try db.create(table: "sectionItem", options: [.ifNotExists]) { table in
                table.autoIncrementedPrimaryKey("id")
                table.belongsTo("section").notNull()
                table.column("text", .text).notNull().indexed()
                table.column("isComplete", .boolean).notNull().indexed()
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
    static let db = makeDb(name: "db")
    
    static func makeDb(name: String) -> AppDatabase {
        do {
            // create the "Application Support/Database" directory if needed
            let fileManager = FileManager.default
            let appSupportUrl = try fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let directoryUrl = appSupportUrl.appendingPathComponent("Database", isDirectory: true)
            
            // create database folder
            try fileManager.createDirectory(at: directoryUrl, withIntermediateDirectories: true)
            
            
            // open or create database
            let databaseUrl  = directoryUrl.appendingPathComponent(name).appendingPathExtension("sqlite")
            NSLog("Database stored at \(databaseUrl.path)")
            let dbQueue = try DatabaseQueue(path: databaseUrl.path)
            
            // create AppDatabase
            let appDatabase = try AppDatabase(dbQueue)
            
            return appDatabase
        } catch {
            fatalError("Some error happened: \(error)")
        }
    }
    
    static func deleteDb(name: String) {
        do {
            // get db directory
            let fileManager = FileManager.default
            let appSupportUrl = try fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let directoryUrl = appSupportUrl.appendingPathComponent("Database", isDirectory: true)
            
            // get db file name
            let databaseUrl  = directoryUrl.appendingPathComponent(name).appendingPathExtension("sqlite")
            NSLog("Database stored at \(databaseUrl.path)")
            
            try! fileManager.removeItem(atPath: databaseUrl.path)
        } catch {
            fatalError("Some error happened: \(error)")
        }
    }
}
