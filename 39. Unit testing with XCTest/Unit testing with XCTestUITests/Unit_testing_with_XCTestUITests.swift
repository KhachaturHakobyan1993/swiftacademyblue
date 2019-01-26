//
//  Unit_testing_with_XCTestUITests.swift
//  Unit testing with XCTestUITests
//
//  Created by Khachatur Hakobyan on 1/26/19.
//  Copyright © 2019 Khachatur Hakobyan. All rights reserved.
//

import XCTest

class Unit_testing_with_XCTestUITests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testInitialStateIsCorrect() {
        let table = XCUIApplication().tables
        XCTAssertEqual(table.cells.count, 7, "There should be 7 rows initially")
    }
    
    func testUserFilteringString() {
        let app = XCUIApplication()
        app.buttons["Search"].tap()
        
        let filterAlert = app.alerts
        let textField = filterAlert.textFields.element
        textField.typeText("test")
        
                filterAlert.buttons["Filter"].tap()
        
        XCTAssertEqual(app.tables.cells.count, 56, "There should be 56 words matching 'test'")
    }
}
