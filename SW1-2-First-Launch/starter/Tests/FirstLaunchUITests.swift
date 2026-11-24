import XCTest

final class FirstLaunchUITests: XCTestCase {
    func testLaunchShowsTheExpectedHeading() {
        let app = XCUIApplication()
        app.launch()
        let heading = app.staticTexts["launch-title"]
        XCTAssertTrue(heading.waitForExistence(timeout: 10))
        XCTAssertEqual(heading.label, "Ready to launch")
    }
}
