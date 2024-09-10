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
    @FocusState var isFocused: Bool
    
    func deleteStep(at offsets: IndexSet) {
        self.projectSteps.remove(atOffsets: offsets)
    }
    
    var body: some View {
        List {
            ForEach($projectSteps, id: \.self.data.id) { $step in
                ProjectStepView(text: $step.data.text, isEditing: $step.isEditing, isComplete: $step.data.completed)
            }
            .onDelete(perform: deleteStep)
            .onMove { indexSet, offset in
                projectSteps.move(fromOffsets: indexSet, toOffset: offset)
            }.accessibilityIdentifier("AllSteps")
            
        }
    }
}

