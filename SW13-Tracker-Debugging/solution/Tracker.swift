import Foundation

struct TaskEntry: Identifiable {
    let id = UUID()
    let title: String
}

struct Tracker {
    private(set) var tasks: [TaskEntry] = []

    mutating func add(_ draft: String) -> Bool {
        let title = draft.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { return false }
        tasks.append(TaskEntry(title: title))
        return true
    }
}
