//
//  ProjectStep.swift
//  Sewing Planner
//
//  Created by Art on 6/21/24.
//

import SwiftUI

struct ProjectStepView: View {
    @Binding var text: String
    @Binding var isEditing: Bool
    @Binding var isComplete: Bool
    @State var newText = ""
    
    var body: some View {
        HStack {
            Toggle(text, isOn: $isComplete).toggleStyle(.checkbox)
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
    
    private var isNewTextValid: Bool {
        newText.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var body: some View {
        
        HStack {
            TextField("write your instruction", text: $newText).onSubmit {
                guard !isNewTextValid else { return }
                
                originalText = newText
                newText = ""
                isEditing = false
            }.textFieldStyle(.plain)
            Button("Cancel") {
                newText = originalText
                isEditing = false
            }
            Button("Update") {
                originalText = newText.trimmingCharacters(in: .whitespacesAndNewlines)
                newText = originalText
                isEditing = false
            }.disabled(isNewTextValid)
        }
    }
}

//   ProjectStep()
// }
