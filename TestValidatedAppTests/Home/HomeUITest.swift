//
//  DownloadUITest.swift
//  TestValidatedApp
//
//  Created by Luong Manh on 7/7/25.
//

import XCTest

final class HomeUITest: XCTestCase {
    func testPasteButton() throws {
        let app = XCUIApplication()
        app.launch()

        let pasteButton = app.buttons["Paste_button"]
        pasteButton.tap()
        sleep(1)
        
        let title = app.staticTexts["Pasted"]
        XCTAssertTrue(title.waitForExistence(timeout: 2))
    }
}
