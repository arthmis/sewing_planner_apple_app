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
    
    private var isNewTextValid: Bool {
        newText.trimmingCharacters(in: .whitespaces).isEmpty
    }
    var body: some View {
        HStack {
            Toggle(data.text, isOn: $data.isComplete).toggleStyle(.checkbox)
            Button("\(Image(systemName: "pencil"))") {
                isEditing = true
            }
            Menu("\(Image(systemName: "ellipsis"))") {
                Button("Delete") {
                }
            }
        }
        if isEditing {
            HStack {
                TextField("edit text", text: $newText).onSubmit {
                    guard !isNewTextValid else { return }
                    
                    data.text = newText.trimmingCharacters(in: .whitespacesAndNewlines)
                    isEditing = false
                }.textFieldStyle(.plain)
                Button("Cancel") {
                    newText = data.text
                    isEditing = false
                }
                Button("Update") {
                    // TODO: add a toast to show why it didn't work
                    guard !isNewTextValid else { return }
                    data.text = newText.trimmingCharacters(in: .whitespacesAndNewlines)
                    isEditing = false
                }.disabled(isNewTextValid)
            }
        }
    }
}

//#Preview {
//    ItemView()
//}
