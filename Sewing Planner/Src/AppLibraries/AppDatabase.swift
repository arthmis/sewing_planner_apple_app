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
        try migrator.migrate(self.dbWriter)

//        #if DEBUG
//            try self.dbWriter.read { db in
//                let rows = try ProjectMetadata.all().fetchAll(db)
//                if rows.isEmpty {
        ////                    AppFiles().deleteImagesFolder()
//                }
//            }
//        #endif
    }
}

extension AppDatabase {
    func addProject(project: inout ProjectMetadata) throws -> ProjectMetadata {
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
}

extension AppDatabase {
    private var migrator: DatabaseMigrator {
        var migrator = DatabaseMigrator()

        migrator.registerMigration("projects") { db in
            try db.create(table: "project", options: [.ifNotExists]) { table in
                table.autoIncrementedPrimaryKey("id")
                table.column("name", .text).notNull().indexed()
                table.column("completed", .boolean).notNull().indexed()
                table.column("isDeleted", .boolean).notNull()
                table.column("createDate", .datetime).notNull()
                table.column("updateDate", .datetime).notNull()
            }

            try db.create(table: "projectImage", options: [.ifNotExists]) { table in
                table.autoIncrementedPrimaryKey("id")
                table.belongsTo("project").notNull()
                table.column("filePath", .text).notNull()
                table.column("isDeleted", .boolean).notNull()
                table.column("createDate", .datetime).notNull()
                table.column("updateDate", .datetime).notNull()
            }

            try db.create(table: "section", options: [.ifNotExists]) { table in
                table.autoIncrementedPrimaryKey("id")
                table.belongsTo("project").notNull()
                table.column("name", .text).notNull().indexed()
                table.column("isDeleted", .boolean).notNull()
                table.column("createDate", .datetime).notNull()
                table.column("updateDate", .datetime).notNull()
            }

            try db.create(table: "sectionItem", options: [.ifNotExists]) { table in
                table.autoIncrementedPrimaryKey("id")
                table.belongsTo("section").notNull()
                table.column("text", .text).notNull().indexed()
                table.column("isComplete", .boolean).notNull().indexed()
                table.column("isDeleted", .boolean).notNull()
                table.column("order", .integer).notNull()
                table.column("createDate", .datetime).notNull()
                table.column("updateDate", .datetime).notNull()
            }

            try db.create(table: "sectionItemNote", options: [.ifNotExists]) { table in
                table.autoIncrementedPrimaryKey("id")
                table.belongsTo("sectionItem").notNull().unique()
                table.column("text", .text).notNull().indexed()
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
    func fetchProjectsAndProjectImage() throws -> [ProjectDisplay] {
        var projectDisplayData: [ProjectDisplay] = []

        print(dbWriter.configuration)
        // get projects
        try dbWriter.read { db in
            let projects: [ProjectMetadata] = try ProjectMetadata.all().order(ProjectColumns.id)
                .fetchAll(db)

            for project in projects {
                let projectIdColumn = Column("projectId")
                // can unwrap project.id because an image can't be stored without having a project id
                if let record = try ProjectImageRecord.all().filter(projectIdColumn == project.id!).order(Column("id")).fetchOne(db) {
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

    func getProject(id: Int64) throws -> ProjectMetadata? {
        return try dbWriter.read { db in
            try ProjectMetadata.all().filter(ProjectColumns.id == id)
                .fetchOne(db)
        }
    }

    func getSections(projectId: Int64) throws -> ProjectSections {
        return try dbWriter.read { db in
            var sections: [Section] = []
            let sectionRecords: [SectionRecord] = try SectionRecord
                .all()
                .filter(Column("projectId") == projectId)
                .fetchAll(db)

            for sectionRecord in sectionRecords {
                let sectionItems = try getSectionItems(sectionId: sectionRecord.id!, from: db)
                sections.append(Section(section: sectionRecord, items: sectionItems, id: UUID()))
            }

            return ProjectSections(sections: sections)
        }
    }

    func getSectionItems(sectionId: Int64, from db: Database) throws -> [SectionItem] {
        let sectionItems = try SectionItemRecord
            .including(optional: SectionItemRecord.note)
            .filter(Column("sectionId") == sectionId)
            .filter(Column("isDeleted") == false)
            .asRequest(of: SectionItem.self)
            .fetchAll(db)

        return sectionItems
    }

    func getImages(projectId: Int64) throws -> ProjectImages {
        return try dbWriter.read { db in
            let projectIdColumn = Column("projectId")
            let records: [ProjectImageRecord] = try ProjectImageRecord.all().filter(projectIdColumn == projectId).order(Column("id")).fetchAll(db)

            var projectImages: [ProjectImage] = []
            for record in records {
                let image = AppFiles().getImage(fromPath: record.filePath)
                let projectImage = ProjectImage(record: record, path: record.filePath, image: image)
                projectImages.append(projectImage)
            }

            return ProjectImages(projectId: projectId, images: projectImages)
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
    static let db = {
//        let argument = CommandLine.arguments.first(where: { val in val == "--test" })

//        print("arguments \(argument)")
//        if let testArgument = argument {
//            if testArgument == "--test" {
//                let dbQueue = try! DatabaseQueue(named: "test_db")
//                return try! AppDatabase(dbQueue)
//            }
//        }

        makeDb(name: "db")
    }

    static func makeDb(name: String) -> AppDatabase {
        do {
            // create the "Application Support/Database" directory if needed
            let fileManager = FileManager.default
            let appSupportUrl = try fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            let directoryUrl = appSupportUrl.appendingPathComponent("Database", isDirectory: true)

            // create database folder
            try fileManager.createDirectory(at: directoryUrl, withIntermediateDirectories: true)

            // open or create database
            let databaseUrl = directoryUrl.appendingPathComponent(name).appendingPathExtension("sqlite")
            let dbQueue = try DatabaseQueue(path: databaseUrl.path)
            NSLog("Database stored at \(databaseUrl.path)")

            // create AppDatabase
            let appDatabase = try AppDatabase(dbQueue)

            return appDatabase
        } catch {
            fatalError("Some error happened: \(error)")
        }
    }

//    static func deleteDb(name: String) {
//        do {
//            // get db directory
//            let fileManager = FileManager.default
//            let appSupportUrl = try fileManager.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
//            let directoryUrl = appSupportUrl.appendingPathComponent("Database", isDirectory: true)
//
//            // get db file name
//            let databaseUrl = directoryUrl.appendingPathComponent(name).appendingPathExtension("sqlite")
//            NSLog("Database stored at \(databaseUrl.path)")
//
//            try! fileManager.removeItem(atPath: databaseUrl.path)
//        } catch {
//            fatalError("Some error happened: \(error)")
//        }
//    }
}
