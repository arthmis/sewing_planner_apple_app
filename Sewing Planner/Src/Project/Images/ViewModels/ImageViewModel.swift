//
//  ImageViewModel.swift
//  Sewing Planner
//
//  Created by Art on 10/30/24.
//

import SwiftUI
import GRDB
import PhotosUI

@Observable
class ProjectImages {
    let projectId: Int64
    var images: [ProjectImage] = []
    var deletedImages: [ProjectImage] = []

    var selectedImages: Set<String?> = []
    var overlayedImage: OverlayedImage?
    var pickerItem: PhotosPickerItem?
    var photosAppSelectedImage: Data?
    var errorToast = ErrorToast()
    var inDeleteMode = false

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
                        let (imagePath, thumbnailPath) = try AppFiles().saveProjectImage(projectId: projectId, image: image)!
                        let now = Date.now
                        var input = ProjectImageRecordInput(id: nil, projectId: projectId, filePath: imagePath, thumbnail: thumbnailPath, isDeleted: false, createDate: now, updateDate: now)
                        try input.save(db)
                        let record = ProjectImageRecord(from: consume input)
                        let projectImage = ProjectImage(record: consume record, path: imagePath, image: image.image)
                        addImage(projectImage)
                    }
                } catch {
                    fatalError("error saving record or saving image to filesystem: \(error)")
                }
            }
        }
    }

    func deleteImages() throws {
        try appDatabase.getWriter().write { db in
            for image in deletedImages {
                do {
                    try AppFiles().deleteImage(projectId: projectId, image: image)
                    try image.record.delete(db)
                } catch {
                    throw AppFilesError.deleteError("problem deleting the image")
                }
            }
        }

        deletedImages.removeAll()
    }

    var isInDeleteMode: Bool {
        inDeleteMode
    }

    var selectedImagesIsEmpty: Bool {
        selectedImages.isEmpty
    }

    func cancelDeleteMode() {
        selectedImages = Set()
        inDeleteMode = false
    }

    func handleDeleteImage() {
        if selectedImagesIsEmpty {
            return
        }

        for imagePath in selectedImages {
            if let index = images.firstIndex(where: { $0.path == imagePath }) {
                let image = images.remove(at: index)
                deletedImages.append(image)
            }
        }
        try! deleteImages()

        inDeleteMode = false
        selectedImages = Set()
    }

    func didSetDeleteMode() {
        inDeleteMode = true
    }

    func exitOverlayedImageView() {
        overlayedImage = nil
    }

    func getImage(imageIdentifier: String) -> UIImage {
        AppFiles().getImage(for: imageIdentifier, fromProject: projectId) ?? UIImage()
    }

    func loadProjectImages(appDatabase: AppDatabase) {
        if images.isEmpty {
            images = try! appDatabase.getProjectThumbnails(projectId: projectId)
        }
    }
}
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
