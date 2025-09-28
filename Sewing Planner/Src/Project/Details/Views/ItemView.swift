//
//  ItemView.swift
//  Sewing Planner
//
//  Created by Art on 10/11/24.
//

import SwiftUI

struct ItemView: View {
    @Binding var data: SectionItemRecord
    @State var isEditing = false
    @State var newText = ""
    var updateText: (Int64, String) throws -> Void
    var updateCompletedState: (Int64) throws -> Void

    func resetToPreviousText() {
        newText = data.text
        isEditing = false
    }

    var body: some View {
        if isEditing {
            UpdateItemView(data: $data, isEditing: $isEditing, newText: $newText, updateText: updateText, resetToPreviousText: resetToPreviousText)
        } else {
            HStack(alignment: .firstTextBaseline) {
                Toggle(data.text, isOn: $data.isComplete).toggleStyle(CheckboxStyle(id: data.id, updateCompletedState: updateCompletedState))
                Spacer()
//                Image(systemName: "line.3.horizontal")
            }
            .contentShape(Rectangle())
            .onTapGesture {
                if !isEditing {
                    isEditing = true
                    newText = data.text
                }
            }
        }
    }
}

struct CheckboxStyle: ToggleStyle {
    var id: Int64?
    var updateCompletedState: (Int64) throws -> Void

    func makeBody(configuration: Configuration) -> some View {
        HStack(alignment: .firstTextBaseline) {
            Button {
                try! updateCompletedState(id!)
                configuration.isOn.toggle()
            } label: {
                Image(systemName: configuration.isOn ? "checkmark.square" : "square")
            }
            configuration.label
        }
    }
}

// #Preview {
//    @Previewable @State var val = SectionItemRecord(text: "a set of text")
//    ItemView(data: $val) { id in
//        print(id)
//    } updateItem: { id in
//        print(id)
//    }
//    .padding(30)
//    .border(Color.black, width: 1)
//    .frame(maxWidth: 400, maxHeight: 400)
//    .background(.white)
// }
