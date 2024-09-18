//
//  ImageSketchesView.swift
//  Sewing Planner
//
//  Created by Art on 9/12/24.
//

import SwiftUI
import AppKit

struct SketchData: Identifiable {
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

extension SketchData: Hashable {
    static func == (lhs: SketchData, rhs: SketchData) -> Bool {
        return lhs.path == rhs.path
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(path)
    }
}

struct ImageSketchesView: View {
    @State var text = ""
    @State var showFileImporter = false
    @State var projectImages: [SketchData] = []
    
    func deduplicateSelectedImages(images: [SketchData]) -> [SketchData] {
        var result: [SketchData] = []
        var uniqueData: Set<SketchData> = Set()
        
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
            Button {
                showFileImporter = true
            } label: {
                Label("Select image", systemImage: "doc.circle")
            }.fileImporter(isPresented: $showFileImporter, allowedContentTypes: [.jpeg, .png, .webP, .heic, .heif], allowsMultipleSelection: true) { result in
                switch result {
                case .success(let files):
                    let images: [SketchData] = files.map { file in
                        let name = file.lastPathComponent
                        let path = file
                        
                        // need this to access the file content
                        let hasAccess = file.startAccessingSecurityScopedResource()
                        if !hasAccess {
                            // must relinquish access once it isn't needed
                            // hence needing a call at every return point
                            file.stopAccessingSecurityScopedResource()
                            return SketchData(name: name, path: path)
                        }
                        
                        let data = try! Data(contentsOf: path)
                        if let img = NSImage(data: data) {
                            file.stopAccessingSecurityScopedResource()
                            return SketchData(name: name, path: path, image: img)
                        }
                        
                        file.stopAccessingSecurityScopedResource()
                        return SketchData(name: name, path: path)
                    }
                    print(images)
                    projectImages += images
                    projectImages = deduplicateSelectedImages(images: projectImages)
                case .failure(let error):
                    // Process error here
                    print(error)
                }
            }
            List {
                ForEach($projectImages, id: \.self.path) { $image in
                    if let img = image.image {
                        Image(nsImage: img)
                            .resizable()
                            .interpolation(.high)
                            .aspectRatio(contentMode: /*@START_MENU_TOKEN@*/.fill/*@END_MENU_TOKEN@*/)
                            .frame(width: 150, height: 150, alignment: .center)
                        Text(image.name)
                    } else {
                        // TODO: put a placeholder image if image displaying or loading fails
                        Text(image.name)
                    }
                }
            }
        }.border(Color.green)
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
