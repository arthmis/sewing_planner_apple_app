//
//  Sewing_PlannerUITests.swift
//  Sewing PlannerUITests
//
//  Created by Art on 5/9/24.
//

import XCTest

final class Sewing_PlannerUITests: XCTestCase {
    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // let app = XCUIApplication()
        // app.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // app = nil
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testUpdateProjectName() throws {
        let app = XCUIApplication()
        app.launch()

        let addNewProjectButton = app.buttons["AddNewProjectButton"]
        XCTAssertTrue(addNewProjectButton.exists)
        addNewProjectButton.click()
        let wait = app.waitForExistence(timeout: TimeInterval(2))

        let newStepButton = app.buttons["NewStepButton"]
        XCTAssertTrue(newStepButton.exists)
        newStepButton.click()

        let newStepTextField = app.textFields["NewStepTextField"]
        XCTAssertTrue(newStepTextField.exists)

        newStepTextField.click()
        newStepTextField.typeText("step 1")

        let addStepButton = app.buttons["AddNewStepButton"]
        addStepButton.click()

        let stepOne = app.tables.checkBoxes["AllSteps"].firstMatch
        XCTAssertTrue(stepOne.exists)
        XCTAssertEqual(stepOne.label, "step 1")
    }

    func testAddNewStep() throws {
        let app = XCUIApplication()
        app.launch()

        let addNewProjectButton = app.buttons["AddNewProjectButton"]
        XCTAssertTrue(addNewProjectButton.exists)
        addNewProjectButton.click()
        let wait = app.waitForExistence(timeout: TimeInterval(2))

        let newStepButton = app.buttons["NewStepButton"]
        XCTAssertTrue(newStepButton.exists)
        newStepButton.click()

        let newStepTextField = app.textFields["NewStepTextField"]
        XCTAssertTrue(newStepTextField.exists)

        newStepTextField.click()
        newStepTextField.typeText("step 1")

        let addStepButton = app.buttons["AddNewStepButton"]
        addStepButton.click()

        let stepOne = app.tables.checkBoxes["AllSteps"].firstMatch
        XCTAssertTrue(stepOne.exists)
        XCTAssertEqual(stepOne.label, "step 1")
    }

    //  func testLaunchPerformance() throws {
    //    if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
    //      // This measures how long it takes to launch your application.
    //      measure(metrics: [XCTApplicationLaunchMetric()]) {
    //        XCUIApplication().launch()
    //      }
    //    }
    //  }
}
