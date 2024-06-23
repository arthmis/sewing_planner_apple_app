//
//  ContentView.swift
//  Sewing Planner
//
//  Created by Art on 5/9/24.
//

import SwiftUI

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

struct ContentView: View {
  @State var clicked = true
  @State var name = ""
  @State var newStep = ""
  let values = ["thing 1", "thing 2"]
  @State var projectSteps: [ProjectStepData] = [ProjectStepData]()
  @State var showAddTextboxPopup = false
  @State private var selectItem = "Thing"
  @State private var time = Date.now
  @State var isAddingInstruction = false

  var body: some View {
    TextField("Enter project name", text: $name)
    Text(name)
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

        Button("Cancel") {
          isAddingInstruction = false
          newStep = ""
        }
        Button("Add") {
          // add a popup telling user that instruction can't be empty
          guard !newStep.isEmpty else { return }

          projectSteps.append(ProjectStepData(text: newStep, isEditing: false, isComplete: false))
          newStep = ""
          isAddingInstruction = false

        }
      }
    }
    Form {
      Button("New Step") {
        isAddingInstruction = true
      }
    }
  }
}

#Preview {
  ContentView()
}
