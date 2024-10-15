//
//  SectionView.swift
//  Sewing Planner
//
//  Created by Art on 10/11/24.
//

import SwiftUI

struct SectionView: View {
    @ObservedObject var data: Section
    @State var isRenamingSection = true
    @State var name = ""
    @State var isAddingItem = false
    @State var newItem = ""
    
    func deleteItem(at offsets: IndexSet) {
        offsets.forEach { index in
            let step = data.items.remove(at: index)
            data.deletedItems.append(step)
        }
    }
    
    private var isNewNameValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    var body: some View {
        VStack {
            // TODO: this if else can become a view called SectionName
            if isRenamingSection {
                HStack {
                    TextField("section name", text: $name).onSubmit {
                        // TODO: add a popup telling user that instruction can't be empty
                        guard isNewNameValid else { return }
                        
                        
                        isRenamingSection = false
                        data.updateSectionName(with: name)
                        print("submit hit")
                        print(isRenamingSection)
                        print(data.section.name)
                        print(name)
                    }
                    Button("Cancel") {
                        name = data.section.name
                        
                        isRenamingSection = false
                    }
                    Button("Set") {
                        // add a popup telling user that instruction can't be empty
                        guard isNewNameValid else { return }
                        
                        // think about what to do here for validation or something
                        data.section.name = name
                        
                        isRenamingSection = false
                        print("button set clicked", isRenamingSection)
                    }
                }
            } else {
                Text(data.section.name)
            }
            List {
                ForEach($data.items, id: \.self) { $item in
                    ItemView(data: $item)
                }
                .onDelete(perform: deleteItem)
                .accessibilityIdentifier("AllSteps")
                
            }
            if isAddingItem {
                TextField("new item", text: $newItem).onSubmit {
                    data.addItem(text: newItem)
                    isAddingItem = false
                    newItem = ""
                }
            }
            Button("Add Item") {
                isAddingItem = true
            }
            .accessibilityIdentifier("NewStepButton")
        }
    }
}
