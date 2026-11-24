import XCTest

final class TaskReviewUITests: XCTestCase {
    private func reveal(_ element: XCUIElement, in app: XCUIApplication) {
        for _ in 0..<4 where !element.isHittable { app.swipeUp() }
        XCTAssertTrue(element.isHittable)
    }

    func testCoreInteraction() {
        let app = XCUIApplication()
        app.launchArguments += ["-UIPreferredContentSizeCategoryName", "UICTContentSizeCategoryAccessibilityXXXL"]
        app.launch()
        reveal(app.buttons["Save task"], in: app)
        app.buttons["Save task"].tap()
        XCTAssertTrue(app.staticTexts["Saved"].exists)
        XCTAssertTrue(app.staticTexts["Status: open"].exists)
        reveal(app.buttons["Delete task"], in: app)
        app.buttons["Delete task"].tap()
        app.buttons["Cancel"].tap()
        XCTAssertFalse(app.staticTexts["No tasks"].exists)
        reveal(app.buttons["Delete task"], in: app)
        app.buttons["Delete task"].tap()
        app.buttons["Confirm deletion"].tap()
        XCTAssertTrue(app.staticTexts["No tasks"].exists)
        app.buttons["Restore sample"].tap()
        XCTAssertFalse(app.staticTexts["No tasks"].exists)
    }
}
