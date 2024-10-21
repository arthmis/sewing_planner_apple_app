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
    @State var name = ""
    var projectId: Int64?
    @State var showAddTextboxPopup = false
    @State var doesProjectHaveName = false
    @State var showAlertIfProjectNotSaved = false
    @State var isLoading = true
    @Binding var projectsNavigation: [Project]
    
    private var isProjectValid: Bool {
        !model.project.data.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private var isNewProjectEmpty: Bool {
        model.project.data.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func saveProject() throws {
        guard isProjectValid else {
            showAlertIfProjectNotSaved = true
            return
        }
        
        do {
            let projectId = try model.saveProject()
        } catch {
            fatalError(
                "error adding steps and materials for project id: \(model.project.data.id)\n\n\(error)")
        }
        projectsNavigation.removeLast()
    }
    
    var body: some View {
        VStack {
            if isLoading {
                Text("is loading...")
            } else {
                VStack {
                    HSplitView {
                        ProjectDetails(project: model.project, projectSections: model.projectSections, projectsNavigation: $projectsNavigation)
                        ImageSketchesView(projectId: projectId, projectImages: model.projectImages)
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
                                    // make this into a view and pass in the project object for reactivity
                                    VStack {
                                        if !isProjectValid {
                                            TextField("Enter a project name", text: $name).accessibilityIdentifier(
                                                "ProjectNameTextFieldInAlertUnsavedProject")
                                            
                                        }
                                        Button(role: .destructive) {
                                            // no need to do anything as changes haven't been saved yet
                                            dismiss()
                                        } label: {
                                            Text("Discard")
                                        }
                                        Button("Save") {
                                            // have a toast in return or just display something under the textfield saying name can't be empty
                                            guard isProjectValid else { return }
                                            
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
                        .frame(maxWidth: .infinity, maxHeight: .infinity).background(Color.white).border(Color.blue)
                }
                
            }
        }
        .task {
            if let id = projectId {
                print(id)
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
