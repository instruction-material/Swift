import Testing
@testable import TrackerModel

@Test func savesANamedTask() {
    var tracker = Tracker()
    let added = tracker.add("Plan app")
    #expect(added)
    #expect(tracker.tasks.map(\.title) == ["Plan app"])
}
