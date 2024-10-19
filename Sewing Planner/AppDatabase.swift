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
    
    func saveProject(model: ProjectDetailData) throws -> Int64 {
        var projectId: Int64 = 0
        
        try dbWriter.write { db in
            let now = try db.transactionDate

            // save project
            if let id = model.project.data.id {
                try model.project.data.save(db)
            } else {
                model.project.data.createDate = now
                model.project.data.updateDate = now
                try model.project.data.save(db)
            }
            projectId = model.project.data.id!

            // save sections and items belonging to those sections
            for section in model.projectSections.sections {
                if section.section.id != nil {
                    print("has id \(section.section)")
                    try section.section.save(db)
                } else {
                    section.section.createDate = now
                    section.section.updateDate = now
                    section.section.projectId = projectId
                    print("no id \(section.section)")
                    try section.section.save(db)
                }
                let sectionId = section.section.id!

                for var sectionItem in section.items {
                    if let sectionItemId = sectionItem.id  {
                        try sectionItem.save(db)
                    } else {
                        sectionItem.createDate = now
                        sectionItem.updateDate = now
                        sectionItem.sectionId = sectionId
                        try sectionItem.save(db)
                    }
                }
            }
            
            // save project images
            for i in 0..<model.projectImages.images.count {
                if var record = model.projectImages.images[i].record {
                    if let _projectImageId = record.id {
                        try record.save(db)
                    }
                } else {
                    let projectPhotosFolder = AppFiles().getProjectPhotoDirectoryPath(projectId: projectId)
                    print("project folder for images: \(projectPhotosFolder)")
                    let originalFileName = model.projectImages.images[i].path.deletingPathExtension().lastPathComponent
                    let newFilePath = projectPhotosFolder.appendingPathComponent(originalFileName).appendingPathExtension(for: .png)
                    
                    var record = ProjectImageRecord(projectId: projectId, filePath: newFilePath, createDate: now, updateDate: now)
                    try record.save(db)
                    model.projectImages.images[i].record = record
                    model.projectImages.images[i].path = newFilePath
                }
            }
        }
        
        return projectId
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
        
//#if DEBUG
//        migrator.eraseDatabaseOnSchemaChange = true
//#endif
        
        return migrator
    }
}

extension AppDatabase {
    var reader: DatabaseReader {
        dbWriter
    }
}

extension AppDatabase {
    func fetchProjectsAndProjectImage() throws -> [ProjectDisplay] {
        var projectDisplayData: [ProjectDisplay] = []

        try dbWriter.read { db in
            let projects: [Project] = try Project.all().order(ProjectColumns.id)
                    .fetchAll(db)
        
            for project in projects {
                let imageIdColumn = Column("projectId")
                if let record = try ProjectImageRecord.all().filter(imageIdColumn == project.id!).order(Column("id")).fetchOne(db) {
                    let image = AppFiles().getImage(fromPath: record.filePath)
                    let projectImage = ProjectImage(record: record, path: record.filePath, image: image)
                    projectDisplayData.append(ProjectDisplay(project: project, image: projectImage))
                } else {
                    projectDisplayData.append(ProjectDisplay(project: project))
                }
            }
        }
        
        return projectDisplayData
    }
    
    func getProject(id: Int64) throws -> Project? {
        return try dbWriter.read { db in
            return try Project.all().filter(ProjectColumns.id == id)
                    .fetchOne(db)
        }
    }
    
    func getSections(projectId: Int64) throws -> ProjectSections {
        return try dbWriter.read { db in
            var sections: [Section] = []
            let sectionRecords: [SectionRecord] = try SectionRecord.all().order(Column("id"))
                    .fetchAll(db)
            
            for sectionRecord in sectionRecords {
                let sectionItemRecords: [SectionItemRecord] = try SectionItemRecord.all().filter(Column("sectionId") == sectionRecord.id!).order(Column("id")).fetchAll(db)
                
                sections.append(Section(section: sectionRecord, items: sectionItemRecords, id: UUID()))
            }
            
            return ProjectSections(sections: sections)
        }
    }
    
    func getImages(projectId: Int64) throws -> ProjectImages {
        return try dbWriter.read { db in
            let imageIdColumn = Column("projectId")
            let records: [ProjectImageRecord] = try ProjectImageRecord.all().filter(imageIdColumn == projectId).order(Column("id")).fetchAll(db)
            
            var projectImages: [ProjectImage] = []
            for record in records {
                let image = AppFiles().getImage(fromPath: record.filePath)
                let projectImage = ProjectImage(record: record, path: record.filePath, image: image)
                projectImages.append(projectImage)
                }
            
            return ProjectImages(images: projectImages)
        }
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
