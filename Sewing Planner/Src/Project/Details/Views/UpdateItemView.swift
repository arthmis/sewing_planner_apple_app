//
//  UpdateItemView.swift
//  Sewing Planner
//
//  Created by Art on 11/29/24.
//

import SwiftUI

struct UpdateItemView: View {
    @Binding var data: SectionItemRecord
    @Binding var isEditing: Bool
    @Binding var newText: String
    let updateText: (Int64, String) throws -> Void
    let resetToPreviousText: () -> Void

    private var isNewTextValid: Bool {
        newText.trimmingCharacters(in: .whitespaces).isEmpty && newText != data.text
    }
    
    func update() {
        guard !isNewTextValid else { return }

        do {
            try updateText(data.id!, newText)
            data.text = newText
        } catch {
            fatalError("\(error)")
        }
        isEditing = false
    }

    var body: some View {
        if isEditing {
            HStack {
                TextField("edit text", text: $newText, axis: .vertical)
                    .textFieldStyle(.plain)
                    .primaryTextFieldStyle(when: newText.isEmpty, placeholder: "type item")
                    .onSubmit {
                        update()
                    }
                Button("Cancel") {
                    resetToPreviousText()
                }
                Button("Update") {
                    update()
                }
                .disabled(isNewTextValid)
            }
        }
    }
}

// #Preview {
//    UpdateItemView()
// }
