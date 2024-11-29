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

    func resetToPreviousText() {
        newText = data.text
        isEditing = false
    }

    var body: some View {
        VStack {
            HStack(alignment: .firstTextBaseline) {
                Toggle(data.text, isOn: $data.isComplete).toggleStyle(.checkbox)
                    .padding(.trailing, 40)
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
                        .foregroundStyle(Color(hex: 0x999999, opacity: isHovering ? 1 : 0))
                        .allowsHitTesting(isHovering)
                        .padding(.trailing, 10)
                }
                .buttonStyle(PlainButtonStyle())
                Image(systemName: "line.3.horizontal")
                    .foregroundStyle(Color(hex: 0x999999, opacity: isHovering ? 1 : 0))
                    .allowsHitTesting(isHovering)
            }
            .padding([.top, .bottom], 7)
            .background(Color(hex: 0xEEEEEE, opacity: isHovering ? 1 : 0))
            .onTapGesture {
                isEditing = true
            }
            .onHover { hover in
                isHovering = hover
            }
            UpdateItemView(data: $data, isEditing: $isEditing, newText: $newText, updateText: updateText, resetToPreviousText: resetToPreviousText)
                    }
                    .disabled(isNewTextValid)
                }
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
