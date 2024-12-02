//
//  AllProjectsScreenTests.swift
//  Sewing PlannerUITests
//
//  Created by Art on 7/18/24.
//

import XCTest

final class AllProjectsScreenTests: XCTestCase {
    private var app: XCUIApplication!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        app = XCUIApplication()
        app.launchArguments = ["--test"]
        app.launch()

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testAddNewProject() throws {
        let addNewProjectButton = app.buttons["AddNewProjectButton"]
        XCTAssertTrue(addNewProjectButton.exists)
        addNewProjectButton.tap()

        guard app.staticTexts.matching(identifier: "Project Name").firstMatch.waitForExistence(timeout: 5.0) else {
            return XCTFail()
        }

        let addSectionButton = app.buttons["AddNewSectionButton"]
        XCTAssertTrue(addSectionButton.exists)
        
        let addImageButton = app.buttons["AddNewImageButton"]
        XCTAssertTrue(addImageButton.exists)
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            // This measures how long it takes to launch your application.
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                XCUIApplication().launch()
            }
        }
    }
}
