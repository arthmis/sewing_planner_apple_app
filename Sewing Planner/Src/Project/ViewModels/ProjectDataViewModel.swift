//
//  ProjectDetailData.swift
//  Sewing Planner
//
//  Created by Art on 10/11/24.
//

import Foundation
import GRDB
import SwiftUI

class ProjectSections: ObservableObject {
    @Published var sections: [Section] = []

    init() {}

    init(sections: [Section]) {
        self.sections = sections
    }

    func addSection() {
        sections.append(Section(id: UUID(), name: "Section \(sections.count + 1)"))
    }
}

class ProjectDetailData: ObservableObject {
    var project = ProjectMetadataViewModel()
    var projectSections: ProjectSections = .init()
    var projectImages: ProjectImages = .init()
    var deletedImages: [ProjectImage] = []
    let appDatabase: AppDatabase = .db

    func saveProject() throws -> Int64 {
        let projectId = try appDatabase.saveProject(model: self)
        try AppFiles().saveProjectImages(projectId: projectId, images: projectImages.images)
        return projectId
    }

    func getProject(with id: Int64) {
        let db = AppDatabase.db

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

class ProjectImages: ObservableObject {
    @Published var images: [ProjectImage] = []
    @Published var deletedImages: [ProjectImage] = []

    init() {}

    init(images: [ProjectImage]) {
        self.images = images
    }
}
