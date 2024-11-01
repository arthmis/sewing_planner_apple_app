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
    @State var isHovering = false
    var deleteItem: (Int64) throws -> Void

    private var isNewTextValid: Bool {
        newText.trimmingCharacters(in: .whitespaces).isEmpty
    }

    var body: some View {
        if !isEditing {
            HStack(alignment: .firstTextBaseline) {
                Toggle(data.text, isOn: $data.isComplete).toggleStyle(.checkbox)
                    .padding(.trailing, 40)
                Spacer()
                Button {
                    if let id = data.id {
                        do {
                            try deleteItem(id)
                        } catch {
                            fatalError("\(error)")
                        }
                    }
                } label: {
                    Image(systemName: "trash")
                        .foregroundStyle(Color(hex: 0x999999, opacity: isHovering ? 1 : 0))
                        .allowsHitTesting(isHovering)
                        .padding(.trailing, 10)
                }
                .buttonStyle(PlainButtonStyle())
                Image(systemName: "line.3.horizontal")
                    .foregroundStyle(Color(hex: 0x999999, opacity: isHovering ? 1 : 0))
                    .allowsHitTesting(isHovering)
            }
            .padding([.top, .bottom], 7)
            .onHover { hover in
                isHovering = hover
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

#Preview {
    @Previewable @State var val = SectionItemRecord(text: "a set of text")
    ItemView(data: $val) { index in
        print(index)
    }
    .padding(30)
    .border(Color.black, width: 1)
    .frame(maxWidth: 400, maxHeight: 400)
    .background(.white)
}
