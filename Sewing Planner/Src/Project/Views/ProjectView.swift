//
//  ProjectView.swift
//  Sewing Planner
//
//  Created by Art on 7/9/24.
//

import GRDB
import PhotosUI
import SwiftUI

enum CurrentView {
    case details
    case images
}


struct ProjectView: View {
    // used for dismissing a view(basically the back button)
    @Environment(\.dismiss) private var dismiss
    @Environment(\.appDatabase) private var appDatabase
    @Environment(\.store) private var store
    @Binding var projectsNavigation: [ProjectMetadata]
    let fetchProjects: () -> Void
    @State var isLoading = true

    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                Project(model: store.selectedProject!.model, projectsNavigation: $projectsNavigation, fetchProjects: fetchProjects)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // clicking anywhere will remove focus from whatever may have focus
        // mostly using this to remove focus from textfields when you click outside of them
        // using a frame using all the available space to make it more effective
//        .onTapGesture {
//            NSApplication.shared.keyWindow?.makeFirstResponder(nil)
//        }
        .onAppear {
            if let id = projectsNavigation.last?.id {
                if let projectData = try! ProjectDetailData.getProject(with: id, from: appDatabase) {
                    store.selectedProject = ProjectViewModel(data: projectData, projectsNavigation: projectsNavigation)
                } else {
                    // TODO: navigate back to main screen because project loading was unsuccessful
                    // show an error
                }
            } else {
                // navigate back to main view and show an error
            }
            isLoading = false
        }
    }
}

struct Project: View {
    // used for dismissing a view(basically the back button)
    @Environment(\.dismiss) private var dismiss
    @State var model: ProjectDetailData
    @Binding var projectsNavigation: [ProjectMetadata]
    let fetchProjects: () -> Void
    @State var currentView = CurrentView.details
    @State var name = ""
    @State var showAddTextboxPopup = false
    @State var doesProjectHaveName = false
    @State private var pickerItem: PhotosPickerItem?
    @State private var photosAppSelectedImage: Data?
    @State private var showPhotoPicker = false

    var body: some View {
        VStack {
            TabView(selection: $currentView) {
                Tab("Details", systemImage: "tray.and.arrow.down.fill", value: .details) {
                    ProjectDetails(project: $model.project, projectSections: $model.projectSections, projectsNavigation: $projectsNavigation)
                }
//                 Tab("Images", systemImage: "photo.artframe", value: .images) {
// //                    ImagesView(projectImages: $model.projectImages)
//                     ImagesView(model: ImagesViewModel(projectImages: model.projectImages ?? ProjectImages(projectId: model.project.data.id)))
//                 }
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    BackButton {
                        dismiss()
                        fetchProjects()
                    }
                }
            }.toolbar {
                ToolbarItem(placement: .primaryAction) {
                    if currentView == CurrentView.details {
                        Button {
                            do {
                                try model.projectSections.addSection(projectId: model.project.data.id)
                            } catch {
                                fatalError("\(error)")
                            }
                        } label: {
                            Image(systemName: "plus")
                        }
                        .buttonStyle(AddNewSectionButtonStyle())
                        .accessibilityIdentifier("AddNewSectionButton")
                    } else if currentView == CurrentView.images {
                        Button { showPhotoPicker = true } label: {
                            Image(systemName: "photo.badge.plus")
                        }
                        .buttonStyle(AddImageButtonStyle())
                        .photosPicker(isPresented: $showPhotoPicker, selection: $pickerItem, matching: .images)
                        .onChange(of: pickerItem) {
                            Task {
                                let result = try await pickerItem?.loadTransferable(type: Data.self)

                                switch result {
                                case let .some(files):
                                    let img = UIImage(data: files)!
                                    // TODO: Performance problem here, scale the images in a background task
                                    let resizedImage = img.scaleToAppImageMaxDimension()
                                    let projectImage = ProjectImageInput(image: img)
                                    try! model.projectImages?.importImages([projectImage])
                                case .none:
                                    // TODO: think about how to deal with path that couldn't become an image
                                    // I'm thinking display an error alert that lists every image that couldn't be uploaded
                                    print("couldn't load image")
                                    //                                        errorToast = ErrorToast(show: true, message: "Error importing images. Please try again later")
                                    // log error
                                }
                            }
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        // clicking anywhere will remove focus from whatever may have focus
        // mostly using this to remove focus from textfields when you click outside of them
        // using a frame using all the available space to make it more effective
//        .onTapGesture {
//            NSApplication.shared.keyWindow?.makeFirstResponder(nil)
//        }
    }
}

struct BackButton: View {
    let buttonAction: () -> Void
    var body: some View {
        Button(action: buttonAction) {
            Image(systemName: "chevron.left")
        }
    }
}
