//
//  ImageSketchesView.swift
//  Sewing Planner
//
//  Created by Art on 9/12/24.
//

import AppKit
import GRDB
import SwiftUI

struct ProjectImageRecord: Identifiable, Codable, EncodableRecord, FetchableRecord, MutablePersistableRecord, TableRecord {
    var id: Int64?
    var projectId: Int64
    var filePath: URL
    var createDate: Date
    var updateDate: Date
    static let databaseTableName = "projectImage"
}

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
}

extension ProjectImage: Hashable {
    static func == (lhs: ProjectImage, rhs: ProjectImage) -> Bool {
        return lhs.path == rhs.path
    }

    func hash(into hasher: inout Hasher) {
        hasher.combine(path)
    }
}

struct ImageSketchesView: View {
    let projectId: Int64?
    @State var showFileImporter = false
    @ObservedObject var projectImages: ProjectImages
    @State var selectedImageForDeletion: URL?
    @State var overlaySelectedImage = false
    @State var selectedImage: URL?

    func deduplicateSelectedImages(images: [ProjectImage]) -> [ProjectImage] {
        var result: [ProjectImage] = []
        var uniqueData: Set<ProjectImage> = Set()

        for image in images {
            if !uniqueData.contains(image) {
                result.append(image)
                uniqueData.insert(image)
            }
        }

        return result
    }

//    func handleFileImport()

    var body: some View {
        VStack(alignment: .center) {
            HStack {
                if let imagePath = selectedImageForDeletion {
                    HStack(alignment: .center) {
                        Button("Cancel") {
                            selectedImageForDeletion = nil
                        }
                        Spacer()
                        Button("Delete") {
                            if let index = self.projectImages.images.firstIndex(where: { $0.path == imagePath }) {
                                let image = self.projectImages.images.remove(at: index)
                                projectImages.deletedImages.append(image)
                            }

                            selectedImageForDeletion = nil
                        }
                    }
                }
                Spacer()
                SectionViewButton {} label: {
                    Image(systemName: "ellipsis")
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 30)
            }
            .frame(maxWidth: .infinity)
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150, maximum: 150), spacing: 30)]) {
                    ForEach($projectImages.images, id: \.self.path) { $image in
                        ImageButton(image: $image, selectedImageForDeletion: $selectedImageForDeletion, overlaySelectedImage: $overlaySelectedImage, selectedImage: $selectedImage)
                    }
                }
                .padding(30)
            }
            Button {
                showFileImporter = true
            } label: {
                Image(systemName: "photo.badge.plus")
            }
            .buttonStyle(AddImageButtonStyle())
            .frame(maxWidth: .infinity, alignment: .trailing)
            .padding(10)
            .padding(.trailing, 10)
            .fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.jpeg, .png, .webP, .heic, .heif], allowsMultipleSelection: true) { result in
                switch result {
                case let .success(files):
                    let images: [ProjectImage] = files.map { file in
                        let name = file.lastPathComponent
                        let path = file

                        // need this to access the file content
                        let hasAccess = file.startAccessingSecurityScopedResource()
                        if !hasAccess {
                            // must relinquish access once it isn't needed
                            // hence needing a call at every return point
                            file.stopAccessingSecurityScopedResource()
                            return ProjectImage(path: path)
                        }

                        let data = try! Data(contentsOf: path)
                        if let img = NSImage(data: data) {
                            file.stopAccessingSecurityScopedResource()
                            //                                return ProjectImage(name: name, path: path, image: img)
                            return ProjectImage(path: path, image: img)
                        }

                        file.stopAccessingSecurityScopedResource()
                        //                            return ProjectImage(name: name, path: path)
                        return ProjectImage(path: path)
                    }
                    print(images)
                    projectImages.images += images
                    projectImages.images = deduplicateSelectedImages(images: projectImages.images)
                case let .failure(error):
                    // Process error here
                    print(error)
                }
            }
        }.overlay(alignment: .center) {
            if overlaySelectedImage {
                VStack {
                    HStack(alignment: .firstTextBaseline) {
                        Button {
                            overlaySelectedImage = false
                            selectedImage = nil
                        } label: {
                            Image(systemName: "xmark.circle")
                        }
                    }
                    .frame(maxWidth: .infinity, alignment: .leading)
                    if let imgPath = selectedImage {
                        // TODO: figure out what to do if image doesn't exist, some default image
                        Image(nsImage: projectImages.images.first(where: { $0.path == imgPath })?.image ?? NSImage(size: NSZeroSize))
                            .resizable()
                            .interpolation(.high)
                            .scaledToFit()
                    } else {
                        // TODO: display a toast saying something went wrong and say try again
                        //                    overlaySelectedImage = false
                        Text("Something went wrong. Image could not be displayed")
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .background(.ultraThinMaterial)
            }
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .topLeading
        )
    }
}

// var body: some View {
//    VStack(alignment: .center) {
//        PhotosPicker("Select image", selection: $pickerItem, matching: .images)
//            .onChange(of: pickerItem) {
//                Task {
//                    selectedImage = try await pickerItem?.loadTransferable(type: Image.self)
//                }
//            }
//        selectedImage?.resizable().scaledToFit()
//    }
// }

// #Preview {
//    ImageSketchesView()
// }
