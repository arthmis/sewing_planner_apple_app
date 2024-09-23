//
//  MaterialList.swift
//  Sewing Planner
//
//  Created by Art on 8/5/24.
//

import SwiftUI
import GRDB

struct MaterialRecord: Codable, EncodableRecord, FetchableRecord, MutablePersistableRecord, TableRecord {
    var id: Int64?
    // using a default which will be updated before the material is stored
    var projectId: Int64?
    var text: String = ""
    var link: URL?
    var completed: Bool
    var createDate: Date
    var updateDate: Date
    static let databaseTableName = "projectMaterial"
    
    mutating func didInsert(_ inserted: InsertionSuccess) {
        id = inserted.rowID
    }
//    mutating func didInsert(with rowID: Int64, for column: String?)
    
    init(material: String, link: URL?) {
        let currentTime = Date()
        self.link = link
        self.text = material
        completed = false
        createDate = currentTime
        updateDate = currentTime
    }
}

struct MaterialList: View {
    @State var isAddingMaterial = false
    @State var newMaterial = ""
    @State var newLink = ""
    @Binding var materials: [MaterialRecord]
    @Binding var deletedMaterials: [MaterialRecord]

    func deleteMaterial(at offsets: IndexSet) {
        offsets.forEach { index in
            let material = materials.remove(at: index)
            deletedMaterials.append(material)
            print(deletedMaterials)
        }
    }
    
    var body: some View {
        
        VStack {
            List {
                ForEach($materials, id: \.self.text) { $materialData in
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
                            MaterialRecord(material: newMaterial, link: nil)
                        } else {
                            MaterialRecord(material: newMaterial, link: URL(string: newLink))
                        }
                        materials.append(newData)
                        newMaterial = ""
                        newLink = ""
                        isAddingMaterial = false
                    }.textFieldStyle(.plain)
                        .accessibilityIdentifier("NewMaterialTextField")
                    TextField("optional link", text: $newLink).onSubmit {
                        let newData = if newLink.isEmpty {
                            MaterialRecord(material: newMaterial, link: nil)
                        } else {
                            MaterialRecord(material: newMaterial, link: URL(string: newLink))
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
                            MaterialRecord(material: newMaterial, link: nil)
                        } else {
                            MaterialRecord(material: newMaterial, link: URL(string: newLink))
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
