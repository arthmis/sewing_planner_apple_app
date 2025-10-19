//
//  ProjectDisplayViewModel.swift
//  Sewing Planner
//
//  Created by Art on 10/30/24.
//

import SwiftUI

struct ProjectDisplay {
    var project: ProjectMetadata
    var image: ProjectDisplayImage?
}

class ProjectDisplayImage {
    var record: ProjectImageRecord
    var path: String
    var image: UIImage?

    init(record: ProjectImageRecord, path: String, image: UIImage?) {
        self.record = record
        self.image = image
        self.path = path
    }
}

class ProjectsViewModel {
    var projects: [ProjectMetadata] = []
    var projectsDisplay: [ProjectDisplay] = []
    let db: AppDatabase = .db()

    init(projects: [ProjectDisplay]) {
        self.projectsDisplay = projects
    }
    
    init() {}

    func addProject() throws {
        try db.getWriter().write { db in
            var newProjectInput = ProjectMetadataInput()
            try newProjectInput.save(db)

            projects.append(ProjectMetadata(from: newProjectInput))
        }
    }
}
