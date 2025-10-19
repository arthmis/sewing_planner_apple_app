//
//  ImageSketchesView.swift
//  Sewing Planner
//
//  Created by Art on 9/12/24.
//

import GRDB
import PhotosUI
import SwiftUI

struct ErrorToast: Equatable {
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
    //    @Binding var projectImages: ProjectImages
    //    @State var selectedImages: Set<String?> = []
    //    @State var overlayedImage: OverlayedImage?
    //    @State private var pickerItem: PhotosPickerItem?
    //    @State private var photosAppSelectedImage: Data?
    //    @State var errorToast = ErrorToast()
    //    @State var isInDeleteMode = false
    @Environment(\.appDatabase) private var appDatabase
    @State var model: ImagesViewModel
    @Namespace var transitionNamespace

    var body: some View {
        VStack(alignment: .center) {
            HStack {
                if model.isInDeleteMode {
                    HStack(alignment: .center) {
                        Button("Cancel", action: model.cancelDeleteMode)
                            .buttonStyle(SecondaryButtonStyle())
                        Spacer()
                        Button {
                        } label: {
                            HStack {
                                Text("Delete")
                                Image(systemName: "trash")
                                    .font(.system(size: 20, weight: Font.Weight.medium))
                                    .foregroundStyle(Color.white)
                            }
                        }
                        .disabled(model.selectedImagesIsEmpty)
                        .buttonStyle(DeleteButtonStyle())
                        .simultaneousGesture(
                            LongPressGesture(minimumDuration: 2).onEnded { val in
                                print(val)
                                model.deleteImages()
                            })
                    }
                    .padding(.top, 16)
                }
            }
            .animation(.easeOut(duration: 0.12), value: model.isInDeleteMode)
            .frame(maxWidth: .infinity)
            ScrollView {
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(minimum: 100, maximum: 400), spacing: 4),
                        GridItem(.flexible(minimum: 100, maximum: 400), spacing: 4),
                        //                    GridItem(.adaptive(minimum: 100), spacing: 4),
                    ], spacing: 4
                ) {
                    ForEach($model.projectImages.images, id: \.self.path) { $image in
                        if !model.isInDeleteMode {
                            ImageButton(image: $image, selectedImage: $model.overlayedImage)
                                .onLongPressGesture {
                                    model.didSetDeleteMode()
                                }
                                .matchedTransitionSource(id: image.path, in: transitionNamespace)
                        } else {
                            SelectedImageButton(
                                image: $image, selectedImagesForDeletion: $model.selectedImages)
                        }
                    }
                }
            }
        }
        .padding([.horizontal, .bottom], 8)
        .sheet(item: $model.overlayedImage) { item in
            VStack {
                HStack(alignment: .firstTextBaseline) {
                    Button {
                        model.exitOverlayedImageView()
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
                Image(uiImage: model.getImage(imageIdentifier: item.id))
                    .resizable()
                    .interpolation(.low)
                    .scaledToFit()
                    .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    .navigationTransition(.zoom(sourceID: item.id, in: transitionNamespace))
            }
        }
        .overlay(alignment: .bottom) {
            if model.errorToast.show {
                Toast(showToast: $model.errorToast.show, message: model.errorToast.message)
                    .padding(.horizontal, 16)
            }
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity,
        )
        .animation(.easeOut(duration: 0.1), value: model.isInDeleteMode)
        .animation(.easeOut(duration: 0.1), value: model.overlayedImage)
        .onAppear {
            if self.model.projectImages.images.isEmpty {
                self.model.projectImages = try! ProjectDetailData.getImages(
                    fromProject: model.projectImages.projectId, usingDatabase: appDatabase)
            }
            // TODO: navigate back to main screen because project loading was unsuccessful
            // show an error
            // isLoading = false
        }
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
