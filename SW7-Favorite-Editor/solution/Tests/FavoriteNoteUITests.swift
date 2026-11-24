import XCTest

final class FavoriteNoteUITests: XCTestCase {
    func testCoreInteraction() {
        let app = XCUIApplication()
        app.launch()
        XCTAssertTrue(app.staticTexts["Favorites: 0"].exists)
        app.buttons["Favorite stop"].tap()
        XCTAssertTrue(app.buttons["Unfavorite stop"].exists)
        XCTAssertTrue(app.staticTexts["Favorites: 1"].exists)
        app.textFields["Draft note"].tap()
        app.textFields["Draft note"].typeText("Water break\n")
        app.buttons["Save note"].tap()
        XCTAssertTrue(app.staticTexts["Water break"].exists)
        app.buttons["Reset"].tap()
        XCTAssertTrue(app.staticTexts["No saved note"].exists)
        XCTAssertTrue(app.staticTexts["Favorites: 0"].exists)
    }
}
