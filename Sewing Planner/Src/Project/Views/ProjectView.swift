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

struct LoadProjectView: View {
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
                ProjectView(
                    // safe to unwrap because this view isn't presented until isLoading is false
                    // if loading the project fails then the view navigates back to all the projects
                    // meaning this project view won't be displayed
                    model: store.selectedProject!, projectsNavigation: $projectsNavigation,
                    fetchProjects: fetchProjects)
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
                if let projectData = try! ProjectDetailData.getProject(with: id, from: appDatabase)
                {
                    store.selectedProject = ProjectViewModel(
                        data: projectData, projectsNavigation: projectsNavigation)
                } else {
                    dismiss()
                    // TODO: navigate back to main screen because project loading was unsuccessful
                    // show an error
                }
            } else {
                dismiss()
                // navigate back to main view and show an error
            }
            isLoading = false
        }
    }
}

struct ProjectView: View {
    // used for dismissing a view(basically the back button)
    @Environment(\.dismiss) private var dismiss
    @State var model: ProjectViewModel
    @Binding var projectsNavigation: [ProjectMetadata]
    let fetchProjects: () -> Void

    var body: some View {
        VStack {
            TabView(selection: $model.currentView) {
                Tab("Details", systemImage: "list.bullet.rectangle.portrait", value: .details) {
                    ProjectDetailsView(
                        project: $model.projectDetails.project,
                        projectSections: $model.projectDetails.projectSections
                    )
                }
                Tab("Images", systemImage: "photo.artframe", value: .images) {
                    ImagesView(
                        model: ImagesViewModel(
                            projectImages: model.projectImages
                                ?? ProjectImages(projectId: model.projectDetails.project.data.id)))
                }
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
                    if model.currentView == CurrentView.details {
                        Button {
                            model.addSection()
                        } label: {
                            Image(systemName: "plus")
                        }
                        .buttonStyle(AddNewSectionButtonStyle())
                        .accessibilityIdentifier("AddNewSectionButton")
                    } else if model.currentView == CurrentView.images {
                        Button {
                            model.showPhotoPickerView()
                        } label: {
                            Image(systemName: "photo.badge.plus")
                        }
                        .buttonStyle(AddImageButtonStyle())
                        .photosPicker(
                            isPresented: $model.showPhotoPicker, selection: $model.pickerItem,
                            matching: .images
                        )
                        .onChange(of: model.pickerItem) {
                            model.handleOnChangePickerItem()
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

@Observable
class ProjectViewModel {
    var projectDetails: ProjectDetailData
    var projectsNavigation: [ProjectMetadata]
    var projectImages: ProjectImages?
    var deletedImages: [ProjectImage] = []
    // let fetchProjects: () -> Void
    var currentView = CurrentView.details
    var name = ""
    var showAddTextboxPopup = false
    var doesProjectHaveName = false
    var pickerItem: PhotosPickerItem?
    private var photosAppSelectedImage: Data?
    var showPhotoPicker = false

    init(data: ProjectDetailData, projectsNavigation: [ProjectMetadata]) {
        self.projectDetails = data
        self.projectsNavigation = projectsNavigation
    }

    static func getProject(projectId: Int64, db: AppDatabase) throws -> ProjectViewModel {
        let projectData = try! ProjectDetailData.getProject(with: projectId, from: db)
        return ProjectViewModel(data: projectData!, projectsNavigation: [])
    }

    func addSection() {
        do {
            try projectDetails.projectSections.addSection(
                projectId: projectDetails.project.data.id)
        } catch {
            fatalError("\(error)")
        }
    }

    func showPhotoPickerView() {
        showPhotoPicker = true
    }

    func handleOnChangePickerItem() {
        Task {
            let result = try await pickerItem?.loadTransferable(type: Data.self)

            switch result {
            case .some(let files):
                let img = UIImage(data: files)!
                // TODO: Performance problem here, scale the images in a background task
                let resizedImage = img.scaleToAppImageMaxDimension()
                let projectImage = ProjectImageInput(image: resizedImage)
                try! projectImages?.importImages([projectImage])
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

struct BackButton: View {
    let buttonAction: () -> Void
    var body: some View {
        Button(action: buttonAction) {
            Image(systemName: "chevron.left")
        }
    }
}
