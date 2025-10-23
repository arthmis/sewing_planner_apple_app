//
//  ImagesView.swift
//  Sewing Planner
//
//  Created by Art on 9/12/24.
//

import GRDB
import PhotosUI
import SwiftUI

struct OverlayedImage: Identifiable, Hashable {
    var id: String {
        return body
    }

    var body: String
}

struct ImagesView: View {
    @Environment(\.appDatabase) private var appDatabase
    @Environment(ProjectViewModel.self) private var project
    @Binding var model: ProjectImages
    @Namespace var transitionNamespace

    var body: some View {
        VStack(alignment: .center) {
            HStack {
                if model.isInDeleteMode {
                    HStack(alignment: .center) {
                        Button("Cancel", action: model.cancelDeleteMode)
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
                        .disabled(model.selectedImagesIsEmpty)
                        .buttonStyle(DeleteButtonStyle())
                        .simultaneousGesture(
                            LongPressGesture(minimumDuration: 2).onEnded { _ in
                                do {
                                    try model.handleDeleteImage()
                                } catch {
                                    project.handleError(error: .deleteImages)
                                }
                            })
                    }
                    .padding(.top, 16)
                }
            }
            .frame(maxWidth: .infinity)
            ScrollView {
                LazyVGrid(
                    columns: [
                        GridItem(.flexible(minimum: 100, maximum: 400), spacing: 4),
                        GridItem(.flexible(minimum: 100, maximum: 400), spacing: 4),
                        //                    GridItem(.adaptive(minimum: 100), spacing: 4),
                    ], spacing: 4
                ) {
                    ForEach($model.images, id: \.self.path) { $image in
                        if !model.isInDeleteMode {
                            ImageButton(image: $image, selectedImage: $model.overlayedImage)
                                .onLongPressGesture {
                                    model.didSetDeleteMode()
                                }
                                .matchedTransitionSource(id: image.path, in: transitionNamespace)
                        } else {
                            SelectedImageButton(
                                image: $image, selectedImagesForDeletion: $model.selectedImages
                            )
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
        .animation(.easeOut(duration: 0.1), value: model.isInDeleteMode)
        .animation(.easeOut(duration: 0.1), value: model.overlayedImage)
        .task {
            do {
                try model.loadProjectImages(appDatabase: appDatabase)
            } catch {
                project.handleError(error: .loadImages)
            }
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
