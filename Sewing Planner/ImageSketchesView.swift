//
//  ImageSketchesView.swift
//  Sewing Planner
//
//  Created by Art on 9/12/24.
//

import SwiftUI
import AppKit
import GRDB

struct ProjectImageRecord: Identifiable, Codable, EncodableRecord, FetchableRecord, MutablePersistableRecord, TableRecord {
    var id: Int64?
    var projectId: Int64
    var filePath: URL
    var createDate: Date
    var updateDate: Date
    static let databaseTableName = "projectImage"
}

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
    let projectId: Int64
    @State var showFileImporter = false
    @Binding var projectImages: [ProjectImage]
    @Binding var deletedImages: [ProjectImage]
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
    
    var body: some View {
        VStack(alignment: .center) {
            HStack {
                Button("save images") {
                    try! AppFiles().saveProjectImages(projectId: projectId, images: projectImages)
                }
                Button {
                    showFileImporter = true
                } label: {
                    Label("Select image", systemImage: "doc.circle")
                }.fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.jpeg, .png, .webP, .heic, .heif], allowsMultipleSelection: true) { result in
                    switch result {
                    case .success(let files):
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
                        projectImages += images
                        projectImages = deduplicateSelectedImages(images: projectImages)
                    case .failure(let error):
                        // Process error here
                        print(error)
                    }
                }
                if let imagePath = selectedImageForDeletion {
                    HStack(alignment: .center) {
                        Button("Cancel") {
                            selectedImageForDeletion = nil
                        }
                        Spacer()
                        Button("Delete") {
                            if let index = self.projectImages.firstIndex(where: {$0.path == imagePath}) {
                                let image = self.projectImages.remove(at: index)
                                self.deletedImages.append(image)
                            }
                            
                            selectedImageForDeletion = nil
                        }
                    }
                }
            }
            ScrollView {
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 150, maximum: 150))]) {
                    ForEach($projectImages, id: \.self.path) { $image in
                        if let img = image.image {
                            if image.path == selectedImageForDeletion {
                                VStack {
                                    Image(nsImage: img)
                                        .resizable()
                                        .interpolation(.high)
                                        .scaledToFit()
                                        .frame(width: 120, height: 120, alignment: .center)
                                    Text(image.name)
                                }.background(Color.blue)
                            } else {
                                VStack {
                                    Image(nsImage: img)
                                        .resizable()
                                        .interpolation(.high)
                                        .scaledToFit()
                                        .frame(width: 120, height: 120, alignment: .center)
                                    Text(image.name)
                                }.onTapGesture {
                                    selectedImage = image.path
                                    overlaySelectedImage = true
                                }.onLongPressGesture {
                                    selectedImageForDeletion = image.path
                                }
                            }
                        } else {
                            // TODO: put a placeholder image if image displaying or loading fails
                            Text(image.name)
                        }
                    }
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
                        Image(nsImage: projectImages.first(where: { $0.path == imgPath })?.image ?? NSImage(size: NSZeroSize))
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

//var body: some View {
//    VStack(alignment: .center) {
//        PhotosPicker("Select image", selection: $pickerItem, matching: .images)
//            .onChange(of: pickerItem) {
//                Task {
//                    selectedImage = try await pickerItem?.loadTransferable(type: Image.self)
//                }
//            }
//        selectedImage?.resizable().scaledToFit()
//    }
//}

//#Preview {
//    ImageSketchesView()
//}
