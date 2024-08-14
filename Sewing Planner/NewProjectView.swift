//
//  ProjectView.swift
//  Sewing Planner
//
//  Created by Art on 7/9/24.
//

import GRDB
import SwiftUI

struct NewProjectView: View {
    // used for dismissing a view(basically the back button)
    @Environment(\.dismiss) private var dismiss
    @Environment(\.appDatabase) private var appDatabase
    @State var clicked = true
    var projectId: Int64 = 0
    @State var project = Project()
    @State var name = ""
    @State var newStep = ""
    @State var projectSteps: [ProjectStepData] = [ProjectStepData]()
    @State var showAddTextboxPopup = false
    @State var isAddingInstruction = false
    @State var doesProjectHaveName = false
    @State var showAlertIfProjectNotSaved = false
    @Binding var projectsNavigation: [Project]
    @State var materials: [MaterialData] = []

    private var isNewStepValid: Bool {
        newStep.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    private var isProjectValid: Bool {
        !project.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private var isNewProjectEmpty: Bool {
        project.name.trimmingCharacters(in: .whitespaces).isEmpty && projectSteps.isEmpty
    }
    
    var body: some View {
        VStack {
            VStack {
                ProjectName(project: $project)
                ProjectStepsView(projectSteps: self.$projectSteps)
                if isAddingInstruction {
                    HStack {
                        TextField("write your instruction", text: $newStep).onSubmit {
                            // add a popup telling user that instruction can't be empty
                            guard !newStep.isEmpty else { return }
                            projectSteps.append(
                                ProjectStepData(text: newStep, isEditing: false, isComplete: false))
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
                                ProjectStepData(text: newStep, isEditing: false, isComplete: false))
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
                
                let projectId = try! appDatabase.addProject(name: "")
                project = Project(name: "", id: projectId)
                print("creating project with id: \(projectId)")
                // add alert that says they need to pass validation
                print(project.name)
                print(projectSteps.count)
                
                do {
                    for step in projectSteps {
                        try appDatabase.addProjectStep(text: step.text, projectId: project.id)
                    }
                } catch {
                    fatalError(
                        "error when inserting step: \(newStep) for project id: \(project.id)\n\n\(error)")
                }
                
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
                                    let projectId = try! appDatabase.addProject(name: project.name)
                                    project = Project(name: project.name, id: projectId)
                                    print("creating project with id: \(projectId)")
                                    
                                    do {
                                        for step in projectSteps {
                                            try appDatabase.addProjectStep(text: step.text, projectId: project.id)
                                        }
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
