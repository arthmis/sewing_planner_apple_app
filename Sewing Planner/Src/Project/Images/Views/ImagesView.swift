//
//  ImageSketchesView.swift
//  Sewing Planner
//
//  Created by Art on 9/12/24.
//

import AppKit
import GRDB
import SwiftUI

struct ImagesView: View {
    @State var showFileImporter = false
    @ObservedObject var projectImages: ProjectImages
    @State var selectedImageForDeletion: URL?
    @State var overlaySelectedImage = false
    @State var selectedImage: URL?


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
                        let path = file

                        // need this to access the file content
                        let hasAccess = file.startAccessingSecurityScopedResource()
                        // must relinquish access once it isn't needed
                        defer { file.stopAccessingSecurityScopedResource() }
                        
                        if !hasAccess {
                            return ProjectImage(path: path)
                        }

                        let img = NSImage(contentsOf: path)
                        // TODO: think about how to deal with path that couldn't become an image
                        // I'm thinking display an error alert that lists every image that couldn't be uploaded
                        return ProjectImage(path: path, image: img)
                    }
                    try! projectImages.addImages(images)
                case let .failure(error):
                    // Process error here, display a toast
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
