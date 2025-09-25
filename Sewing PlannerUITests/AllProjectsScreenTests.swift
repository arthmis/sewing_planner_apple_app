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
        
        app.toolbars.children(matching: .button)["ProjectViewCustomBackButton"].children(matching: .button)["ProjectViewCustomBackButton"].tap()
        
        let projectNames = app.scrollViews.otherElements.staticTexts["ProjectName"]
//        print(projectNames.debugDescription)
        print(projectNames.label)
        //        print(projectNames.count)
        XCTAssertTrue(projectNames.value.debugDescription == "Project Name")
        
//        let swiftuiModifiedcontentSewingPlannerContentviewSwiftuiEnvironmentkeywritingmodifierSewingPlannerAppdatabase1Appwindow1Window = XCUIApplication()/*@START_MENU_TOKEN@*/.windows["SwiftUI.ModifiedContent<Sewing_Planner.ContentView, SwiftUI._EnvironmentKeyWritingModifier<Sewing_Planner.AppDatabase>>-1-AppWindow-1"]/*[[".windows[\"Projects\"]",".windows[\"SwiftUI.ModifiedContent<Sewing_Planner.ContentView, SwiftUI._EnvironmentKeyWritingModifier<Sewing_Planner.AppDatabase>>-1-AppWindow-1\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/
//        swiftuiModifiedcontentSewingPlannerContentviewSwiftuiEnvironmentkeywritingmodifierSewingPlannerAppdatabase1Appwindow1Window/*@START_MENU_TOKEN@*/.buttons["AddNewProjectButton"]/*[[".groups",".buttons[\"New Project\"]",".buttons[\"AddNewProjectButton\"]"],[[[-1,2],[-1,1],[-1,0,1]],[[-1,2],[-1,1]]],[0]]@END_MENU_TOKEN@*/.click()
//        swiftuiModifiedcontentSewingPlannerContentviewSwiftuiEnvironmentkeywritingmodifierSewingPlannerAppdatabase1Appwindow1Window.toolbars/*@START_MENU_TOKEN@*/.children(matching: .button)["ProjectViewCustomBackButton"].children(matching: .button)["ProjectViewCustomBackButton"]/*[[".children(matching: .button)[\"Back\"]",".children(matching: .button)[\"ProjectViewCustomBackButton\"]"],[[[-1,1,1],[-1,0,1]],[[-1,1],[-1,0]]],[0,0]]@END_MENU_TOKEN@*/.click()
//        swiftuiModifiedcontentSewingPlannerContentviewSwiftuiEnvironmentkeywritingmodifierSewingPlannerAppdatabase1Appwindow1Window/*@START_MENU_TOKEN@*/.scrollViews.otherElements.staticTexts["ProjectName"]/*[[".groups.scrollViews.otherElements",".staticTexts[\"Project Name\"]",".staticTexts[\"ProjectName\"]",".scrollViews.otherElements"],[[[-1,3,1],[-1,0,1]],[[-1,2],[-1,1]]],[0,0]]@END_MENU_TOKEN@*/.click()
        
        
//        let firstProjectName = app.textViews["ProjectName"].children(matching: .staticText)["Project Name"]
//        XCTAssertTrue(firstProjectName.exists)
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
