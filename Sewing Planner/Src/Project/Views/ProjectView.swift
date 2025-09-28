//
//  ProjectView.swift
//  Sewing Planner
//
//  Created by Art on 7/9/24.
//

import GRDB
import SwiftUI

enum CurrentView {
    case details
    case images
}

struct ProjectView: View {
    // used for dismissing a view(basically the back button)
    @Environment(\.dismiss) private var dismiss
    @State var model = ProjectDetailData()
    @Binding var projectsNavigation: [ProjectMetadata]
    let fetchProjects: () -> Void
    @State var currentView = CurrentView.details
    @State var name = ""
    @State var showAddTextboxPopup = false
    @State var doesProjectHaveName = false
    @State var isLoading = true

    private var isProjectValid: Bool {
        !model.project.data.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var isNewProjectEmpty: Bool {
        model.project.data.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack {
            if isLoading {
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                VStack {
                    TabView(selection: $currentView) {
                        Tab("Details", systemImage: "tray.and.arrow.down.fill", value: .details) {
                            ProjectDetails(project: $model.project, projectSections: $model.projectSections, projectsNavigation: $projectsNavigation)
                        }
                        Tab("Images", systemImage: "photo.artframe", value: .images) {
                            ImagesView(projectImages: $model.projectImages)
                        }
                    }
                }
                .navigationBarBackButtonHidden(true).toolbar {
                    ToolbarItem(placement: .navigation) {
                        BackButton {
                            dismiss()
                            fetchProjects()
                        }
                        .accessibilityIdentifier("ProjectViewCustomBackButton")
                    }
                    ToolbarItem(placement: .primaryAction) {
                        Button {
                            do {
                                try model.projectSections.addSection(projectId: model.project.data.id!)
                            } catch {
                                fatalError("\(error)")
                            }
                        } label: {
                            Image(systemName: "plus")
                        }
                        .buttonStyle(AddNewSectionButtonStyle())
                        .accessibilityIdentifier("AddNewSectionButton")
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
        .task {
            if let id = projectsNavigation.last?.id! {
                self.model.getProject(with: id)
            }
            isLoading = false
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
