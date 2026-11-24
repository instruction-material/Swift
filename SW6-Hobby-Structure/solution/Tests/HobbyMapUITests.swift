import XCTest

final class HobbyMapUITests: XCTestCase {
    func testCoreInteraction() {
        let app = XCUIApplication()
        app.launch()
        app.buttons["Hiking"].tap()
        XCTAssertTrue(app.staticTexts["Bring: Water bottle"].exists)
        app.navigationBars.buttons.firstMatch.tap()
        app.buttons["Sketching"].tap()
        XCTAssertTrue(app.staticTexts["Bring: Pencil"].exists)
    }
}
