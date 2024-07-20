//
//  ProjectView.swift
//  Sewing Planner
//
//  Created by Art on 7/9/24.
//

import GRDB
import SwiftUI

struct Project: Hashable {
    var name = ""
    var id: Int64 = 0
}

struct NewProjectView: View {
    @Environment(\.appDatabase) private var appDatabase
    @State var clicked = true
    var projectId: Int64 = 0
    @State var project = Project()
    @State var name = ""
    @State var newStep = ""
    @State var projectSteps: [ProjectStepData] = [ProjectStepData]()
    @State var showAddTextboxPopup = false
    @State var isAddingInstruction = false
    @Binding var projectsNavigation: [Project]
    
    private var isNewStepValid: Bool {
        newStep.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    private var isProjectValid: Bool {
        !name.trimmingCharacters(in: .whitespaces).isEmpty && !projectSteps.isEmpty
    }
    
    var body: some View {
        VStack {
            TextField("Enter project name", text: $name)
                .accessibilityIdentifier("ProjectNameTextfield").onSubmit {
                    // add a popup telling user that name can't be empty
                    guard !project.name.isEmpty else { return }
                    do {
                        try appDatabase.updateProjectName(name: name, projectId: project.id)
                    } catch {
                        fatalError("error when inserting step: \(newStep) for project id: \(project.id)\n\n\(error)")
                    }
                    project.name = name
                }
            Text(name)
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
            project = Project(name: "", id: projectId)
            print("creating project with id: \(projectId)")
        }
    }
}
