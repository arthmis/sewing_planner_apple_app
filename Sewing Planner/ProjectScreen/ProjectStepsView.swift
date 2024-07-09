//
//  ProjectStepsView.swift
//  Sewing Planner
//
//  Created by Art on 6/21/24.
//

import SwiftUI

struct ProjectStepsView: View {
  @Binding var projectSteps: [ProjectStepData]
  @FocusState var isFocused: Bool

  func deleteStep(at offsets: IndexSet) {
    self.projectSteps.remove(atOffsets: offsets)
  }

  var body: some View {
    List {
      ForEach($projectSteps, id: \.id) { $step in
        ProjectStep(text: $step.text, isEditing: $step.isEditing, isComplete: $step.isComplete)
      }
      .onDelete(perform: deleteStep)
      .onMove { indexSet, offset in
        projectSteps.move(fromOffsets: indexSet, toOffset: offset)
      }.accessibilityIdentifier("AllSteps")

    }
  }
}

struct ProjectStepData: Hashable, Identifiable {
  var id: UUID
  var text: String
  var isEditing: Bool
  var isComplete: Bool

  init(text: String, isEditing: Bool, isComplete: Bool) {
    self.id = UUID()
    self.text = text
    self.isEditing = isEditing
    self.isComplete = isComplete
  }

  func getId() -> UUID {
    return self.id
  }
}
