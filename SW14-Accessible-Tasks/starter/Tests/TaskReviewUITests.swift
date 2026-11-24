import XCTest

final class TaskReviewUITests: XCTestCase {
    func testCoreInteraction() {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.buttons["Change status"].exists)
        app.buttons["Delete"].tap()
        XCTAssertTrue(app.staticTexts["No tasks"].exists)
        app.buttons["Restore sample"].tap()
        XCTAssertFalse(app.staticTexts["No tasks"].exists)
    }
}
