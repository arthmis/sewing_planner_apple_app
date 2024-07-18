//
//  ProjectView.swift
//  Sewing Planner
//
//  Created by Art on 7/9/24.
//

import SwiftUI

struct NewProjectView: View {
  @State var clicked = true
  @State var name = ""
  @State var newStep = ""
  @State var projectSteps: [ProjectStepData] = [ProjectStepData]()
  @State var showAddTextboxPopup = false
  @State var isAddingInstruction = false

  private var isNewStepValid: Bool {
    newStep.trimmingCharacters(in: .whitespaces).isEmpty
  }

  var body: some View {
    VStack {
      TextField("Enter project name", text: $name)
        .accessibilityIdentifier("ProjectNameTextfield")
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
            .accessibilityIdentifier("NewStepTextField")

          Button("Cancel") {
            isAddingInstruction = false
            newStep = ""
          }
          Button("Add") {
            // add a popup telling user that instruction can't be empty
            // guard !newStep.trimmingCharacters(in: .whitespaces).isEmpty else { return }
            guard !isNewStepValid else { return }

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
      }
    }
  }
}
