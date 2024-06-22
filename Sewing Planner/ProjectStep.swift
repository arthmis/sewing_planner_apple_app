//
//  ProjectStep.swift
//  Sewing Planner
//
//  Created by Art on 6/21/24.
//

import SwiftUI

struct ProjectStep: View {
  @Binding var text: String
  @Binding var isEditing: Bool
  @State var newText = ""

  var body: some View {
    HStack {
      Text(text)
      Button("\(Image(systemName: "pencil"))") {
        isEditing = true
      }
      Menu("\(Image(systemName: "ellipsis"))") {
        Button("Delete") {
        }
      }
    }
    if isEditing {
      EditStep(originalText: $text, newText: text, isEditing: $isEditing)
    }
  }
}

struct EditStep: View {
  @Binding var originalText: String
  @State var newText: String
  @Binding var isEditing: Bool

  var body: some View {

    HStack {
      TextField("write your instruction", text: $newText).onSubmit {
        guard !newText.isEmpty else { return }

        originalText = newText
        newText = ""
        isEditing = false
      }.textFieldStyle(.plain)
      Button("Cancel") {
        newText = ""
        isEditing = false
      }
      Button("Update") {
        originalText = newText
        newText = ""
        isEditing = false
      }
    }
  }
}

//   ProjectStep()
// }
