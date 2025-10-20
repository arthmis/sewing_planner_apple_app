//
//  ProjectDetailData.swift
//  Sewing Planner
//
//  Created by Art on 10/11/24.
//

import Foundation
import GRDB
import SwiftUI
import PhotosUI

@Observable
class ProjectDetailData {
    var project: ProjectMetadataViewModel
    var projectSections: ProjectSections = .init()
    let db: AppDatabase = .db()

    init(project: ProjectMetadataViewModel) {
        self.project = project
    }

    init(project: ProjectMetadataViewModel, projectSections: ProjectSections) {
        self.project = project
        self.projectSections = projectSections
    }

    init(project: ProjectMetadataViewModel, projectSections: ProjectSections, projectImages: ProjectImages) {
        self.project = project
        self.projectSections = projectSections
    }

    static func getProject(with id: Int64, from db: AppDatabase) throws -> ProjectDetailData? {
        do {
            if let project = try db.getProject(id: id) {
                let projectData = ProjectMetadataViewModel(data: project)
                let project = projectData
                print(projectData.data)
                let sections = try db.getSections(projectId: id)
                let projectSections = sections
                print(sections.sections.count)
                // let images = try db.getProjectThumbnails(projectId: id)
                // print(images.images.count)
                // for image in images.images {
                //     print(image.record)
                // }
                // let projectImages = images
                // return (ProjectDetailData(project: project, projectSections: projectSections, projectImages: projectImages))
                return (ProjectDetailData(project: project, projectSections: projectSections))
            }

        } catch {
            print("error retrieving data: \(error)")
        }
        return nil
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
            let now = Date()
            var sectionInput = SectionInputRecord(projectId: projectId, name: "Section \(sections.count + 1)", createDate: now, updateDate: now)
            try sectionInput.save(db)
            let sectionRecord = SectionRecord(from: sectionInput)
            let section = Section(id: UUID(), name: sectionRecord)
            sections.append(section)
        }
    }
}

enum AppFilesError: Error {
    case deleteError(String)
}
