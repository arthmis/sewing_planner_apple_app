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
    @Binding var project: Project
    @State var name = ""
    @State var newStep = ""
    @Binding var projectSteps: [ProjectStep]
    @Binding var materials: [MaterialRecord]
    @Binding var deletedMaterials: [MaterialRecord]
    @State var showAddTextboxPopup = false
    @State var isAddingInstruction = false
    @State var doesProjectHaveName = false
    @State var showAlertIfProjectNotSaved = false
    @Binding var projectsNavigation: [Project]
    
    private var isNewStepValid: Bool {
        newStep.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
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
            MaterialList(materials: $materials, deletedMaterials: $deletedMaterials)
        }.background(Color.white).border(.red, width: 4)
    }
}

//#Preview {
//    ProjectDetails()
//}
