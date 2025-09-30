//
//  ImageSketchesView.swift
//  Sewing Planner
//
//  Created by Art on 9/12/24.
//

// import AppKit
import GRDB
import PhotosUI
import SwiftUI

struct ErrorToast {
    var show: Bool
    let message: String

    init(show: Bool = false, message: String = "Something went wrong. Please try again") {
        self.show = show
        self.message = message
    }
}

struct ImagesView: View {
    @Binding var projectImages: ProjectImages
    @State var selectedImageForDeletion: URL?
    @State var overlaySelectedImage = false
    @State var selectedImage: URL?
    @State private var pickerItem: PhotosPickerItem?
    @State private var photosAppSelectedImage: Data?
    @State var errorToast = ErrorToast()

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
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 100, maximum: 100), spacing: 4)]) {
                    ForEach($projectImages.images, id: \.self.path) { $image in
                        ImageButton(image: $image, selectedImageForDeletion: $selectedImageForDeletion, overlaySelectedImage: $overlaySelectedImage, selectedImage: $selectedImage)
                    }
                }
                .padding(8)
            }
        }
        .overlay(alignment: .center) {
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
                        Image(systemName: "xmark.circle")
//                        Image(nsImage: projectImages.images.first(where: { $0.path == imgPath })?.image ?? NSImage(size: NSZeroSize))
//                            .resizable()
//                            .interpolation(.high)
//                            .scaledToFit()
                    } else {
                        // TODO: display a toast saying something went wrong and say try again
                        //                    overlaySelectedImage = false
                        Text("Something went wrong. Image could not be selected. Please try again later")
                    }
                }
                .padding(20)
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                .background(.ultraThinMaterial)
            }
        }
        .overlay(alignment: .bottomTrailing) {
            if errorToast.show {
                Toast(showToast: $errorToast.show, message: errorToast.message)
                    .padding([.trailing], 30)
            }
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
            alignment: .topLeading
        )
    }
}

// TODO: support photospicker as well
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
//    VStack {
//        ImagesView(projectImages: ProjectImages(projectId: 2))
//    }
//    .frame(
//        maxWidth: .infinity,
//        maxHeight: .infinity,
//        alignment: .topLeading
//    )
//    .background(.white)
// }
