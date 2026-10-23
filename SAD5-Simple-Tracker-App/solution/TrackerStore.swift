import Foundation
import Observation

@MainActor
@Observable
final class TrackerStore {
    private(set) var items: [TrackerItem]

    init(items: [TrackerItem] = TrackerItem.samples) {
        self.items = items
    }

    @discardableResult
    func add(title: String) -> Bool {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return false }
        items.append(TrackerItem(title: trimmed))
        return true
    }

    @discardableResult
    func update(id: UUID, title: String) -> Bool {
        let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty,
              let index = items.firstIndex(where: { $0.id == id }) else { return false }
        items[index].title = trimmed
        return true
    }

    @discardableResult
    func toggle(id: UUID) -> Bool {
        guard let index = items.firstIndex(where: { $0.id == id }) else { return false }
        items[index].completed.toggle()
        return true
    }

    func delete(at offsets: IndexSet) {
        for index in offsets.sorted(by: >) where items.indices.contains(index) {
            items.remove(at: index)
        }
    }
}
