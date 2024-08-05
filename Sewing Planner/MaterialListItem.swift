//
//  MaterialView.swift
//  Sewing Planner
//
//  Created by Art on 8/5/24.
//

import SwiftUI

struct MaterialListItem: View {
    @State var isComplete = false
    @State var isEditing = false
    @Binding var text: String
    @State var newText = ""
    
    var body: some View {
        HStack {
            Toggle(text, isOn: $isComplete).toggleStyle(.checkbox)
            Button("\(Image(systemName: "pencil"))") {
                isEditing = true
            }
            Menu("\(Image(systemName: "ellipsis"))") {
                Button("Delete") {
                }
            }
        }
        if isEditing {
            EditStep(originalText: $text, newText: text, isEditing: $isEditing)
        }
    }
}

//#Preview {
//    MaterialListItem()
//}
