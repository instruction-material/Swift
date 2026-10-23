import Foundation

@main
struct TrackerContracts {
    @MainActor
    static func main() throws {
        var checks: [String] = []
        func check(_ name: String, _ condition: @autoclosure () -> Bool) {
            guard condition() else { fatalError("Failed: " + name) }
            checks.append(name)
        }

        let first = TrackerItem(title: "First")
        let second = TrackerItem(title: "Second", completed: true)
        let third = TrackerItem(title: "Third")
        let store = TrackerStore(items: [first, second, third])
        check("initial order and completion", store.items == [first, second, third])
        check("blank add rejected", !store.add(title: " \n\t "))
        check("blank add preserves list", store.items == [first, second, third])
        check("trimmed add accepted", store.add(title: " \n Fourth \t"))
        let fourth = store.items[3]
        check("new item title and state", fourth.title == "Fourth" && !fourth.completed)
        check("new item unique ID", ![first.id, second.id, third.id].contains(fourth.id))
        check("duplicate title allowed", store.add(title: "First"))
        check("duplicate title has separate identity", store.items.last!.id != first.id)

        var draft = second
        draft.title = "Unsaved draft"
        check("editing a value does not save", store.items[1] == second)
        draft.title = second.title
        check("discarding a draft preserves state", store.items[1] == second)
        check("edit accepted", store.update(id: second.id, title: "  Edited second \n"))
        check("edit trims title", store.items[1].title == "Edited second")
        check("edit preserves ID and completion", store.items[1].id == second.id && store.items[1].completed)
        check("edit preserves neighboring order", store.items[0] == first && store.items[2] == third && store.items[3] == fourth)
        let beforeBlank = store.items
        check("blank edit rejected", !store.update(id: second.id, title: " \t\n"))
        check("invalid edit preserves list", store.items == beforeBlank)
        check("missing item edit rejected", !store.update(id: UUID(), title: "Missing"))
        check("missing item toggle rejected", !store.toggle(id: UUID()))
        check("missing IDs preserve list", store.items == beforeBlank)
        check("toggle selected item", store.toggle(id: first.id) && store.items[0].completed)
        check("toggle twice restores state", store.toggle(id: first.id) && !store.items[0].completed)
        check("toggle preserves other item", store.items[1] == beforeBlank[1])

        store.delete(at: IndexSet([0, 2]))
        check("multiple deletion uses original offsets", store.items.map(\.id) == [second.id, fourth.id, beforeBlank[4].id])
        let afterDelete = store.items
        store.delete(at: IndexSet([999]))
        store.delete(at: IndexSet())
        check("empty and stale deletion preserve list", store.items == afterDelete)
        store.delete(at: IndexSet(integersIn: 0..<store.items.count))
        check("all items can be deleted", store.items.isEmpty)
        check("empty list accepts new item", store.add(title: "Restart"))

        let fresh = TrackerStore()
        let separate = TrackerStore()
        fresh.add(title: "Only in first store")
        check("preview and app stores are isolated", separate.items == TrackerItem.samples)
        check("new instance resets in-memory data", TrackerStore().items == TrackerItem.samples)
        let empty = TrackerStore(items: [])
        check("empty injected store stays empty", empty.items.isEmpty)

        let data = try JSONSerialization.data(withJSONObject: ["accepted": true, "passed": checks.count, "checks": checks], options: [.sortedKeys])
        print(String(decoding: data, as: UTF8.self))
    }
}
