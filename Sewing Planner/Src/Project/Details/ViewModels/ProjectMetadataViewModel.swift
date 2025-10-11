//
//  ProjectViewModel.swift
//  Sewing Planner
//
//  Created by Art on 10/30/24.
//

import SwiftUI

@Observable
class ProjectMetadataViewModel {
    var data: ProjectMetadata
    var bindedName = ""
    var db: AppDatabase = .db()

    init(data: ProjectMetadata) {
        self.data = data
    }

    func updateName(name: String) throws {
        try db.getWriter().write { db in
            data.name = name
            try data.save(db)
        }
    }
}
