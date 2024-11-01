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
    var updateItem: (Int64) throws -> Void

    private var isNewTextValid: Bool {
        newText.trimmingCharacters(in: .whitespaces).isEmpty && newText != data.text
    }

    var body: some View {
        VStack {
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
            .background(Color(hex: 0xEEEEEE, opacity: isHovering ? 1 : 0))
            .onTapGesture {
                isEditing = true
            }
            .onHover { hover in
                isHovering = hover
            }
            if isEditing {
                HStack {
                    TextField("edit text", text: $newText, axis: .vertical)
                        .textFieldStyle(.plain)
                        .primaryTextFieldStyle(when: newText.isEmpty, placeholder: "type item")
                        .onSubmit {
                            guard !isNewTextValid else { return }

                            data.text = newText.trimmingCharacters(in: .whitespacesAndNewlines)
                            do {
                                try updateItem(data.id!)
                            } catch {
                                fatalError("\(error)")
                            }
                            isEditing = false
                        }
                    Button("Cancel") {
                        newText = data.text
                        isEditing = false
                    }
                    Button("Update") {
                        // TODO: add a error message to show why it didn't work
                        guard !isNewTextValid else { return }
                        
                        data.text = newText.trimmingCharacters(in: .whitespacesAndNewlines)
                        do {
                            try updateItem(data.id!)
                        } catch {
                            fatalError("\(error)")
                        }
                        isEditing = false
                    }
                    .disabled(isNewTextValid)
                }
            }
        }
    }
}

#Preview {
    @Previewable @State var val = SectionItemRecord(text: "a set of text")
    ItemView(data: $val) { id in
        print(id)
    } updateItem: { id in
        print(id)
    }
    .padding(30)
    .border(Color.black, width: 1)
    .frame(maxWidth: 400, maxHeight: 400)
    .background(.white)
}
