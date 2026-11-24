import XCTest

final class GalleryCardUITests: XCTestCase {
    @MainActor
    func testStarterCardExposesItsTitleAndDescriptionOnce() throws {
        let app = XCUIApplication()
        app.launch()
        let title = "Sunset Poster"
        let summary = "A warm poster-style sunset composition."
        let card = app.buttons.matching(NSPredicate(format: "label CONTAINS %@", title)).firstMatch
        XCTAssertTrue(card.waitForExistence(timeout: 15))
        let label = card.label
        XCTAssertEqual(label.components(separatedBy: title).count, 2, label)
        XCTAssertTrue(label.contains("Photo"), label)
        XCTAssertFalse(label.contains(summary), label)
        XCTAssertEqual(card.value as? String, summary)
        XCTAssertFalse(card.images.firstMatch.exists)
        XCTAssertTrue(app.staticTexts[title].firstMatch.exists)
        let evidence = XCTAttachment(string: "Card label: \(label)\nCard value: \(card.value ?? "")")
        evidence.name = "Gallery starter card accessibility"
        evidence.lifetime = .keepAlways
        add(evidence)
    }
}
