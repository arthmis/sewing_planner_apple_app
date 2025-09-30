//
//  AddItemView.swift
//  Sewing Planner
//
//  Created by Art on 11/29/24.
//

import SwiftUI

struct AddItemView: View {
    @Binding var isAddingItem: Bool
    @State var newItem = ""
    let addItem: (_ text: String, _ note: String?) throws -> Void
    @State var showErrorText = false
    @State var itemNote = ""
    let errorText = "Item text can't be empty."
//    @FocusState var addItemFocus: Bool

    private var isNewItemTextValid: Bool {
        !newItem.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func add() {
        guard isNewItemTextValid else {
            showErrorText = true
            return
        }

        let validText = newItem.trimmingCharacters(in: .whitespacesAndNewlines)
        let validNoteText = itemNote.trimmingCharacters(in: .whitespacesAndNewlines)
        let noteText = validNoteText.isEmpty ? nil : validNoteText
        
        do {
            try addItem(newItem, noteText)
        } catch {
            // add some kind of toast if failure
            fatalError("\(error)")
        }
        showErrorText = false
        isAddingItem = false
        newItem = ""
        itemNote = ""
    }

    var body: some View {
        if isAddingItem {
            VStack(alignment: .leading) {
                VStack {
                    HStack {

                    TextField("Task", text: $newItem, axis: .vertical).onSubmit {
                        add()
                    }
                    .textFieldStyle(.plain)
                    .padding(.vertical, 4)
                    .frame(maxWidth: .infinity)
                        Button {
                            showErrorText = false
                            isAddingItem = false
                            newItem = ""
                            itemNote = ""
                        } label: {
                            Image(systemName: "xmark.circle")
                                .foregroundStyle(Color.red)
                                .font(.system(size: 24, weight: Font.Weight.thin))
                        }
                        .padding([.trailing], 8)
                    }
                    .contentShape(Rectangle())
                    TextField("Note", text: $itemNote, axis: .vertical)
                        .onSubmit {}
                        .padding(.vertical, 4)
                }
                .padding(4)
//                .onTapGesture {
//                    addItemFocus = true
//                }
//                .focused($addItemFocus)
//                .onChange(of: addItemFocus) { _, newFocus in
//                    if !newFocus {
//                        guard isNewItemTextValid else {
//                            isAddingItem = false
//                            newItem = ""
//                            return
//                        }
//
//                        do {
//                            try addItem(newItem)
//                        } catch {
//                            fatalError("\(error)")
//                        }
//                        isAddingItem = false
//                        newItem = ""
//                    }
//                }
                if showErrorText {
                    Text(errorText)
                        .padding(.leading, 8)
                        .foregroundStyle(Color.red)
                }
                HStack(alignment: .lastTextBaseline) {
                    Button {
                        add()
                    } label: {
                        Image(systemName: "arrow.up.circle.fill")
                            .font(.system(size: 32))
                    }
                    .disabled(!isNewItemTextValid)
                    .padding([.trailing, .bottom], 8)
                }
                .frame(maxWidth: .infinity, alignment: .bottomTrailing)
            }
            .background(Color(hex: 0xF2F2F2, opacity: 0.9))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        } else {
            Button {
                isAddingItem = true
//                addItemFocus = true
            }
            label: {
                HStack {
                    Image(systemName: "plus")
                    Text("New Item")
                }
            }
            .buttonStyle(SecondaryButtonStyle())
            .accessibilityIdentifier("NewStepButton")
        }
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed
        configuration.label
            .padding([.top, .bottom], 12)
            .padding([.leading, .trailing], 16)
            .background(Color(hex: 0xEFEFEF, opacity: 0.5))
            .foregroundColor(.black)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .scaleEffect(isPressed ? 0.95 : 1)
            .brightness(isPressed ? -0.05 : 0)
//            .shadow(color: Color(hex: 0xCFCFCF), radius: isPressed ? 1.5 : 3, x: 1, y: 3)
            .animation(.easeIn(duration: 0.1), value: isPressed)
    }
}

#Preview {
    @Previewable @State var isAddingItem = true
    @Previewable @State var newItem = ""

    AddItemView(isAddingItem: $isAddingItem, addItem: { val, note throws in print(val) })
        .frame(height: 300)
        .padding(8)
}
