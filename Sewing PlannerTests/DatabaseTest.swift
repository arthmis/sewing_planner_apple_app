//
//  DatabaseTest.swift
//  Sewing PlannerTests
//
//  Created by Art on 9/9/24.
//

import XCTest
import GRDB
@testable import Sewing_Planner

final class DatabaseTest: XCTestCase {
    
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testSaveProject() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // Any test you write for XCTest can be annotated as throws and async.
        // Mark your test throws to produce an unexpected failure when your test encounters an uncaught error.
        // Mark your test async to allow awaiting for asynchronous code to complete. Check the results with assertions afterwards.
        let db = AppDatabase.empty()
        let now = Date()
        var project = Project(id: nil, name: "Project", completed: false, createDate: now, updateDate: now)
        try db.saveProject(project: &project, projectSteps: [], materialData: [])
        let writer = db.getWriter()
//        try writer.write { db in
//            try! project.save(db)
//        }
        try writer.read { db in
            let latestId = db.lastInsertedRowID
            let projectOne = try Project.fetchOne(
                db,
                sql: "SELECT * FROM project WHERE id = ?",
                arguments: [latestId])!
            
            XCTAssertEqual(project.id, Optional(1))
            XCTAssertEqual(project.name, projectOne.name)
            XCTAssertEqual(project.completed, projectOne.completed)
            XCTAssertEqual(project.createDate, projectOne.createDate)
            XCTAssertEqual(project.updateDate, projectOne.updateDate)
    }
        
        
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
