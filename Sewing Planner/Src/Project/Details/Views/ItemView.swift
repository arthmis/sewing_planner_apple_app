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
    @State var isHovering = false
    var deleteItem: (Int64) throws -> Void
    var updateText: (Int64, String) throws -> Void
    @State var offset: CGSize = .zero
    @State private var isDragging = false

    func resetToPreviousText() {
        newText = data.text
        isEditing = false
    }

    var body: some View {
        VStack {
            HStack(alignment: .firstTextBaseline) {
                Toggle(data.text, isOn: $data.isComplete).toggleStyle(.button)
                Spacer()
                Button {
                    if let id = data.id {
                        do {
                            try deleteItem(id)
                        } catch {
                            fatalError("\(error)")
                        }
                    }
                } label: {
                    Image(systemName: "trash")
                        .padding(.trailing, 8)
                }
                .buttonStyle(PlainButtonStyle())
                Image(systemName: "line.3.horizontal")
            }
            .padding([.top, .bottom], 8)
            .onTapGesture {
                isEditing = true
                newText = data.text
            }
            .onHover { hover in
                isHovering = hover
            }
            if isEditing {
                UpdateItemView(data: $data, isEditing: $isEditing, newText: $newText, updateText: updateText, resetToPreviousText: resetToPreviousText)
            }
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
