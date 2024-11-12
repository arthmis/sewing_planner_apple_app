//
//  ImageViewModel.swift
//  Sewing Planner
//
//  Created by Art on 10/30/24.
//

import CryptoKit
import SwiftUI

// TODO: make this a class since storing data like an image is too expensive to be copying
struct ProjectImage {
    var record: ProjectImageRecord?
    var path: URL
    var image: NSImage?
    var name: String {
        path.deletingPathExtension().lastPathComponent
    }

    init(path: URL, image: NSImage? = nil) {
        self.path = path
        self.image = image
    }

    init(record: ProjectImageRecord, path: URL, image: NSImage? = nil) {
        self.record = record
        self.image = image
        self.path = path
    }

    func getHash() -> String? {
        if let imageData = image {
            if let data = imageData.tiffRepresentation {
                let digest = SHA256.hash(data: data)
                return digest.description
            }
        }

        return nil
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
