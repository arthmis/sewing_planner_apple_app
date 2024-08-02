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
    
    
    
    private var isNewStepValid: Bool {
        newStep.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    private var isProjectValid: Bool {
        !project.name.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    private var isNewProjectEmpty: Bool {
        project.name.trimmingCharacters(in: .whitespaces).isEmpty && projectSteps.isEmpty
    }
    
    var body: some View {
        VStack {
            ProjectName(project: $project)
            ProjectStepsView(projectSteps: self.$projectSteps)
            if isAddingInstruction {
                HStack {
                    TextField("write your instruction", text: $newStep).onSubmit {
                        // add a popup telling user that instruction can't be empty
                        guard !newStep.isEmpty else { return }
                        projectSteps.append(ProjectStepData(text: newStep, isEditing: false, isComplete: false))
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
                        
                        do {
                            try appDatabase.addProjectStep(text: newStep, projectId: project.id)
                        } catch {
                            fatalError("error when inserting step: \(newStep) for project id: \(project.id)\n\n\(error)")
                        }
                        
                        projectSteps.append(ProjectStepData(text: newStep, isEditing: false, isComplete: false))
                        newStep = ""
                        isAddingInstruction = false
                        
                    }.disabled(isNewStepValid)
                        .accessibilityIdentifier("AddNewStepButton")
                }
            }
            Form {
                Button("New Step") {
                    isAddingInstruction = true
                }.accessibilityIdentifier("NewStepButton")
                Button("Save") {
                    guard isProjectValid else {
                        showAlertIfProjectNotSaved = true
                        return }
                    
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
                        fatalError("error when inserting step: \(newStep) for project id: \(project.id)\n\n\(error)")
                    }
                    
                    
                    projectsNavigation.removeLast()
                    
                }.accessibilityIdentifier("SaveButton")
                    .alert("Unsaved Changes", isPresented: $showAlertIfProjectNotSaved) {
                        HStack {
                            TextField("Enter a project name", text: $project.name)
                            Button("Save") {
                                let projectId = try! appDatabase.addProject(name: project.name)
                                project = Project(name: project.name, id: projectId)
                                print("creating project with id: \(projectId)")
                                
                                do {
                                    for step in projectSteps {
                                        try appDatabase.addProjectStep(text: step.text, projectId: project.id)
                                    }
                                } catch {
                                    fatalError("error when inserting step: \(newStep) for project id: \(project.id)\n\n\(error)")
                                }
                                
                                dismiss()
                            }
                            Button(role: .destructive) {
                                dismiss()
                            } label: {
                                Text("Discard")
                            }
                            
                        }
                    } message: {
                        Text("Enter a name to save this project.")
                    }
                
            }
        }
        .navigationBarBackButtonHidden(true).toolbar {
            ToolbarItem(placement: .navigation) {
                Button {
                    if isNewProjectEmpty {
                        dismiss()
                        return
                    }
                    
                    showAlertIfProjectNotSaved = true
                } label: {
                    HStack(alignment: VerticalAlignment.center) {
                        Image(systemName: "arrowshape.backward.fill")
                        Text("Back")
                    }
                }
                .alert("Unsaved Changes", isPresented: $showAlertIfProjectNotSaved) {
                    VStack {
                        
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
                                fatalError("error when inserting step: \(newStep) for project id: \(project.id)\n\n\(error)")
                            }
                            
                            dismiss()
                        }.keyboardShortcut(/*@START_MENU_TOKEN@*/.defaultAction/*@END_MENU_TOKEN@*/)
                    }
                } message: {
                    Text("Do you want to save this project?")
                }
            }
        }
        
    }
}
