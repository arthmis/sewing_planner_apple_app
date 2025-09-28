//
//  ProjectDetailData.swift
//  Sewing Planner
//
//  Created by Art on 10/11/24.
//

import Foundation
import GRDB
import SwiftUI

@Observable
class ProjectDetailData {
    var project = ProjectMetadataViewModel()
    var projectSections: ProjectSections = .init()
    var projectImages: ProjectImages = .init(projectId: 0)
    var deletedImages: [ProjectImage] = []
    let db: AppDatabase = .db()

    func getProject(with id: Int64) {
        do {
            let project = try db.getProject(id: id)
            let projectData = ProjectMetadataViewModel(data: project!)
            self.project = projectData
            print(projectData.data)
            let sections = try db.getSections(projectId: id)
            projectSections = sections
            print(sections.sections.count)
            let images = try db.getImages(projectId: id)
            print(images.images.count)
            for image in images.images {
                print(image.record!)
            }
            projectImages = images

        } catch {
            print("error retrieving data: \(error)")
        }
    }
}

@Observable
class ProjectSections {
    var sections: [Section] = []
    let appDatabase: AppDatabase = .db()

    init() {}

    init(sections: [Section]) {
        self.sections = sections
    }

    func addSection(projectId: Int64) throws {
        try appDatabase.getWriter().write { db in
            let section = Section(id: UUID(), name: "Section \(sections.count + 1)")
            section.section.projectId = projectId
            try section.section.save(db)
            sections.append(section)
        }
    }
}

@Observable
class ProjectImages {
    let projectId: Int64
    var images: [ProjectImage] = []
    var deletedImages: [ProjectImage] = []
    let appDatabase: AppDatabase = .db()

    init(projectId: Int64) {
        self.projectId = projectId
    }

    init(projectId: Int64, images: [ProjectImage]) {
        self.projectId = projectId
        self.images = images
    }

    func importImages(_ newImages: [ProjectImageInput]) throws {
        try saveImages(images: newImages)
    }

    func addImage(_ image: ProjectImage) {
        images.append(image)
    }

    func saveImages(images: [ProjectImageInput]) throws {
        try appDatabase.getWriter().write { db in
            for image in images {
                do {
                    if image.record == nil {
                        let newFilePath = try AppFiles().saveProjectImage(projectId: projectId, image: image)
                        let now = Date.now
                        var record = ProjectImageRecord(id: nil, projectId: projectId, filePath: newFilePath, isDeleted: false, createDate: now, updateDate: now)
                        try record.save(db)
                        let projectImage = ProjectImage(record: record, path: newFilePath, image: image.image)
                        addImage(projectImage)
                    }
                } catch {
                    fatalError("error saving record or saving image to filesystem: \(error)")
                }
            }
        }
    }
}
