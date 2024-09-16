//
//  ProjectDetails.swift
//  Sewing Planner
//
//  Created by Art on 9/12/24.
//

import SwiftUI

struct ProjectDetails: View {
    // used for dismissing a view(basically the back button)
    @Environment(\.dismiss) private var dismiss
    @Environment(\.appDatabase) private var appDatabase
    @State var clicked = true
    var projectId: Int64 = 0
    @State var project = Project()
    @State var name = ""
    @State var newStep = ""
    @State var projectSteps: [ProjectStep] = [ProjectStep]()
    @State var showAddTextboxPopup = false
    @State var isAddingInstruction = false
    @State var doesProjectHaveName = false
    @State var showAlertIfProjectNotSaved = false
    @Binding var projectsNavigation: [Project]
    @State var materials: [MaterialRecord] = []
    
    private var isNewStepValid: Bool {
        newStep.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private var isProjectValid: Bool {
        !project.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private var isNewProjectEmpty: Bool {
        project.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && projectSteps.isEmpty
    }
    var body: some View {
        VStack {
            ProjectName(project: $project)
            VStack {
                ProjectStepsView(projectSteps: self.$projectSteps)
                
                if isAddingInstruction {
                    HStack {
                        TextField("write your instruction", text: $newStep).onSubmit {
                            // add a popup telling user that instruction can't be empty
                            guard !newStep.isEmpty else { return }
                            projectSteps.append(
                                ProjectStep(text: newStep, isComplete: false, isEditing: false))
                            newStep = ""
                            isAddingInstruction = false
                        }.textFieldStyle(.plain)
                            .accessibilityIdentifier("NewStepTextField")
                        Button("Cancel") {
                            isAddingInstruction = false
                            newStep = ""
                        }
                        Button("Add") {
                            // add a popup telling user that instruction can't be empty
                            // guard !newStep.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                            guard !isNewStepValid else { return }
                            
                            // think about what to do here for validation or something
                            
                            projectSteps.append(
                                ProjectStep(text: newStep, isComplete: false, isEditing: false))
                            newStep = ""
                            isAddingInstruction = false
                            
                        }.disabled(isNewStepValid)
                            .accessibilityIdentifier("AddNewStepButton")
                    }
                }
                Button("New Step") {
                    isAddingInstruction = true
                }.accessibilityIdentifier("NewStepButton")
                
            }
            Divider()
            MaterialList(materials: $materials)
            Button("Save") {
                guard isProjectValid else {
                    showAlertIfProjectNotSaved = true
                    return
                }
                
                do {
                    try appDatabase.saveProject(project: &project, projectSteps: projectSteps, materialData: materials)
                } catch {
                    print(project)
                    print(materials)
                    print(projectSteps)
                    fatalError(
                        "error adding steps and materials for project id: \(project.id)\n\n\(error)")
                }
                //                try! appDatabase.getProject(projectId: projectId)
                
                projectsNavigation.removeLast()
                
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
                                        try appDatabase.saveProject(project: &project, projectSteps: projectSteps, materialData: materials)
                                    } catch {
                                        fatalError(
                                            "error when inserting step: \(newStep) for project id: \(project.id)\n\n\(error)"
                                        )
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
        }.background(Color.white).border(.red, width: 4)
    }
}

//#Preview {
//    ProjectDetails()
//}
