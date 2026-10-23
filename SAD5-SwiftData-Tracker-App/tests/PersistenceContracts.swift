import Foundation
import SwiftData

@main
struct PersistenceContracts {
    @MainActor
    static func main() throws {
        if CommandLine.arguments.count > 1 {
            try diskPhase(Array(CommandLine.arguments.dropFirst()))
            return
        }
        var checks: [String] = []
        func check(_ name: String, _ condition: @autoclosure () throws -> Bool) throws {
            guard try condition() else { fatalError("Failed: " + name) }
            checks.append(name)
        }
        let container = try TrackerPersistence.makeContainer(inMemory: true)
        let context = container.mainContext
        let repository = TrackerRepository(context: context)
        try check("manual save boundary", !context.autosaveEnabled)
        try check("fresh test store empty", try rows(context).isEmpty)
        let first = try repository.add(title: "  First \n")
        let second = try repository.add(title: "Second")
        try check("insert trims and preserves order", try rows(context).map(\.title) == ["First", "Second"])
        try check("new records have distinct IDs", first != second)
        let original = try rows(context)[0]
        let creationTime = original.createdAt
        try repository.toggle(id: first)
        try check("toggle persisted model", try rows(context)[0].completed)
        try repository.update(id: first, title: "  Edited first  ")
        let edited = try rows(context)[0]
        try check("edit trims title", edited.title == "Edited first")
        try check("edit preserves identity and completion", edited.id == first && edited.completed)
        try check("edit preserves creation order", edited.createdAt == creationTime && (try rows(context)[1].id) == second)
        var draft = edited.title
        draft = "Cancelled draft"
        try check("draft does not mutate persisted model", edited.title == "Edited first" && draft != edited.title)
        do { _ = try repository.add(title: " \t\n"); fatalError("Blank add accepted") }
        catch TrackerChangeError.blankTitle { checks.append("blank add rejected") }
        do { try repository.update(id: first, title: " \n"); fatalError("Blank edit accepted") }
        catch TrackerChangeError.blankTitle { checks.append("blank edit rejected") }
        try check("invalid input preserves stored state", try rows(context).map(\.title) == ["Edited first", "Second"])
        do { try repository.update(id: UUID(), title: "Missing"); fatalError("Missing ID accepted") }
        catch TrackerChangeError.missingItem { checks.append("missing edit rejected") }
        do { try repository.toggle(id: UUID()); fatalError("Missing ID toggled") }
        catch TrackerChangeError.missingItem { checks.append("missing toggle rejected") }

        enum Injected: Error { case saveFailed }
        let failing = TrackerRepository(context: context, save: { _ in throw Injected.saveFailed })
        do { _ = try failing.add(title: "Not saved"); fatalError("Failed insert accepted") }
        catch Injected.saveFailed { checks.append("insert save error propagates") }
        try check("failed insertion rolls back", try rows(context).count == 2 && !context.hasChanges)
        do { try failing.update(id: first, title: "Not saved"); fatalError("Failed edit accepted") }
        catch Injected.saveFailed { checks.append("edit save error propagates") }
        try check("failed edit rolls back", try rows(context)[0].title == "Edited first" && !context.hasChanges)
        do { try failing.toggle(id: first); fatalError("Failed toggle accepted") }
        catch Injected.saveFailed { checks.append("toggle save error propagates") }
        try check("failed toggle rolls back", try rows(context)[0].completed && !context.hasChanges)
        do { try failing.delete(ids: [first, second]); fatalError("Failed deletion accepted") }
        catch Injected.saveFailed { checks.append("deletion save error propagates") }
        try check("failed deletion restores records", try rows(context).map(\.id) == [first, second] && !context.hasChanges)
        try repository.delete(ids: [UUID()])
        try check("stale deletion is harmless", try rows(context).count == 2)
        try repository.delete(ids: [first, second])
        try check("selected IDs deleted together", try rows(context).isEmpty)

        let previewA = try TrackerPersistence.makeContainer(inMemory: true)
        let previewB = try TrackerPersistence.makeContainer(inMemory: true)
        _ = try TrackerRepository(context: previewA.mainContext).add(title: "Preview only")
        try check("previews are isolated", try rows(previewB.mainContext).isEmpty)
        let freshPreview = try TrackerPersistence.makeContainer(inMemory: true)
        try check("preview data is ephemeral", try rows(freshPreview.mainContext).isEmpty)
        try check("CloudKit disabled", container.configurations.allSatisfy { $0.cloudKitContainerIdentifier == nil })

        let blocked = FileManager.default.temporaryDirectory.appendingPathComponent(UUID().uuidString)
        try Data("A file cannot be a store directory".utf8).write(to: blocked)
        defer { try? FileManager.default.removeItem(at: blocked) }
        do {
            _ = try TrackerPersistence.makeContainer(url: blocked.appendingPathComponent("tracker.store"))
            fatalError("An unavailable store silently opened")
        } catch { checks.append("unavailable store reports failure without memory fallback") }
        try output(["accepted": true, "passed": checks.count, "checks": checks])
    }

    @MainActor
    static func rows(_ context: ModelContext) throws -> [TrackerRecord] {
        try context.fetch(FetchDescriptor<TrackerRecord>(sortBy: [SortDescriptor(\.createdAt)]))
    }

    @MainActor
    static func diskPhase(_ args: [String]) throws {
        guard args.count >= 2 else { fatalError("phase and store URL required") }
        let phase = args[0]
        let container = try TrackerPersistence.makeContainer(url: URL(fileURLWithPath: args[1]), allowsSave: phase != "read-only")
        let context = container.mainContext
        let repository = TrackerRepository(context: context)
        let expected = args.count > 2 ? UUID(uuidString: args[2]) : nil
        var result: [String: Any] = ["accepted": true, "phase": phase]
        switch phase {
        case "write":
            guard try rows(context).isEmpty else { fatalError("Use a fresh test store") }
            let id = try repository.add(title: "  Saved record  ")
            try repository.toggle(id: id)
            result["id"] = id.uuidString
        case "read", "read-edited":
            let items = try rows(context)
            guard items.count == 1, items[0].id == expected, items[0].completed,
                  items[0].title == (phase == "read" ? "Saved record" : "Edited record")
            else { fatalError("Stored record did not survive process relaunch") }
        case "edit":
            guard let expected else { fatalError("Expected ID required") }
            try repository.update(id: expected, title: "  Edited record  ")
        case "read-only":
            guard let expected else { fatalError("Expected ID required") }
            var rejected = false
            do { try repository.update(id: expected, title: "Must not save") }
            catch { rejected = true }
            guard rejected else { fatalError("Read-only configuration accepted a write") }
            guard try rows(context)[0].title == "Edited record"
            else { fatalError("Read-only rejection changed the stored title") }
            guard !context.hasChanges else { fatalError("Read-only rejection left uncommitted changes") }
            result["saveRejected"] = true
        case "delete":
            guard let expected else { fatalError("Expected ID required") }
            try repository.delete(ids: [expected])
        case "read-empty":
            guard try rows(context).isEmpty else { fatalError("Deleted record returned after relaunch") }
        default: fatalError("Unknown phase")
        }
        try output(result)
    }

    static func output(_ result: [String: Any]) throws {
        let data = try JSONSerialization.data(withJSONObject: result, options: [.sortedKeys])
        print(String(decoding: data, as: UTF8.self))
    }
}
