//
//  TimestampedRecord.swift
//  Sewing Planner
//
//  Created by Art on 9/10/24.
//

import Foundation
import GRDB

/// A type that tracks its creation and modification dates, as described in
/// <https://swiftpackageindex.com/groue/grdb.swift/documentation/grdb/recordtimestamps>
protocol TimestampedRecord {
    var creationDate: Date? { get set }
    var modificationDate: Date? { get set }
}

extension TimestampedRecord where Self: MutablePersistableRecord {
    /// Sets `modificationDate` to the transaction date.
    mutating func touch(_ db: Database) throws {
        modificationDate = try db.transactionDate
    }

    /// Sets both `creationDate` and `modificationDate` to the transaction date,
    /// if they are not set yet.
    ///
    /// Records that customize the `willInsert` callback can call this method
    /// from their implementation.
    mutating func initializeTimestamps(_ db: Database) throws {
        if creationDate == nil {
            creationDate = try db.transactionDate
        }
        if modificationDate == nil {
            modificationDate = try db.transactionDate
        }
    }

    // Default implementation of `willInsert`.
    mutating func willInsert(_ db: Database) throws {
        try initializeTimestamps(db)
    }

    /// Sets `modificationDate` to the transaction date, and executes an
    /// `UPDATE` statement on all columns.
    mutating func updateWithTimestamp(_ db: Database) throws {
        try touch(db)
        try update(db)
    }
}
