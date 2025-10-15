//
//  ImageSketchesView.swift
//  Sewing Planner
//
//  Created by Art on 9/12/24.
//

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

struct OverlayedImage: Identifiable, Hashable {
    var id: String {
        return body
    }

    var body: String
}

struct ImagesView: View {
    @Binding var projectImages: ProjectImages
    @State var selectedImages: Set<String?> = []
    @State var overlayedImage: OverlayedImage?
    @State private var pickerItem: PhotosPickerItem?
    @State private var photosAppSelectedImage: Data?
    @State var errorToast = ErrorToast()
    @State var isInDeleteMode = false
    @Namespace var transitionNamespace

    var body: some View {
        VStack(alignment: .center) {
            HStack {
                if isInDeleteMode {
                    HStack(alignment: .center) {
                        Button("Cancel") {
                            selectedImages = Set()
                            isInDeleteMode = false
                        }
                        .buttonStyle(SecondaryButtonStyle())
                        Spacer()
                        Button {} label: {
                            HStack {
                                Text("Delete")
                                Image(systemName: "trash")
                                    .font(.system(size: 20, weight: Font.Weight.medium))
                                    .foregroundStyle(Color.white)
                            }
                        }
                        .disabled(selectedImages.isEmpty)
                        .buttonStyle(DeleteButtonStyle())
                        .simultaneousGesture(LongPressGesture(minimumDuration: 2).onEnded { _ in
                            if selectedImages.isEmpty {
                                return
                            }

                            for imagePath in selectedImages {
                                if let index = self.projectImages.images.firstIndex(where: { $0.path == imagePath }) {
                                    let image = self.projectImages.images.remove(at: index)
                                    projectImages.deletedImages.append(image)
                                }
                            }
                            try! projectImages.deleteImages()

                            isInDeleteMode = false
                            selectedImages = Set()
                        })
                    }
                    .padding(.top, 16)
                }
            }
            .animation(.easeOut(duration: 0.12), value: isInDeleteMode)
            .frame(maxWidth: .infinity)
            ScrollView {
                LazyVGrid(columns: [
                    GridItem(.flexible(minimum: 100, maximum: 400), spacing: 4),
                    GridItem(.flexible(minimum: 100, maximum: 400), spacing: 4),
//                    GridItem(.adaptive(minimum: 100), spacing: 4),
                ], spacing: 4) {
                    ForEach($projectImages.images, id: \.self.path) { $image in
                        if !isInDeleteMode {
                            ImageButton(image: $image, selectedImagesForDeletion: $selectedImages, selectedImage: $overlayedImage)
                                .onLongPressGesture {
                                    isInDeleteMode = true
                                }
                                .matchedTransitionSource(id: image.path, in: transitionNamespace)
                        } else {
                            SelectedImageButton(image: $image, selectedImagesForDeletion: $selectedImages)
                        }
                    }
                }
            }
        }
        .padding([.horizontal, .bottom], 8)
        .sheet(item: $overlayedImage) { item in
            VStack {
                HStack(alignment: .firstTextBaseline) {
                    Button {
                        overlayedImage = nil
                    } label: {
                        Image(systemName: "xmark.circle")
                            .font(.system(size: 22, weight: Font.Weight.thin))
                            .foregroundStyle(Color.red)
                    }
                    .padding(.bottom, 8)
                }
                .padding([.top, .leading], 16)
                .frame(maxWidth: .infinity, alignment: .leading)

                // TODO: figure out what to do if image doesn't exist, some default image
                Image(uiImage: AppFiles().getImage(for: item.id, fromProject: projectImages.projectId) ?? UIImage())
                    .resizable()
                    .interpolation(.low)
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .navigationTransition(.zoom(sourceID: item.id, in: transitionNamespace))
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
        )
        .animation(.easeOut(duration: 0.25), value: isInDeleteMode)
        .animation(.easeOut(duration: 0.15), value: overlayedImage)
    }
}

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
