import Foundation
import SwiftData
import Testing
@testable import TrackerPersistenceCore

@Suite("SwiftData tracker", .serialized)
@MainActor
struct PersistenceTests {
    @Test("Edits preserve the record's identity and completion")
    func editBoundary() throws {
        let container = try TrackerPersistence.makeContainer(inMemory: true)
        let repository = TrackerRepository(context: container.mainContext)
        let id = try repository.add(title: "  First  ")
        try repository.toggle(id: id)
        try repository.update(id: id, title: "  Revised  ")
        let item = try container.mainContext.fetch(FetchDescriptor<TrackerRecord>()).first
        #expect(item?.id == id)
        #expect(item?.title == "Revised")
        #expect(item?.completed == true)
    }

    @Test("A rejected title does not create a record")
    func invalidInput() throws {
        let container = try TrackerPersistence.makeContainer(inMemory: true)
        let repository = TrackerRepository(context: container.mainContext)
        #expect(throws: TrackerChangeError.self) { _ = try repository.add(title: " \n\t") }
        #expect(try container.mainContext.fetchCount(FetchDescriptor<TrackerRecord>()) == 0)
    }

    @Test("A failed save restores the previously committed title")
    func failedSave() throws {
        enum Failure: Error { case save }
        let container = try TrackerPersistence.makeContainer(inMemory: true)
        let context = container.mainContext
        let id = try TrackerRepository(context: context).add(title: "Original")
        let failing = TrackerRepository(context: context, save: { _ in throw Failure.save })
        #expect(throws: Failure.self) { try failing.update(id: id, title: "Unsaved") }
        #expect(try context.fetch(FetchDescriptor<TrackerRecord>()).first?.title == "Original")
        #expect(!context.hasChanges)
    }

    @Test("Deletion affects only the selected identity")
    func selectedDeletion() throws {
        let container = try TrackerPersistence.makeContainer(inMemory: true)
        let repository = TrackerRepository(context: container.mainContext)
        let removed = try repository.add(title: "Same title")
        let retained = try repository.add(title: "Same title")
        try repository.delete(ids: [removed])
        #expect(try container.mainContext.fetch(FetchDescriptor<TrackerRecord>()).map(\.id) == [retained])
    }

    @Test("Preview containers do not share records")
    func previewIsolation() throws {
        let first = try TrackerPersistence.makeContainer(inMemory: true)
        let second = try TrackerPersistence.makeContainer(inMemory: true)
        _ = try TrackerRepository(context: first.mainContext).add(title: "Only in first")
        #expect(try first.mainContext.fetchCount(FetchDescriptor<TrackerRecord>()) == 1)
        #expect(try second.mainContext.fetchCount(FetchDescriptor<TrackerRecord>()) == 0)
    }
}
