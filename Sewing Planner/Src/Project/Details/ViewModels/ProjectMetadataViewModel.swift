//
//  ProjectViewModel.swift
//  Sewing Planner
//
//  Created by Art on 10/30/24.
//

import SwiftUI

class ProjectMetadataViewModel: ObservableObject {
    @Published var data = ProjectMetadata()
    @Published var bindedName = ""

    init() {}

    init(data: ProjectMetadata) {
        self.data = data
    }

    func updateName(name: String) {
        data.name = name
    }
}
