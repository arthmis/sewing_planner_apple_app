//
//  ImageSketchesView.swift
//  Sewing Planner
//
//  Created by Art on 9/12/24.
//

import SwiftUI
import AppKit

struct ProjectImage: Identifiable {
    var id: Int64?
    var projectId: Int64
    var filePath: URL
    var createDate: Date
    var updateDate: Date
    
    init(name: String, path: URL, image: NSImage? = nil) {
        projectId = 0
        self.filePath = path
        let now = Date()
        createDate = now
        updateDate = now
    }
}

struct ProjectImageData: Identifiable {
    var id: Int64?
    var projectId: Int64
    var name: String
    var path: URL
    var image: NSImage?
    var createDate: Date
    var updateDate: Date
    
    init(name: String, path: URL, image: NSImage? = nil) {
        projectId = 0
        self.name = name
        self.path = path
        self.image = image
        let now = Date()
        createDate = now
        updateDate = now
    }
}

extension ProjectImageData: Hashable {
    static func == (lhs: ProjectImageData, rhs: ProjectImageData) -> Bool {
        return lhs.path == rhs.path
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(path)
    }
}

struct ImageSketchesView: View {
    @State var text = ""
    @State var showFileImporter = false
    @State var projectImages: [ProjectImageData] = []
    @State var selectedImageForDeletion: URL?
    @State var overlaySelectedImage = false
    @State var selectedImage: URL?
    
    func deduplicateSelectedImages(images: [ProjectImageData]) -> [ProjectImageData] {
        var result: [ProjectImageData] = []
        var uniqueData: Set<ProjectImageData> = Set()
        
        for image in images {
            if !uniqueData.contains(image) {
                result.append(image)
                uniqueData.insert(image)
            }
        }
        
        return result
    }
    
    // save images in a ProjectPhotos directory
    // within that directory save the project images in a folder(with the name of project id)
    // consider using a uuid for a project id and use that as a folder name instead of the
    // integer project id
    // have an projectImages table in database
    // schema looks like
    // imageId : Int64
    // projectId : Int64
    // filePath : text
    // createDate
    // updateDate
    var body: some View {
        VStack(alignment: .center) {
            HStack {
                Button("save images") {
                    let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
                    let usersPhotosUrl = documentsURL.appendingPathComponent("ProjectPhotos")
                    
                    do {
                        try FileManager.default.createDirectory(at: usersPhotosUrl, withIntermediateDirectories: true, attributes: nil)
                    } catch {
                        print("Error \(error)")
                    }
                }
                Button {
                    showFileImporter = true
                } label: {
                    Label("Select image", systemImage: "doc.circle")
                }.fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.jpeg, .png, .webP, .heic, .heif], allowsMultipleSelection: true) { result in
                    switch result {
                    case .success(let files):
                        let images: [ProjectImageData] = files.map { file in
                            let name = file.lastPathComponent
                            let path = file
                            
                            // need this to access the file content
                            let hasAccess = file.startAccessingSecurityScopedResource()
                            if !hasAccess {
                                // must relinquish access once it isn't needed
                                // hence needing a call at every return point
                                file.stopAccessingSecurityScopedResource()
                                return ProjectImageData(name: name, path: path)
                            }
                            
                            let data = try! Data(contentsOf: path)
                            if let img = NSImage(data: data) {
                                file.stopAccessingSecurityScopedResource()
                                return ProjectImageData(name: name, path: path, image: img)
                            }
                            
                            file.stopAccessingSecurityScopedResource()
                            return ProjectImageData(name: name, path: path)
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
                            self.projectImages = self.projectImages.filter { $0.path != imagePath}
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

#Preview {
    ImageSketchesView()
}
