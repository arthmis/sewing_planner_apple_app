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
    @Binding var data: Section
    @State var isRenamingSection = false
    @State var name = ""
    @State var isAddingItem = false
    @State var newItem = ""
    @FocusState var headerFocus: Bool
    @State private var draggedItem: SectionItemRecord?
    @State var isEditingSection = false

    func deleteItem(at offsets: IndexSet) {
        for index in offsets {
            let step = data.items.remove(at: index)
            data.deletedItems.append(step)
        }
    }

    private var isNewNameValid: Bool {
        !name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    func updateName() {
        // TODO: add a popup telling user that instruction can't be empty
        guard isNewNameValid else { return }

        isRenamingSection = false
        do {
            try data.updateSectionName(with: name)
        } catch {
            fatalError("\(error)")
        }
    }

    var body: some View {
        VStack(alignment: .leading) {
            // TODO: this if else can become a view called SectionName
            if isEditingSection {
                HStack {
                    Text("editing")
                    Button("cancel") {
                        isEditingSection = false
                    }
                }
            }
            HStack {
                if isRenamingSection {
                    HStack {
                        TextField("", text: $name)
                            .onSubmit {
                                updateName()
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
//                            .overlay(Rectangle()
//                                .fill(Color(hex: 0x131944, opacity: 0.9))
//                                .frame(maxWidth: .infinity, maxHeight: 5),
//                                alignment: .bottom)
                            .font(.custom("SourceSans3-Medium", size: 16))
                        Button("Cancel") {
                            name = data.section.name
                            isRenamingSection = false
                        }
                        Button("Set") {
                            updateName()
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
//                        .overlay(Rectangle()
//                            .frame(maxWidth: .infinity, maxHeight: 3),
//                            alignment: .bottom)
                }
//                SectionViewButton {} label: {
//                    Image(systemName: "ellipsis")
//                }
            }
            .overlay(Divider()
                .frame(maxWidth: .infinity, maxHeight: 1)
                .background(Color(red: 230, green: 230, blue: 230)), alignment: .bottom)
            ForEach($data.items, id: \.self.id) { $item in
                if !isEditingSection {
                    ItemView(data: $item, deleteItem: data.deleteItem, updateText: data.updateText, updateCompletedState: data.updateCompletedState)
                        .contentShape(Rectangle())
                        .onLongPressGesture {
                            isEditingSection = true
                        }
                } else {
                    SelectedSectionItemView(data: $item, selected: $data.selectedItems, deleteItem: data.deleteItem, updateText: data.updateText, updateCompletedState: data.updateCompletedState)
                        .contentShape(Rectangle())
                        .onDrag {
                            draggedItem = item
                            return NSItemProvider(object: "\(item.hashValue)" as NSString)
                        }
                        .onDrop(of: [.text], delegate: DropSectionItemViewDelegate(item: item, data: $data.items, draggedItem: $draggedItem))
                }
            }
            .frame(maxWidth: .infinity)
            AddItemView(isAddingItem: $isAddingItem, newItem: $newItem, addItem: data.addItem)

        }
    }
}

struct SelectedSectionItemView: View {
    @Binding var data: SectionItemRecord
    @State var isEditing = false
    @State var newText = ""
    @Binding var selected: Set<Int64>
    var deleteItem: (Int64) throws -> Void
    var updateText: (Int64, String) throws -> Void
    var updateCompletedState: (Int64) throws -> Void

    var isSelected: Bool {
        selected.contains(data.id!)
    }
    
    var body: some View {
            HStack(alignment: .firstTextBaseline) {
                Toggle(data.text, isOn: $data.isComplete)
                    .toggleStyle(CheckboxStyle(id: data.id, updateCompletedState: updateCompletedState))
                Spacer()
//                Button {
//                    if let id = data.id {
//                        do {
//                            try deleteItem(id)
//                        } catch {
//                            fatalError("\(error)")
//                        }
//                    }
//                } label: {
//                    Image(systemName: "trash")
//                        .padding(.horizontal, 8)
//                }
//                .buttonStyle(PlainButtonStyle())
//                Image(systemName: "line.3.horizontal")
            }
            .contentShape(Rectangle())
            .background(isSelected ? Color.blue : Color.white)
            .onTapGesture {
                if !isSelected {
                    selected.insert(data.id!)
                } else {
                    selected.remove(data.id!)
                }
            }
    }
}

struct DropSectionItemViewDelegate: DropDelegate {
    let item: SectionItemRecord
    @Binding var data: [SectionItemRecord]
    @Binding var draggedItem: SectionItemRecord?
    func dropEntered(info: DropInfo) {
        guard item  != draggedItem,
              let current = draggedItem,
              let from = data.firstIndex(of: current),
              let to = data.firstIndex(of: item)
        else {
            return
        }
        if data[to] != current {
            withAnimation {
                data.move(fromOffsets: IndexSet(integer: from), toOffset: (to > from) ? to + 1 : to)
            }
        }
    }
    
    func dropUpdated(info: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }
    
    func performDrop(info: DropInfo) -> Bool {
        draggedItem = nil
        return true
    }
}
