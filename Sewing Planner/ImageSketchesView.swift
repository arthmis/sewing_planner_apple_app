//
//  ImageSketchesView.swift
//  Sewing Planner
//
//  Created by Art on 9/12/24.
//

import SwiftUI

struct SketchData: Identifiable {
    var id: Int64?
    var projectId: Int64
    var name: String
    var path: URL
    var createDate: Date
    var updateDate: Date
    
    init(name: String, path: URL) {
        projectId = 0
        self.name = name
        self.path = path
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
                    Text(image.name)
                }
            }
        }.frame(width: .infinity, height: .infinity, alignment: .top).border(Color.green)
    }
}

#Preview {
    ImageSketchesView()
}
