//
//  ImageViewModel.swift
//  Sewing Planner
//
//  Created by Art on 10/30/24.
//

import SwiftUI

// TODO: make this a class since storing data like an image is too expensive to be copying
struct ProjectImage {
    var record: ProjectImageRecord
    var path: String
    var image: UIImage

    init(record: ProjectImageRecord, path: String, image: UIImage) {
        self.record = record
        self.image = image
        self.path = path
    }
}

extension ProjectImage: Hashable {
    static func == (lhs: ProjectImage, rhs: ProjectImage) -> Bool {
        return lhs.path == rhs.path
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(path)
    }
}


struct ProjectImageInput {
    var record: ProjectImageRecord?
    var image: UIImage

    init(image: UIImage) {
        self.image = image
    }

    init(record: ProjectImageRecord, image: UIImage) {
        self.record = record
        self.image = image
    }
}
