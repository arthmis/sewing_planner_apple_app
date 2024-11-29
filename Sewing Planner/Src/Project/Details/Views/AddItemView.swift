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
    let addItem: (_ text: String) throws -> ()
    @FocusState var addItemFocus: Bool

    private var isNewItemTextValid: Bool {
        !newItem.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        if isAddingItem {
            VStack(alignment: .leading) {
                TextField("", text: $newItem, axis: .vertical).onSubmit {
                    guard isNewItemTextValid else {
                        // add some kind of validation error
                        return
                    }

                    do {
                        print(newItem)
                        try addItem(newItem)
                    } catch {
                        fatalError("\(error)")
                        // add some kind of toast if failure
                    }
                    isAddingItem = false
                    newItem = ""
                }
                .textFieldStyle(.plain)
                .primaryTextFieldStyle(when: newItem.isEmpty, placeholder: "type item")
                .frame(minWidth: 300, maxWidth: .infinity)
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
                HStack(alignment: .center) {
                    Button("Add") {
                        guard isNewItemTextValid else { return }

                        do {
                            try addItem(newItem)
                        } catch {
                            fatalError("\(error)")
                        }
                        isAddingItem = false
                        newItem = ""
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    Button("Cancel") {
                        isAddingItem = false
                        newItem = ""
                    }
                    .buttonStyle(SecondaryButtonStyle())
                    .padding([.leading], 10)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
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

//#Preview {
//    AddItemView()
//}
