//
//  MaterialList.swift
//  Sewing Planner
//
//  Created by Art on 8/5/24.
//

import SwiftUI

struct MaterialList: View {
    @State var isAddingMaterial = false
    @State var newMaterial = ""
    @State var materials: [String] = []
    
    func deleteMaterial(at offsets: IndexSet) {
        self.materials.remove(atOffsets: offsets)
    }
    
    var body: some View {
        
        VStack {
            List {
                ForEach($materials, id: \.self) { $material in
                    MaterialListItem(text: $material)
                }
                .onDelete(perform: deleteMaterial)
                .onMove { indexSet, offset in
                    materials.move(fromOffsets: indexSet, toOffset: offset)
                }.accessibilityIdentifier("AllSteps")
                
            }
            if isAddingMaterial {
                HStack {
                    TextField("write material", text: $newMaterial).onSubmit {
                        // add a popup telling user that instruction can't be empty
                        guard !newMaterial.isEmpty else { return }
                        materials.append(newMaterial)
                        newMaterial = ""
                        isAddingMaterial = false
                    }.textFieldStyle(.plain)
                        .accessibilityIdentifier("NewMaterialTextField")
                    
                    Button("Cancel") {
                        isAddingMaterial = false
                        newMaterial = ""
                    }
                    Button("Add") {
                        // add a popup telling user that instruction can't be empty
                        // guard !newStep.trimmingCharacters(in: .whitespaces).isEmpty else { return }
                        //                        guard !isNewStepValid else { return }
                        
                        // think about what to do here for validation or something
                        
                        materials.append(newMaterial)
                        newMaterial = ""
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
