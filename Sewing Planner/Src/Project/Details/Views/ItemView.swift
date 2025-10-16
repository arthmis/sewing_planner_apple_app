//
//  ItemView.swift
//  Sewing Planner
//
//  Created by Art on 10/11/24.
//

import SwiftUI

struct ItemView: View {
    @Binding var data: SectionItem
    @State var isEditing = false
    @State var newText = ""
    @State var newNoteText = ""
    var updateText: (Int64, String, String?) throws -> Void
    var updateCompletedState: (Int64) throws -> Void

    func resetToPreviousText() {
        newText = data.record.text
        isEditing = false
    }

    private var hasNote: Bool {
        data.note != nil
    }

    var body: some View {
        VStack {
            if isEditing {
                UpdateItemView(data: $data, isEditing: $isEditing, newText: $newText, newNoteText: $newNoteText, updateText: updateText, resetToPreviousText: resetToPreviousText)
                    .transition(.revealFrom(edge: .top).combined(with: .opacity))
            } else {
                VStack(alignment: .leading, spacing: 0) {
                    HStack(alignment: .firstTextBaseline) {
                        Toggle(data.record.text, isOn: $data.record.isComplete).toggleStyle(CheckboxStyle(id: data.record.id, hasNote: hasNote, updateCompletedState: updateCompletedState, isSelected: false))
                        Spacer()
                    }
                }
                .contentShape(Rectangle())
                .onTapGesture {
                    if !isEditing {
                        isEditing = true
                        newText = data.record.text
                        newNoteText = data.note != nil ? data.note!.text : ""
                    }
                }
            }
        }
        .animation(.easeOut(duration: 0.075), value: isEditing)
    }
}

struct CheckboxStyle: ToggleStyle {
    var id: Int64?
    var hasNote: Bool
    var updateCompletedState: (Int64) throws -> Void
    let isSelected: Bool

    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .firstTextBaseline, spacing: 8) {
            Button {
                try! updateCompletedState(id!)
                configuration.isOn.toggle()
            } label: {
                Image(systemName: configuration.isOn ? "checkmark.square" : "square")
            }
            VStack(spacing: 0) {
                configuration.label
                    .frame(maxWidth: .infinity, alignment: .topLeading)
                if hasNote {
                    Image(systemName: "note.text")
                        .font(.system(size: 14, weight: Font.Weight.light))
                        .foregroundStyle(isSelected ? Color.white : Color.gray)
                        .frame(maxWidth: .infinity, alignment: .topLeading)
                }
            }
        }
    }
}

// #Preview {
//    @Previewable @State var val = SectionItem(record: SectionItemRecord(text: "This is really long task to see how it gets displayed. Making this message way longer because it still isn't long enough", order: 1), note: SectionItemNoteRecord(text: "string", sectionItemId: 1))
//    var updateText: (Int64, String, String?) throws -> Void
//    var updateCompletedState: (Int64) throws -> Void
//
//    ItemView(data: $val) { id, _, _ in
//        print(id)
//    } updateCompletedState: { id in
//        print(id)
//    }
//    .padding(30)
//    .border(Color.black, width: 1)
//    .frame(maxWidth: 400, maxHeight: 400)
//    .background(.white)
// }
