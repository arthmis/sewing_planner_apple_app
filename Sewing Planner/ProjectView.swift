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
    @Environment(\.appDatabase) private var appDatabase
    @State var clicked = true
    var projectId: Int64 = 0
    @State var project = Project()
    @State var projectSteps: [ProjectStep] = []
    @State var showAddTextboxPopup = false
    @State var isAddingInstruction = false
    @State var doesProjectHaveName = false
    @State var showAlertIfProjectNotSaved = false
    @Binding var projectsNavigation: [Project]
    @State var projectImages: [ProjectImage] = []
    @State var deletedImages: [ProjectImage] = []
    @State var materials: [MaterialRecord] = []
    @State var deletedMaterials: [MaterialRecord] = []
    
    private var isProjectValid: Bool {
        !project.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private var isNewProjectEmpty: Bool {
        project.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && projectSteps.isEmpty
    }
    
    func saveProject() throws {
        guard isProjectValid else {
            showAlertIfProjectNotSaved = true
            return
        }
        
        do {
            let projectId = try appDatabase.saveProject(project: &project, projectSteps: projectSteps, materialData: materials, projectImages: &projectImages)
            try AppFiles().saveProjectImages(projectId: projectId, images: projectImages)
        } catch {
            print(project)
            print(materials)
            print(projectSteps)
            fatalError(
                "error adding steps and materials for project id: \(project.id)\n\n\(error)")
        }
        projectsNavigation.removeLast()
    }
    
    var body: some View {
        VStack {
            HSplitView {
                ProjectDetails(project: $project, projectSteps: $projectSteps, materials: $materials, deletedMaterials: $deletedMaterials, projectsNavigation: $projectsNavigation)
                ImageSketchesView(projectId: projectId, projectImages: $projectImages, deletedImages: $deletedImages)
            }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top).border(Color.green)
            Button("Save") {
                try! saveProject()
            }.accessibilityIdentifier("SaveButton")
                .navigationBarBackButtonHidden(true).toolbar {
                    ToolbarItem(placement: .navigation) {
                        BackButton {
                            if isNewProjectEmpty {
                                dismiss()
                                return
                            }
                            
                            showAlertIfProjectNotSaved = true
                        }
                        .accessibilityIdentifier("ProjectViewCustomBackButton")
                        .alert("Unsaved Changes", isPresented: $showAlertIfProjectNotSaved) {
                            VStack {
                                if !isProjectValid {
                                    TextField("Enter a project name", text: $project.name).accessibilityIdentifier(
                                        "ProjectNameTextFieldInAlertUnsavedProject")
                                    
                                }
                                Button(role: .destructive) {
                                    // no need to do anything as changes haven't been saved yet
                                    dismiss()
                                } label: {
                                    Text("Discard")
                                }
                                Button("Save") {
                                    do {
                                        try saveProject()
                                    } catch {
                                        fatalError("error: \(error)")
                                    }
                                    
                                    dismiss()
                                }
                                .accessibilityIdentifier("SaveButtonInAlertUnsavedProject")
                                .keyboardShortcut( /*@START_MENU_TOKEN@*/.defaultAction /*@END_MENU_TOKEN@*/)
                            }
                        } message: {
                            Text("Do you want to save this project?")
                        }
                    }
                }
        }.frame(maxWidth: .infinity, maxHeight: .infinity).background(Color.white).border(Color.blue)
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
