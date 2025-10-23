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
    // @State var isLoading = true

    var body: some View {
        VStack {
            if let project = store.selectedProject {
                ProjectView(
                    project: project, projectsNavigation: $projectsNavigation,
                    fetchProjects: fetchProjects
                )
            } else {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
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
                do {
                    let maybeProjectData = try ProjectData.getProject(with: id, from: appDatabase)
                    if let projectData = maybeProjectData {
                        store.selectedProject = ProjectViewModel(
                            data: projectData, projectsNavigation: projectsNavigation,
                            projectImages: ProjectImages(projectId: projectData.data.id)
                        )
                    } else {
                        dismiss()
                        store.appError = .loadProject
                        // TODO: show an error
                    }
                } catch {
                    dismiss()
                    store.appError = .loadProject
                    // TODO: show an error
                }
            } else {
                dismiss()
                store.appError = .loadProject
                // navigate back to main view and show an error
                // this basically shouldn't happen because there must be a project in projects navigation at this point, which means
                // there is an id
            }
        }
    }
}

struct ProjectView: View {
    // used for dismissing a view(basically the back button)
    @Environment(\.dismiss) private var dismiss
    @Environment(\.store) private var store
    @State var project: ProjectViewModel
    @Binding var projectsNavigation: [ProjectMetadata]
    let fetchProjects: () -> Void

    var body: some View {
        VStack {
            TabView(selection: $project.currentView) {
                Tab("Details", systemImage: "list.bullet.rectangle.portrait", value: .details) {
                    ProjectDataView(
                    )
                }
                Tab("Images", systemImage: "photo.artframe", value: .images) {
                    ImagesView(model: $project.projectImages)
                }
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigation) {
                    BackButton {
                        dismiss()
                        store.selectedProject = nil
                        fetchProjects()
                    }
                }
            }.toolbar {
                ToolbarItem(placement: .primaryAction) {
                    if project.currentView == CurrentView.details {
                        Button {
                            project.addSection()
                        } label: {
                            Image(systemName: "plus")
                        }
                        .buttonStyle(AddNewSectionButtonStyle())
                        .accessibilityIdentifier("AddNewSectionButton")
                    } else if project.currentView == CurrentView.images {
                        Button {
                            project.showPhotoPickerView()
                        } label: {
                            Image(systemName: "photo.badge.plus")
                        }
                        .buttonStyle(AddImageButtonStyle())
                        .photosPicker(
                            isPresented: $project.showPhotoPicker, selection: $project.pickerItem,
                            matching: .images
                        )
                        .onChange(of: project.pickerItem) {
                            Task {
                                await project.handleOnChangePickerItem()
                            }
                        }
                    }
                }
            }
        }
        .overlay(alignment: .top) {
            Toast(showToast: $project.projectError)
                .padding(.horizontal, 16)
                .transition(.move(edge: .top))
                .animation(.easeOut(duration: 0.15), value: project.projectError)
        }
        .frame(
            maxWidth: .infinity,
            maxHeight: .infinity
        )
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .environment(project)
        // clicking anywhere will remove focus from whatever may have focus
        // mostly using this to remove focus from textfields when you click outside of them
        // using a frame using all the available space to make it more effective
        //        .onTapGesture {
        //            NSApplication.shared.keyWindow?.makeFirstResponder(nil)
        //        }
    }
}

enum ProjectError: Error, Equatable {
    case addSection
    case addSectionItem
    case updateSectionItemText
    case updateSectionItemCompletion
    case importImage
    case deleteSection
    case deleteSectionItems
    case reOrderSectionItems
    case renameProject
    case deleteImages
    case loadImages
    case genericError
}

struct ErrorToast: Equatable {
    var show: Bool
    let message: String

    init(show: Bool = false, message: String = "Something went wrong. Please try again") {
        self.show = show
        self.message = message
    }
}

@Observable
class ProjectViewModel {
    var projectData: ProjectData
    var projectsNavigation: [ProjectMetadata]
    var projectImages: ProjectImages
    var deletedImages: [ProjectImage] = []
    // let fetchProjects: () -> Void
    var currentView = CurrentView.details
    var name = ""
    var showAddTextboxPopup = false
    var doesProjectHaveName = false
    var pickerItem: PhotosPickerItem?
    private var photosAppSelectedImage: Data?
    var showPhotoPicker = false
    var projectError: ProjectError?

    init(
        data: ProjectData, projectsNavigation: [ProjectMetadata], projectImages: ProjectImages
    ) {
        projectData = data
        self.projectsNavigation = projectsNavigation
        self.projectImages = projectImages
    }

    func addSection() {
        do {
            try projectData.addSection()
        } catch {
            projectError = .addSection
        }
    }

    func handleError(error: ProjectError) {
        projectError = error
    }

    func showPhotoPickerView() {
        showPhotoPicker = true
    }

    func handleOnChangePickerItem() async {
        do {
            try await handleOnChangePickerItemInner()
        } catch {
            projectError = .importImage
        }
    }

    private func handleOnChangePickerItemInner() async throws {
        let result = try await pickerItem?.loadTransferable(type: Data.self)

        switch result {
        case let .some(files):
            // fix this unwrap by throwing an error, display to user
            guard let img = UIImage(data: files) else {
                throw ProjectError.importImage
            }
            // TODO: Performance problem here, scale the images in a background task
            let resizedImage = img.scaleToAppImageMaxDimension()
            let projectImage = ProjectImageInput(image: resizedImage)
            try projectImages.importImages([projectImage])
        case .none:
            // TODO: think about how to deal with path that couldn't become an image
            // I'm thinking display an error alert that lists every image that couldn't be uploaded
            projectError = .importImage
            // errorToast = ErrorToast(show: true, message: "Error importing images. Please try again later")
            // log error
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
