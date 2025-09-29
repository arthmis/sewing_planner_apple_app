//
//  File.swift
//  Sewing Planner
//
//  Created by Art on 9/29/25.
//

import Foundation
import GRDB

struct SectionItem: Decodable, FetchableRecord, Hashable {
    var record: SectionItemRecord
    var note: SectionItemNoteRecord?
}
