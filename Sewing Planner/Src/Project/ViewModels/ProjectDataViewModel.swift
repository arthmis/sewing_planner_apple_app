//
//  ProjectDetailData.swift
//  Sewing Planner
//
//  Created by Art on 10/11/24.
//

import Foundation
import GRDB
import SwiftUI

class ProjectDetailData: ObservableObject {
    var project = ProjectMetadataViewModel()
    var projectSections: ProjectSections = .init()
    var projectImages: ProjectImages = .init(projectId: 0)
    var deletedImages: [ProjectImage] = []
    let db: AppDatabase = .db

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
            projectImages = images

        } catch {
            print("error retrieving data: \(error)")
        }
    }
}

class ProjectSections: ObservableObject {
    @Published var sections: [Section] = []
    let appDatabase: AppDatabase = .db

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

class ProjectImages: ObservableObject {
    let projectId: Int64
    @Published var images: [ProjectImage] = []
    @Published var deletedImages: [ProjectImage] = []
    let appDatabase: AppDatabase = .db

    init(projectId: Int64) {
        self.projectId = projectId
    }

    init(projectId: Int64, images: [ProjectImage]) {
        self.projectId = projectId
        self.images = images
    }

    func addImages(_ newImages: [ProjectImage]) throws {
        images += newImages
        deduplicateImages()
        try saveImages()
    }

    func saveImages() throws {
        try appDatabase.getWriter().write { db in
            for image in images {
                do {
                    if var record = image.record {
                        try record.save(db)
                        try AppFiles().saveProjectImage(projectId: projectId, image: image)
                    }
                }
                catch {
                    fatalError("error saving record or saving image to filesystem: \(error)")
                }
            }
        }
    }

    /// uses hash function to check file uniqueness before adding it
    private func deduplicateImages() {
        var result: [ProjectImage] = []
        var uniqueData: Set<String> = Set()

        let now = Date()

        for var image in images {
            if let record = image.record {
                uniqueData.insert(record.hash)
                result.append(image)
                continue
            }

            // hash file
            if let hash = image.getHash() {
                if !uniqueData.contains(hash) {
                    var record = ProjectImageRecord(projectId: projectId, filePath: image.path, hash: hash, isDeleted: false, createDate: now, updateDate: now)
                    image.record = record
                    result.append(image)
                    uniqueData.insert(hash)
                }
            }
        }

        images = result
    }
}
