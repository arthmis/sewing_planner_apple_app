//
//  ProjectDisplayViewModel.swift
//  Sewing Planner
//
//  Created by Art on 10/30/24.
//

import SwiftUI

struct ProjectDisplay {
    var project: ProjectMetadata
    var image: ProjectImage?
}

@Observable
class ProjectsViewModel {
    var projects: [ProjectMetadata] = []
    var projectsDisplay: [ProjectDisplay] = []
    let db: AppDatabase = .db()

    func addProject() throws {
        try db.getWriter().write { db in
            var newProject = ProjectMetadata()
            try newProject.save(db)
            projects.append(newProject)
        }
    }
}
