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
    @FocusState var headerFocus: Bool
    @State private var draggedItem: SectionItem?
    @State var isEditingSection = false

    func deleteItem(at offsets: IndexSet) {
        for index in offsets {
            let step = data.items.remove(at: index)
            data.deletedItems.append(step.record)
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
        VStack(alignment: .leading, spacing: 4) {
            // TODO: this if else can become a view called SectionName
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
                    if isEditingSection {
                        HStack {
                            Button("Cancel") {
                                withAnimation(.smooth(duration: 0.2)) {
                                    isEditingSection = false
                                }
                            }
                            Button {
                                try! data.deleteSelection()
                                withAnimation(.smooth(duration: 0.2)) {
                                    isEditingSection = false
                                }
                            } label: {
                                Image(systemName: "trash")
                                    .foregroundStyle(Color.red)
                                    .padding(.horizontal, 8)
                            }
                            .disabled(!data.hasSelections)
                        }
                    }
                }
//                SectionViewButton {} label: {
//                    Image(systemName: "ellipsis")
//                }
            }
            .overlay(Divider()
                .frame(maxWidth: .infinity, maxHeight: 1)
                .background(Color(red: 230, green: 230, blue: 230)), alignment: .bottom)
            VStack(spacing: 0) {
                ForEach($data.items, id: \.self.record.id) { $item in
                    if !isEditingSection {
                        ItemView(data: $item, updateText: data.updateText, updateCompletedState: data.updateCompletedState)
                            .contentShape(Rectangle())
                            .onLongPressGesture {
                                withAnimation(.smooth(duration: 0.2)) {
                                    isEditingSection = true
                                }
                            }
                            .padding(.top, 4)
//                            .animation(.easeOut(duration: 0.1), value: isEditingSection)
                    } else {
                        SelectedSectionItemView(data: $item, selected: $data.selectedItems, updateText: data.updateText, updateCompletedState: data.updateCompletedState)
                            .contentShape(Rectangle())
                            .onDrag {
                                draggedItem = item
                                return NSItemProvider(object: "\(item.hashValue)" as NSString)
                            }
                            .onDrop(of: [.text], delegate: DropSectionItemViewDelegate(item: item, data: $data.items, draggedItem: $draggedItem, saveNewOrder: data.saveOrder))
                            .padding(.top, 4)
//                            .animation(.easeOut(duration: 0.1), value: isEditingSection)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            AddItemView(isAddingItem: $isAddingItem, addItem: data.addItem)
                .padding(.top, 8)
        }
        .animation(.easeOut(duration: 0.15), value: isAddingItem)
    }
}

struct SelectedSectionItemView: View {
    @Binding var data: SectionItem
    @State var isEditing = false
    @State var newText = ""
    @Binding var selected: Set<Int64>
    var updateText: (Int64, String, String?) throws -> Void
    var updateCompletedState: (Int64) throws -> Void

    var isSelected: Bool {
        selected.contains(data.record.id)
    }

    private var hasNote: Bool {
        data.note != nil
    }

    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Toggle(data.record.text, isOn: $data.record.isComplete)
                .toggleStyle(CheckboxStyle(id: data.record.id, hasNote: hasNote, updateCompletedState: updateCompletedState, isSelected: isSelected))
                .foregroundStyle(isSelected ? Color.white : Color.black)
            Spacer()
            Image(systemName: "line.3.horizontal")
                .padding(.trailing, 4)
                .foregroundStyle(isSelected ? Color.white : Color.black)
        }
        .contentShape(Rectangle())
        .padding(6)
        .background(isSelected ? Color.blue.opacity(0.5): Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .onTapGesture {
            if !isSelected {
                selected.insert(data.record.id)
            } else {
                selected.remove(data.record.id)
            }
        }
        .animation(.easeOut(duration: 0.1), value: isSelected)
    }
}

struct DropSectionItemViewDelegate: DropDelegate {
    var item: SectionItem
    @Binding var data: [SectionItem]
    @Binding var draggedItem: SectionItem?
    var saveNewOrder: () throws -> Void

    func dropEntered(info: DropInfo) {
        guard item != draggedItem,
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
        try! saveNewOrder()
        draggedItem = nil
        return true
    }
}
