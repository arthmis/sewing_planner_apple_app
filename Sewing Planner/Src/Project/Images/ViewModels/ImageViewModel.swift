//
//  ImageViewModel.swift
//  Sewing Planner
//
//  Created by Art on 10/30/24.
//

import SwiftUI
import GRDB
import PhotosUI

class ImagesViewModel {
    var projectImages: ProjectImages
    var selectedImages: Set<String?> = []
    var overlayedImage: OverlayedImage?
    var pickerItem: PhotosPickerItem?
    var photosAppSelectedImage: Data?
    var errorToast = ErrorToast()
    private var inDeleteMode = false
    
    init(projectImages: ProjectImages) {
        self.projectImages = projectImages
    }
    
    init(projectImages: ProjectImages, selectedImages: Set<String?>, overlayedImage: OverlayedImage? = nil, pickerItem: PhotosPickerItem? = nil, photosAppSelectedImage: Data? = nil, errorToast: ErrorToast = ErrorToast(), isInDeleteMode: Bool = false) {
        self.projectImages = projectImages
        self.selectedImages = selectedImages
        self.overlayedImage = overlayedImage
        self.pickerItem = pickerItem
        self.photosAppSelectedImage = photosAppSelectedImage
        self.errorToast = errorToast
        self.inDeleteMode = isInDeleteMode
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
    
    func deleteImages() {
        if selectedImagesIsEmpty {
            return
        }

        for imagePath in selectedImages {
            if let index = self.projectImages.images.firstIndex(where: { $0.path == imagePath }) {
                let image = self.projectImages.images.remove(at: index)
                projectImages.deletedImages.append(image)
            }
        }
        try! projectImages.deleteImages()

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
        AppFiles().getImage(for: imageIdentifier, fromProject: projectImages.projectId) ?? UIImage()
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
