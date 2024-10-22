//
//  ItemView.swift
//  Sewing Planner
//
//  Created by Art on 10/11/24.
//

import SwiftUI

// TODO: think about how to make this better or accept strings for values instead
extension Color {
    init(hex: Int, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xff) / 255,
            green: Double((hex >> 08) & 0xff) / 255,
            blue: Double((hex >> 00) & 0xff) / 255,
            opacity: opacity
        )
    }
}

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
                Spacer()
                Image(systemName: "line.3.horizontal").foregroundStyle(Color(hex: 0x999999))
            }
        } else {
            HStack {
                TextField("edit text", text: $newText).onSubmit {
                    guard !isNewTextValid else { return }

                    data.text = newText.trimmingCharacters(in: .whitespacesAndNewlines)
                    isEditing = false
                }.textFieldStyle(.plain)
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
