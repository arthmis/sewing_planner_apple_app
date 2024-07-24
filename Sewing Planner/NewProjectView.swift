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
    @State var unsaved = false
    @Binding var projectsNavigation: [Project]
    
    
    private var isNewStepValid: Bool {
        newStep.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    private var isProjectValid: Bool {
        !project.name.trimmingCharacters(in: .whitespaces).isEmpty
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
                        
                        do {
                            try appDatabase.addProjectStep(text: newStep, projectId: project.id)
                        } catch {
                            fatalError("error when inserting step: \(newStep) for project id: \(project.id)\n\n\(error)")
                        }
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
                    // add alert that says they need to pass validation
                    print(project.name)
                    print(projectSteps.count)
                    guard isProjectValid else { return }
                    
                    projectsNavigation.removeLast()
                    
                }.accessibilityIdentifier("SaveButton")
            }
        }.onAppear {
            let projectId = try! appDatabase.addProject(name: "")
            project = Project(name: "New Project", id: projectId)
            print("creating project with id: \(projectId)")
        }.navigationBarBackButtonHidden(true).toolbar {
            ToolbarItem(placement: .navigation) {
                Button {
                    // TODO: check that project is valid
                    guard isProjectValid else {
                        unsaved = true
                        return
                    }
                    dismiss()
                } label: {
                    HStack(alignment: VerticalAlignment.center) {
                        Image(systemName: "arrowshape.backward.fill")
                        Text("Back")
                    }
                }
                .alert("Unsaved Changes", isPresented: $unsaved) {
                    HStack {
                        
                        Button(role: .destructive) {
                            // TODO: do deletion
                            dismiss()
                        } label: {
                            Text("Discard")
                        }
                        Button("Save") {
                            // TODO: handle saving the data
                            dismiss()
                        }
                    }
                } message: {
                    Text("Do you want to save this project?")
                }
            }
        }
        
    }
}
