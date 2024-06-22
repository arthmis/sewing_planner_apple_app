//
//  ProjectStepsView.swift
//  Sewing Planner
//
//  Created by Art on 6/21/24.
//

import SwiftUI

struct AddStepView: View {
  @State var newStep = ""
  // @Binding var showAddTextboxPopup: Bool
  @Binding var steps: [String]

  var body: some View {
    Form {
      TextField("Write new step", text: $newStep)
      Button("Add step") {
        self.steps.append(self.newStep)
        // self.showAddTextboxPopup = false
      }
    }
  }
}

// #Preview {
//   ProjectStepsView()
// }
