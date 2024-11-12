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
                table.column("name", .text).notNull().unique().indexed()
                table.column("completed", .boolean).notNull().indexed()
                table.column("isDeleted", .boolean).notNull()
                table.column("createDate", .datetime).notNull()
                table.column("updateDate", .datetime).notNull()
            }

            try db.create(table: "projectImage", options: [.ifNotExists]) { table in
                table.autoIncrementedPrimaryKey("id")
                table.belongsTo("project").notNull()
                table.column("filePath", .text).notNull()
                table.column("hash", .text).notNull()
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

        try dbWriter.read { db in
            let projects: [ProjectMetadata] = try ProjectMetadata.all().order(ProjectColumns.id)
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
                .order(Column("id"))
                .filter(Column("projectId") == projectId)
                .fetchAll(db)

            for sectionRecord in sectionRecords {
                let sectionItemRecords: [SectionItemRecord] = try SectionItemRecord
                    .all()
                    .filter(Column("sectionId") == sectionRecord.id!)
                    .filter(Column("isDeleted") == false)
                    .order(Column("id"))
                    .fetchAll(db)

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
            let databaseUrl = directoryUrl.appendingPathComponent(name).appendingPathExtension("sqlite")
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
            let databaseUrl = directoryUrl.appendingPathComponent(name).appendingPathExtension("sqlite")
            NSLog("Database stored at \(databaseUrl.path)")

            try! fileManager.removeItem(atPath: databaseUrl.path)
        } catch {
            fatalError("Some error happened: \(error)")
        }
    }
}
