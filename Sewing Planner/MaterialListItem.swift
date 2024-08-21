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
    @Binding var materialData: MaterialRecord
    
    var body: some View {
        HStack {
            if let link = materialData.link {
                Link(destination: link) {
                    Image(systemName: "link")
                }
            }
            Toggle(materialData.material, isOn: $isComplete).toggleStyle(.checkbox)
            Button("\(Image(systemName: "pencil"))") {
                isEditing = true
            }
            Menu("\(Image(systemName: "ellipsis"))") {
                Button("Delete") {
                }
            }
        }
        if isEditing {
            EditMaterial(originalData: $materialData, isEditing: $isEditing)
        }
    }
}

struct EditMaterial: View {
    @Binding var originalData: MaterialRecord
    @State var newMaterial =  ""
    @State var newLink = ""
    @Binding var isEditing: Bool
    
    private var isNewTextValid: Bool {
        newMaterial.trimmingCharacters(in: .whitespaces).isEmpty
    }
    
    var body: some View {
        
        HStack {
            TextField("update material", text: $newMaterial).onSubmit {
                guard !isNewTextValid else { return }
                
                originalData.material = newMaterial
                originalData.link = newLink.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : URL(string: newLink)
                
                newMaterial = ""
                newLink = ""
                isEditing = false
            }.textFieldStyle(.plain)
            TextField("update link", text: $newLink).onSubmit {
                guard !isNewTextValid else { return }
                
                originalData.material = newMaterial
                originalData.link = newLink.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : URL(string: newLink)

                newMaterial = ""
                newLink = ""
                isEditing = false
            }.textFieldStyle(.plain)
            Button("Cancel") {
                newMaterial = ""
                newLink = ""
                isEditing = false
            }
            Button("Update") {
                guard !isNewTextValid else { return }
                
                originalData.material = newMaterial
                originalData.link = newLink.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty ? nil : URL(string: newLink)

                newMaterial = ""
                newLink = ""
                isEditing = false
            }.disabled(isNewTextValid)
        }
    }
}

//#Preview {
//    MaterialListItem()
//}
