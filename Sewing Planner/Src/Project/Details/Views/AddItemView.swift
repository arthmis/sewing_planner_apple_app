//
//  AddItemView.swift
//  Sewing Planner
//
//  Created by Art on 11/29/24.
//

import SwiftUI

struct AddItemView: View {
    @Binding var isAddingItem: Bool
    @Binding var newItem: String
    let addItem: (_ text: String) throws -> Void
    @State var showErrorText = false
    let errorText = "Item text can't be empty."
    @FocusState var addItemFocus: Bool

    private var isNewItemTextValid: Bool {
        !newItem.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    func add() {
        guard isNewItemTextValid else {
            showErrorText = true
            return
        }

        do {
            try addItem(newItem)
        } catch {
            // add some kind of toast if failure
            fatalError("\(error)")
        }
        showErrorText = false
        isAddingItem = false
        newItem = ""
    }

    var body: some View {
        if isAddingItem {
            VStack(alignment: .leading) {
                TextField("", text: $newItem, axis: .vertical).onSubmit {
                    add()
                }
                .textFieldStyle(.plain)
                .primaryTextFieldStyle(when: newItem.isEmpty, placeholder: "type item")
                .frame(maxWidth: .infinity)
                .padding(.trailing, 50)
                .contentShape(Rectangle())
                .onTapGesture {
                    addItemFocus = true
                }
                .focused($addItemFocus)
                .onChange(of: addItemFocus) { _, newFocus in
                    if !newFocus {
                        guard isNewItemTextValid else {
                            isAddingItem = false
                            newItem = ""
                            return
                        }

                        do {
                            try addItem(newItem)
                        } catch {
                            fatalError("\(error)")
                        }
                        isAddingItem = false
                        newItem = ""
                    }
                }
                if showErrorText {
                    Text(errorText)
                        .padding(.leading, 8)
                        .foregroundStyle(Color.red)
                }
                HStack(alignment: .center) {
                    Button("Add") {
                        add()
                    }
                    .disabled(!isNewItemTextValid)
                    .buttonStyle(PrimaryButtonStyle())
                    Button("Cancel") {
                        isAddingItem = false
                        newItem = ""
                        showErrorText = false
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    .padding([.leading], 8)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .leading)
            }
        } else {
            Button("Add Item") {
                isAddingItem = true
                addItemFocus = true
            }
            .buttonStyle(SecondaryButtonStyle())
            .accessibilityIdentifier("NewStepButton")
        }
    }
}

#Preview {
    @Previewable @State var isAddingItem = true
    @Previewable @State var newItem = ""

    AddItemView(isAddingItem: $isAddingItem, newItem: $newItem, addItem: { val throws in print(val) })
        .frame(height: 300)
}
