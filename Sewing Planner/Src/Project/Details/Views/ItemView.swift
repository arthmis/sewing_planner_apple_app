//
//  ItemView.swift
//  Sewing Planner
//
//  Created by Art on 10/11/24.
//

import SwiftUI

struct ItemView: View {
    @Binding var data: SectionItemRecord
    @State var isEditing = false
    @State var newText = ""

    private var isNewTextValid: Bool {
        newText.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        if !isEditing {
            HStack(alignment: .firstTextBaseline) {
                Toggle(data.text, isOn: $data.isComplete).toggleStyle(.checkbox)
                    .padding(.trailing, 40)
                Spacer()
                Image(systemName: "line.3.horizontal").foregroundStyle(Color(hex: 0x999999))
            }
        } else {
            HStack {
                TextField("edit text", text: $newText, axis: .vertical)
                    .primaryTextFieldStyle(when: newText.isEmpty, placeholder: "type item")
                    .onSubmit {
                        guard !isNewTextValid else { return }

                        data.text = newText.trimmingCharacters(in: .whitespacesAndNewlines)
                        isEditing = false
                    }
                Button("Cancel") {
                    newText = data.text
                    isEditing = false
                }
                Button("Update") {
                    // TODO: add a toast to show why it didn't work
                    guard !isNewTextValid else { return }
                    data.text = newText.trimmingCharacters(in: .whitespacesAndNewlines)
                    isEditing = false
                }.disabled(isNewTextValid)
            }
        }
    }
}

// #Preview {
//    ItemView()
// }
