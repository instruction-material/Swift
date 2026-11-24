import Testing
@testable import TrackerModel

@Test func savesANamedTask() {
    var tracker = Tracker()
    let added = tracker.add("Plan app")
    #expect(added)
    #expect(tracker.tasks.map(\.title) == ["Plan app"])
}

@Test(arguments: ["  Plan app  ", "\tPlan app\n"])
func normalizesOnlyTheEdges(_ draft: String) {
    var tracker = Tracker()
    let added = tracker.add(draft)
    #expect(added)
    #expect(tracker.tasks.map(\.title) == ["Plan app"])
}

@Test(arguments: ["", "   ", "\n\t"])
func rejectsBlankInputWithoutChangingSavedTasks(_ draft: String) {
    var tracker = Tracker()
    let saved = tracker.add("Keep this")
    #expect(saved)
    let originalID = tracker.tasks.first?.id
    let added = tracker.add(draft)
    #expect(!added)
    #expect(tracker.tasks.map(\.title) == ["Keep this"])
    #expect(tracker.tasks.first?.id == originalID)
}
