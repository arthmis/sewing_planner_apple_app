//
//  ProjectView.swift
//  Sewing Planner
//
//  Created by Art on 7/9/24.
//

import GRDB
import SwiftUI

struct ProjectView: View {
    // used for dismissing a view(basically the back button)
    @Environment(\.dismiss) private var dismiss
    @StateObject var model = ProjectDetailData()
    @Binding var projectsNavigation: [ProjectMetadata]
    let fetchProjects: () -> ()
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
                    HSplitView {
                        ProjectDetails(project: model.project, projectSections: model.projectSections, projectsNavigation: $projectsNavigation)
                            .frame(minWidth: 500, maxWidth: 600)
                        ImagesView(projectImages: model.projectImages)
                    }.frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .navigationBarBackButtonHidden(true).toolbar {
                    ToolbarItem(placement: .navigation) {
                        BackButton {
                            dismiss()
                            fetchProjects()
                        }
                        .accessibilityIdentifier("ProjectViewCustomBackButton")
                    }
                }
            }
        }
        // clicking anywhere will remove focus from whatever may have focus
        // mostly using this to remove focus from textfields when you click outside of them
        // using a frame using all the available space to make it more effective
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .onTapGesture {
            NSApplication.shared.keyWindow?.makeFirstResponder(nil)
        }
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
            HStack(alignment: VerticalAlignment.center) {
                Image(systemName: "arrowshape.backward.fill")
                Text("Back")
            }
        }
    }
}
