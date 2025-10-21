//
//  NewProjectViewTest.swift
//  Sewing PlannerUITests
//
//  Created by Art on 8/2/24.
//

import XCTest

final class NewProjectViewTest: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        app = XCUIApplication()
        app.launch()

        let addNewProjectButton = app.buttons["AddNewProjectButton"]
        XCTAssertTrue(addNewProjectButton.exists)
        addNewProjectButton.click()
        let wait = app.waitForExistence(timeout: TimeInterval(2))
        print(wait)

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testBackButtonForEmptyProject() throws {
        let newStepButton = app.buttons["NewStepButton"]
        XCTAssertTrue(newStepButton.exists)

        let projectNameTextfield = app.textFields["ProjectNameTextfield"]
        XCTAssertTrue(projectNameTextfield.exists)

        // TODO: figure out why I need to search for the button twice, first in find toolbar buttons then the button I want in the toolbar
        let backButton = app.toolbars.buttons["ProjectViewCustomBackButton"].buttons["ProjectViewCustomBackButton"]
        XCTAssertTrue(backButton.exists)
        backButton.click()

        let wait = app.waitForExistence(timeout: TimeInterval(1))

        let addNewProjectButton = app.buttons["AddNewProjectButton"]
        XCTAssertTrue(addNewProjectButton.exists)
    }

    func testBackButtonForProjectWithName() throws {
        let projectNameTextfield = app.textFields["ProjectNameTextfield"]
        XCTAssertTrue(projectNameTextfield.exists)
        projectNameTextfield.click()
        projectNameTextfield.typeText("Project 1")
        // figure out how to type a key without using a modifier
        projectNameTextfield.typeKey(.enter, modifierFlags: .capsLock)

        // TODO: figure out why I need to search for the back button twice, first in find toolbar buttons then the button I want in the toolbar
        let backButton = app.toolbars.buttons["ProjectViewCustomBackButton"].buttons["ProjectViewCustomBackButton"]
        XCTAssertTrue(backButton.exists)
        backButton.click()

        var wait = app.waitForExistence(timeout: TimeInterval(1))

        let alertTextField = app.textFields["ProjectNameTextFieldInAlertUnsavedProject"]
        XCTAssertFalse(alertTextField.exists)

        let saveButton = app.buttons["SaveButtonInAlertUnsavedProject"]
        XCTAssertTrue(saveButton.exists)
        saveButton.click()

        wait = app.waitForExistence(timeout: TimeInterval(1))

        let addNewProjectButton = app.buttons["AddNewProjectButton"]
        XCTAssertTrue(addNewProjectButton.exists)
    }

    func testBackButtonForProjectWithoutNameWithProjectSteps() throws {
        let newStepButton = app.buttons["NewStepButton"]
        XCTAssertTrue(newStepButton.exists)
        newStepButton.click()

        let newStepTextField = app.textFields["NewStepTextField"]
        XCTAssertTrue(newStepTextField.exists)

        newStepTextField.click()
        newStepTextField.typeText("step 1")

        let addStepButton = app.buttons["AddNewStepButton"]
        addStepButton.click()

        // TODO: figure out why I need to search for the back button twice, first in find toolbar buttons then the button I want in the toolbar
        let backButton = app.toolbars.buttons["ProjectViewCustomBackButton"].buttons["ProjectViewCustomBackButton"]
        XCTAssertTrue(backButton.exists)
        backButton.click()

        var wait = app.waitForExistence(timeout: TimeInterval(1))

        let alertTextField = app.sheets["alert"].textFields["Enter a project name"]
        XCTAssertTrue(alertTextField.exists)
        alertTextField.click()
        alertTextField.typeText("project 1")

        let saveButton = app.buttons["SaveButtonInAlertUnsavedProject"]
        XCTAssertTrue(saveButton.exists)
        saveButton.click()

        wait = app.waitForExistence(timeout: TimeInterval(1))

        let addNewProjectButton = app.buttons["AddNewProjectButton"]
        XCTAssertTrue(addNewProjectButton.exists)
    }

    func testSaveButtonForProjectWithoutNameWithProjectSteps() throws {
        let newStepButton = app.buttons["NewStepButton"]
        XCTAssertTrue(newStepButton.exists)
        newStepButton.click()

        let newStepTextField = app.textFields["NewStepTextField"]
        XCTAssertTrue(newStepTextField.exists)

        newStepTextField.click()
        newStepTextField.typeText("step 1")

        let addStepButton = app.buttons["AddNewStepButton"]
        addStepButton.click()

        let saveButton = app.buttons["SaveButton"]
        XCTAssertTrue(saveButton.exists)
        saveButton.click()

//        var wait = app.waitForExistence(timeout: TimeInterval(1))

        let alertTextField = app.sheets["alert"].textFields["Enter a project name"]
        XCTAssertTrue(alertTextField.exists)
        alertTextField.click()
        alertTextField.typeText("project 1")

        let alertSaveButton = app.buttons["SaveButtonInAlertUnsavedProject"]
        XCTAssertTrue(alertSaveButton.exists)
        alertSaveButton.click()

//        wait = app.waitForExistence(timeout: TimeInterval(1))

        let addNewProjectButton = app.buttons["AddNewProjectButton"]
        XCTAssertTrue(addNewProjectButton.exists)
    }

    func testSaveButtonForEmptyProject() throws {
        let saveButton = app.buttons["SaveButton"]
        XCTAssertTrue(saveButton.exists)
        saveButton.click()

//        var wait = app.waitForExistence(timeout: TimeInterval(1))

        let alertTextField = app.sheets["alert"].textFields["Enter a project name"]
        XCTAssertTrue(alertTextField.exists)
        alertTextField.click()
        alertTextField.typeText("project 1")

        let alertSaveButton = app.buttons["SaveButtonInAlertUnsavedProject"]
        XCTAssertTrue(alertSaveButton.exists)
        alertSaveButton.click()

//        wait = app.waitForExistence(timeout: TimeInterval(1))

        let addNewProjectButton = app.buttons["AddNewProjectButton"]
        XCTAssertTrue(addNewProjectButton.exists)
    }

    func testSaveButtonForProjectWithName() throws {
        let projectNameTextfield = app.textFields["ProjectNameTextfield"]
        XCTAssertTrue(projectNameTextfield.exists)
        projectNameTextfield.click()
        projectNameTextfield.typeText("Project 1")
        // figure out how to type enter key without using a modifier
        projectNameTextfield.typeKey(.enter, modifierFlags: .capsLock)

        let saveButton = app.buttons["SaveButton"]
        XCTAssertTrue(saveButton.exists)
        saveButton.click()

//        let _ = app.waitForExistence(timeout: TimeInterval(1))

        let addNewProjectButton = app.buttons["AddNewProjectButton"]
        XCTAssertTrue(addNewProjectButton.exists)
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
