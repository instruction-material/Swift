import XCTest

final class GalleryCardUITests: XCTestCase {
    @MainActor
    func testStarterCardExposesItsTitleAndDescriptionOnce() {
        let app = XCUIApplication()
        app.launchArguments += ["-AppleLanguages", "(en)", "-AppleLocale", "en_US"]
        app.launch()

        let examples = [
            ("Sunset Poster", "Photo", "A warm poster-style sunset composition."),
            ("Studio Desk", "Workspace", "A clean desk setup for editing and sketching.")
        ]
        for (title, category, summary) in examples {
            let card = app.buttons.matching(
                NSPredicate(format: "label CONTAINS %@", title)
            ).firstMatch
            XCTAssertTrue(card.waitForExistence(timeout: 15))
            XCTAssertEqual(card.label, "\(title), \(category)")
            XCTAssertEqual(card.value as? String, summary)
            XCTAssertTrue(app.staticTexts[title].firstMatch.exists)
            print("Gallery card: \(card.label) | \(card.value ?? "")")
        }
    }
}
