import Foundation

struct TrackerItem: Identifiable, Equatable, Sendable {
    let id: UUID
    var title: String
    var completed: Bool

    init(id: UUID = UUID(), title: String, completed: Bool = false) {
        self.id = id
        self.title = title
        self.completed = completed
    }

    static let samples = [
        TrackerItem(title: "Sketch for 10 minutes"),
        TrackerItem(title: "Review SwiftUI notes", completed: true)
    ]
}
