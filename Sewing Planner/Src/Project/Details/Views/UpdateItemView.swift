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
    @State var showErrorText = false
    let errorText = "Item text can't be empty."
    let updateText: (Int64, String) throws -> Void
    let resetToPreviousText: () -> Void

    private var isNewTextValid: Bool {
        newText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && newText != data.text
    }

    func update() {
        guard !isNewTextValid else {
            showErrorText = true
            return
        }

        let validText = newText.trimmingCharacters(in: .whitespacesAndNewlines)
        do {
            try updateText(data.id!, validText)
            data.text = validText
        } catch {
            fatalError("\(error)")
        }
        showErrorText = false
        isEditing = false
    }

    var body: some View {
        VStack(alignment: .leading) {
            TextField("", text: $newText, axis: .vertical)
                .textFieldStyle(.plain)
                .primaryTextFieldStyle(when: newText.isEmpty, placeholder: "type item")
                .onSubmit {
                    update()
                }
            if showErrorText {
                Text(errorText)
                    .padding(.leading, 10)
                    .foregroundStyle(Color.red)
            }
            HStack(alignment: .center) {
                Button("Update") {
                    update()
                }
                .disabled(isNewTextValid)
                .buttonStyle(PrimaryButtonStyle())
                Button("Cancel") {
                    resetToPreviousText()
                }
                .buttonStyle(SecondaryButtonStyle())
            }
        }
    }
}

#Preview {
    @Previewable @State var record = SectionItemRecord(id: 1, text: "something")
    @Previewable @State var isEditing = true
    @Previewable @State var newText = ""
    UpdateItemView(data: $record, isEditing: $isEditing, newText: $newText, updateText: { id, text throws in print(id ?? 1, text) }, resetToPreviousText: { () in print("resetting") })
        .frame(height: 300)
}
