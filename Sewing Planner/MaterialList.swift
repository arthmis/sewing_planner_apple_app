//
//  MaterialList.swift
//  Sewing Planner
//
//  Created by Art on 8/5/24.
//

import SwiftUI

struct MaterialData {
    var material: String = ""
    var link: URL?
}

struct MaterialList: View {
    @State var isAddingMaterial = false
    @State var newMaterial = ""
    @State var newLink = ""
    @Binding var materials: [MaterialData]
    
    func deleteMaterial(at offsets: IndexSet) {
        self.materials.remove(atOffsets: offsets)
    }
    
    var body: some View {
        
        VStack {
            List {
                ForEach($materials, id: \.self.material) { $materialData in
                    MaterialListItem(materialData: $materialData)
                }
                .onDelete(perform: deleteMaterial)
                .onMove { indexSet, offset in
                    materials.move(fromOffsets: indexSet, toOffset: offset)
                }.accessibilityIdentifier("AllSteps")
                
            }
            if isAddingMaterial {
                HStack {
                    TextField("write material", text: $newMaterial).onSubmit {
                        // add a popup telling user that material can't be empty
                        guard !newMaterial.isEmpty else { return }
                        let newData = if newLink.isEmpty {
                            MaterialData(material: newMaterial, link: nil)
                        } else {
                            MaterialData(material: newMaterial, link: URL(string: newLink))
                        }
                        materials.append(newData)
                        newMaterial = ""
                        newLink = ""
                        isAddingMaterial = false
                    }.textFieldStyle(.plain)
                        .accessibilityIdentifier("NewMaterialTextField")
                    TextField("optional link", text: $newLink).onSubmit {
                        let newData = if newLink.isEmpty {
                            MaterialData(material: newMaterial, link: nil)
                        } else {
                            MaterialData(material: newMaterial, link: URL(string: newLink))
                        }
                        materials.append(newData)
                        newMaterial = ""
                        newLink = ""
                        isAddingMaterial = false
                    }.textFieldStyle(.plain)
                        .accessibilityIdentifier("NewMaterialLinkField")

                    Button("Cancel") {
                        isAddingMaterial = false
                        newMaterial = ""
                        newLink = ""
                    }
                    Button("Add") {
                        guard !newMaterial.isEmpty else { return }
                        let newData = if newLink.isEmpty {
                            MaterialData(material: newMaterial, link: nil)
                        } else {
                            MaterialData(material: newMaterial, link: URL(string: newLink))
                        }
                        materials.append(newData)
                        newMaterial = ""
                        newLink = ""
                        isAddingMaterial = false

                    }.accessibilityIdentifier("AddNewMaterialButton")
                }
            }
            Button("New Material") {
                isAddingMaterial = true
            }.accessibilityIdentifier("NewMaterialButton")
        }
    }
}
//
//#Preview {
//    MaterialList()
//}
