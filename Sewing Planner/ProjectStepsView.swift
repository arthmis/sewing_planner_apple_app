//
//  ProjectStepsView.swift
//  Sewing Planner
//
//  Created by Art on 6/21/24.
//

import SwiftUI
import GRDB

struct ProjectStepData: Hashable, Identifiable, Codable, EncodableRecord, FetchableRecord, MutablePersistableRecord, TableRecord {
    var id: Int64?
    var projectId: Int64 = 0
    var text: String
    var completed: Bool
    var createDate: Date
    var updateDate: Date
    static let databaseTableName = "projectStep"
    
    mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }
    
    init(text: String, isComplete: Bool) {
        self.text = text
        self.completed = isComplete
        let now = Date()
        self.createDate = now
        self.updateDate = now
    }
}

struct ProjectStep: Hashable {
    var isEditing: Bool
    var data: ProjectStepData
    
    init(text: String, isComplete: Bool, isEditing: Bool) {
        self.isEditing = isEditing
        self.data = ProjectStepData(text: text, isComplete: isComplete)
    }
}

struct ProjectStepsView: View {
    @Binding var projectSteps: [ProjectStep]
    @Binding var deletedProjectSteps: [ProjectStep]
    @FocusState var isFocused: Bool
    @State var isAddingInstruction = false
    @State var newStep = ""
    
    func deleteStep(at offsets: IndexSet) {
        offsets.forEach { index in
            let step = projectSteps.remove(at: index)
            deletedProjectSteps.append(step)
        }
    }
    private var isNewStepValid: Bool {
        newStep.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private func resetAddStep() {
        isAddingInstruction = false
        newStep = ""
    }
    
    
    var body: some View {
        List {
            ForEach($projectSteps, id: \.self.data) { $step in
                ProjectStepView(text: $step.data.text, isEditing: $step.isEditing, isComplete: $step.data.completed)
            }
            .onDelete(perform: deleteStep)
            .onMove { indexSet, offset in
                projectSteps.move(fromOffsets: indexSet, toOffset: offset)
            }.accessibilityIdentifier("AllSteps")
            
        }
        if isAddingInstruction {
            HStack {
                TextField("write your instruction", text: $newStep).onSubmit {
                    // TODO: add a popup telling user that instruction can't be empty
                    guard !isNewStepValid else { return }

                    projectSteps.append(
                        ProjectStep(text: newStep, isComplete: false, isEditing: false))
                    
                    resetAddStep()
                }
                    .accessibilityIdentifier("NewStepTextField")
                    .textFieldStyle(PrimaryTextFieldStyle())
                Button("Cancel") {
                    resetAddStep()
                }
                .buttonStyle(SecondaryButtonStyle())
                Button("Add") {
                    // add a popup telling user that instruction can't be empty
                    // guard !newStep.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                    guard !isNewStepValid else { return }
                    
                    // think about what to do here for validation or something
                    
                    projectSteps.append(
                        ProjectStep(text: newStep, isComplete: false, isEditing: false))
                    
                    resetAddStep()
                }
                .buttonStyle(PrimaryButtonStyle())
                .accessibilityIdentifier("AddNewStepButton")
            }
        }
        Button("New Step") {
            isAddingInstruction = true
        }
        .accessibilityIdentifier("NewStepButton")
        
        
    }
}

