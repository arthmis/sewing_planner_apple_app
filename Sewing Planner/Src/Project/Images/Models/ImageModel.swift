//
//  ImageModel.swift
//  Sewing Planner
//
//  Created by Art on 10/30/24.
//

import GRDB
import SwiftUI

struct ProjectImageRecord: Identifiable, Codable, EncodableRecord, FetchableRecord, MutablePersistableRecord, TableRecord {
    var id: Int64?
    var projectId: Int64
    var filePath: URL
    var isDeleted: Bool
    var createDate: Date
    var updateDate: Date
    static let databaseTableName = "projectImage"
}
