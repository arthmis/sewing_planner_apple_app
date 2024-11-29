//
//  SectionView.swift
//  Sewing Planner
//
//  Created by Art on 10/11/24.
//

import SwiftUI

enum FocusField {
    case header
    case addItem
}

struct SectionView: View {
    @ObservedObject var data: Section
    @State var isRenamingSection = false
    @State var name = ""
    @State var isAddingItem = false
    @State var newItem = ""
    @FocusState var headerFocus: Bool
    @State var isHovering = false

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
                        TextField("", text: $name)
                            .onSubmit {
                                // TODO: add a popup telling user that instruction can't be empty
                                guard isNewNameValid else { return }

                                isRenamingSection = false
                                data.updateSectionName(with: name)
                            }
                            .focused($headerFocus)
                            .onChange(of: headerFocus) { _, newFocus in
                                if !newFocus {
                                    guard isNewNameValid else {
                                        isRenamingSection = false
                                        return
                                    }

                                    data.section.name = name
                                    isRenamingSection = false
                                }
                            }
                            .textFieldStyle(.plain)
                            .padding(.bottom, 5)
                            .overlay(Rectangle()
                                .fill(Color(hex: 0x131944, opacity: 0.9))
                                .frame(maxWidth: .infinity, maxHeight: 5),
                                alignment: .bottom)
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
                    .frame(maxWidth: .infinity, maxHeight: 30, alignment: .leading)
                } else {
                    Text(data.section.name)
                        .font(.custom("SourceSans3-Medium", size: 16))
                        .frame(maxWidth: .infinity, maxHeight: 30, alignment: .leading)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            isRenamingSection = true
                            name = data.section.name
                            headerFocus = true
                        }
                        .onHover { hover in
                            isHovering = hover
                        }
                        .overlay(Rectangle()
                            .fill(Color(hex: 0x131944, opacity: isHovering ? 1 : 0))
                            .frame(maxWidth: .infinity, maxHeight: 3),
                            alignment: .bottom)
                }
                SectionViewButton {} label: {
                    Image(systemName: "ellipsis")
                }
            }
            .overlay(Divider()
                .frame(maxWidth: .infinity, maxHeight: 1)
                .background(Color(red: 230, green: 230, blue: 230)), alignment: .bottom)
            ForEach($data.items, id: \.self) { $item in
                ItemView(data: $item, deleteItem: data.deleteItem, updateItem: data.updateItem)
                    .frame(maxWidth: .infinity)
            }
            AddItemView(isAddingItem: $isAddingItem, newItem: $newItem, addItem: data.addItem)

        }
    }
}
