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
        let dbName = "TestDb"
        let db = AppDatabase.makeDb(name: dbName)

        let now = Date()
        var project = Project(id: nil, name: "Project", completed: false, createDate: now, updateDate: now)
        var material = MaterialRecord(material: "test 1", link: nil)
        var steps = ProjectStep(text: "step 1", isComplete: false, isEditing: false)
        let projectId = try db.saveProject(project: &project, projectSteps: [], materialData: [material])
        
        let writer = db.getWriter()
        try writer.read { db in
            let projectOne = try Project.fetchOne(
                db,
                sql: "SELECT * FROM project WHERE id = ?",
                arguments: [projectId])!
            
            XCTAssertEqual(project.id, Optional(1))
            XCTAssertEqual(project.name, projectOne.name)
            XCTAssertEqual(project.completed, projectOne.completed)
            // have to compare dates with a specific granularity because the data accuracy isn't guaranteed
            // it's possible to get the current with Date() and save it in the database, however the value from Date() might end up
            // different when you retrieve it from the database due to accuracy lost
            // more info here: https://github.com/groue/GRDB.swift/issues/492
            XCTAssertTrue(Calendar.current.isDate(project.createDate, equalTo: projectOne.createDate, toGranularity: Calendar.Component.second))
            XCTAssertTrue(Calendar.current.isDate(project.updateDate, equalTo: projectOne.updateDate, toGranularity: Calendar.Component.second))
            
            let materialOne = try MaterialRecord.fetchOne(
                db,
                sql: "SELECT * FROM projectMaterial WHERE id = ?",
                arguments: [1])!
            
            XCTAssertEqual(materialOne.id, Optional(1))
            XCTAssertEqual(materialOne.text, material.text)
            XCTAssertEqual(materialOne.completed, material.completed)
            XCTAssertTrue(Calendar.current.isDate(materialOne.createDate, equalTo: material.createDate, toGranularity: Calendar.Component.second))
            XCTAssertTrue(Calendar.current.isDate(materialOne.updateDate, equalTo: material.updateDate, toGranularity: Calendar.Component.second))
        }
        
        AppDatabase.deleteDb(name: dbName)
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
