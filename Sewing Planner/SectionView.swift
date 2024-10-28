//
//  SectionView.swift
//  Sewing Planner
//
//  Created by Art on 10/11/24.
//

import SwiftUI

struct SectionView: View {
    @ObservedObject var data: Section
    @State var isRenamingSection = false
    @State var name = ""
    @State var isAddingItem = false
    @State var newItem = ""

    func deleteItem(at offsets: IndexSet) {
        for index in offsets {
            let step = data.items.remove(at: index)
            data.deletedItems.append(step)
        }
    }

    private var isNewNameValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    private var isNewItemTextValid: Bool {
        !newItem.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(alignment: .leading) {
            // TODO: this if else can become a view called SectionName
            HStack {
                if isRenamingSection {
                    HStack {
                        TextField("", text: $name).onSubmit {
                            // TODO: add a popup telling user that instruction can't be empty
                            guard isNewNameValid else { return }

                            isRenamingSection = false
                            data.updateSectionName(with: name)
                        }
                        .textFieldStyle(.plain)
                        .font(.custom("SourceSans3-Medium", size: 16))
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
                        }
                    }
                } else {
                    Text(data.section.name).onTapGesture {
                        isRenamingSection = true
                        name = data.section.name
                    }
                    .font(.custom("SourceSans3-Medium", size: 16))
                }
                Spacer()
                SectionViewButton {} label: {
                    Image(systemName: "ellipsis")
                }
            }
            .overlay(Divider()
                .frame(maxWidth: .infinity, maxHeight: 1)
                .background(Color(red: 230, green: 230, blue: 230)), alignment: .bottom)
            ForEach($data.items, id: \.self) { $item in
                ItemView(data: $item)
                    .frame(maxWidth: .infinity)
                    .padding([.top, .bottom], 5)
            }
            .onDelete(perform: deleteItem)
            if isAddingItem {
                VStack(alignment: .leading) {
                    TextField("", text: $newItem, axis: .vertical).onSubmit {
                        guard isNewItemTextValid else { return }

                        data.addItem(text: newItem)
                        isAddingItem = false
                        newItem = ""
                    }
                    .textFieldStyle(.plain)
                    .primaryTextFieldStyle(when: newItem.isEmpty, placeholder: "type item")
                    .frame(minWidth: 300, maxWidth: .infinity)
                    .padding(.trailing, 50)
                    HStack(alignment: .center) {
                        Button("Add") {
                            guard isNewItemTextValid else { return }

                            data.addItem(text: newItem)
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
                }
                .buttonStyle(SecondaryButtonStyle())
                .accessibilityIdentifier("NewStepButton")
            }
        }
    }
}

