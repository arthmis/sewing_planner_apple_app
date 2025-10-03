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
                    .transition(.growFromTop)
            } else {
                VStack(alignment: .leading) {
                    HStack(alignment: .firstTextBaseline) {
                        Toggle(data.record.text, isOn: $data.record.isComplete).toggleStyle(CheckboxStyle(id: data.record.id, hasNote: hasNote, updateCompletedState: updateCompletedState,))
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
        .animation(.linear(duration: 0.075), value: isEditing)
    }
}

struct CheckboxStyle: ToggleStyle {
    var id: Int64?
    var hasNote: Bool
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
                .frame(maxWidth: .infinity, alignment: .topLeading)
            if hasNote {
                Image(systemName: "note.text")
                    .font(.system(size: 14, weight: Font.Weight.light))
                    .foregroundStyle(Color.gray)
                    .padding(.horizontal, 4)
            }
        }
    }
}

// 1. Create a ViewModifier that handles the scaling effect.
// We use a near-zero value for the start to avoid division-by-zero issues.
struct VerticalScaleModifier: ViewModifier {
    var scaleY: CGFloat
    
    func body(content: Content) -> some View {
        content.scaleEffect(x: 1, y: scaleY, anchor: .top)
    }
}

// 2. Create a static extension on AnyTransition to make our new transition reusable.
extension AnyTransition {
    static var growFromTop: AnyTransition {
        .modifier(
            // `active` is the state during the transition (view is appearing)
            active: VerticalScaleModifier(scaleY: 0.00001),

            // `identity` is the final state (view is fully visible)
            identity: VerticalScaleModifier(scaleY: 1)
        )
        .combined(with: .opacity) // Adding opacity makes it look smoother
    }
}

#Preview {
    @Previewable @State var val = SectionItem(record: SectionItemRecord(text: "This is really long task to see how it gets displayed. Making this message way longer because it still isn't long enough", order: 1), note: SectionItemNoteRecord(text: "string", sectionItemId: 1))
    var updateText: (Int64, String, String?) throws -> Void
    var updateCompletedState: (Int64) throws -> Void

    ItemView(data: $val) { id, _, _ in
        print(id)
    } updateCompletedState: { id in
        print(id)
    }
    .padding(30)
    .border(Color.black, width: 1)
    .frame(maxWidth: 400, maxHeight: 400)
    .background(.white)
}
