//
//  SectionViewModel.swift
//  Sewing Planner
//
//  Created by Art on 10/30/24.
//

import SwiftUI

class Section: ObservableObject {
    @Published var section: SectionRecord = .init()
    @Published var items: [SectionItemRecord] = []
    var id: UUID
    var deletedItems: [SectionItemRecord] = []

    init(id: UUID, name: String) {
        section = SectionRecord(name: name)
        self.id = id
    }

    init(section: SectionRecord, items: [SectionItemRecord], id: UUID) {
        self.section = section
        self.items = items
        self.id = id
    }

    func addItem(text: String) {
        items.append(SectionItemRecord(text: text))
    }

    func deleteItem(index: Int) {
        let deletedItem = items.remove(at: index)
        deletedItems.append(deletedItem)
    }

    func updateSectionName(with name: String) {
        section.name = name
    }
}
