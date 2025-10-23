//
//  SectionView.swift
//  Sewing Planner
//
//  Created by Art on 10/11/24.
//

import SwiftUI

struct SectionView: View {
    @Binding var model: Section
    @Environment(ProjectViewModel.self) var project

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // TODO: this if else can become a view called SectionName
            HStack {
                if model.isRenamingSection {
                    HStack {
                        TextField("", text: $model.name)
                            .onSubmit {
                                model.updateName()
                            }
                            .textFieldStyle(.plain)
                            .padding(.bottom, 5)
//                            .overlay(Rectangle()
//                                .fill(Color(hex: 0x131944, opacity: 0.9))
//                                .frame(maxWidth: .infinity, maxHeight: 5),
//                                alignment: .bottom)
                            .font(.custom("SourceSans3-Medium", size: 16))
                        Button("Cancel") {
                            model.name = model.section.name
                            model.isRenamingSection = false
                        }
                        Button("Set") {
                            model.updateName()
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: 30, alignment: .leading)
                } else {
                    Text(model.section.name)
                        .font(.custom("SourceSans3-Medium", size: 16))
                        .frame(maxWidth: .infinity, maxHeight: 30, alignment: .leading)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            model.isRenamingSection = true
                            model.name = model.section.name
                        }
//                        .overlay(Rectangle()
//                            .frame(maxWidth: .infinity, maxHeight: 3),
//                            alignment: .bottom)
                    if model.isEditingSection {
                        HStack {
                            Button("Cancel") {
                                withAnimation(.smooth(duration: 0.2)) {
                                    model.isEditingSection = false
                                }
                            }
                            Button {
                                do {
                                    try model.deleteSelection()
                                    withAnimation(.smooth(duration: 0.2)) {
                                        model.isEditingSection = false
                                    }
                                } catch {
                                    project.handleError(error: .deleteSectionItems)
                                }
                            } label: {
                                Image(systemName: "trash")
                                    .foregroundStyle(Color.red)
                                    .padding(.horizontal, 8)
                            }
                            .disabled(!model.hasSelections)
                        }
                    }
                }
                // TODO: Next add the popup for this, with a delete button
                SectionViewButton {} label: {
                    Image(systemName: "ellipsis")
                }
            }
            .overlay(Divider()
                .frame(maxWidth: .infinity, maxHeight: 1)
                .background(Color(red: 230, green: 230, blue: 230)), alignment: .bottom)
            VStack(spacing: 0) {
                ForEach($model.items, id: \.self.record.id) { $item in
                    if !model.isEditingSection {
                        ItemView(data: $item, updateText: model.updateText, updateCompletedState: model.updateCompletedState)
                            .contentShape(Rectangle())
                            .onLongPressGesture {
                                withAnimation(.smooth(duration: 0.2)) {
                                    model.isEditingSection = true
                                }
                            }
                            .padding(.top, 4)
                    } else {
                        SelectedSectionItemView(data: $item, selected: $model.selectedItems, updateText: model.updateText, updateCompletedState: model.updateCompletedState)
                            .contentShape(Rectangle())
                            .onDrag {
                                model.draggedItem = item
                                return NSItemProvider(object: "\(item.hashValue)" as NSString)
                            }
                            .onDrop(of: [.text], delegate: DropSectionItemViewDelegate(item: item, data: $model.items, draggedItem: $model.draggedItem, saveNewOrder: model.saveOrder))
                            .padding(.top, 4)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            AddItemView(isAddingItem: $model.isAddingItem, addItem: model.addItem)
                .padding(.top, 8)
        }
        .animation(.easeOut(duration: 0.15), value: model.isAddingItem)
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
        .background(isSelected ? Color.blue.opacity(0.5) : Color.white)
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

    func dropEntered(info _: DropInfo) {
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

    func dropUpdated(info _: DropInfo) -> DropProposal? {
        DropProposal(operation: .move)
    }

    func performDrop(info _: DropInfo) -> Bool {
        try! saveNewOrder()
        draggedItem = nil
        return true
    }
}
