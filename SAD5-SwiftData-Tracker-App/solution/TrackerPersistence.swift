import Foundation
import SwiftData

@MainActor
enum TrackerPersistence {
    static func makeContainer(inMemory: Bool = false, url: URL? = nil,
                              allowsSave: Bool = true) throws -> ModelContainer {
        let schema = Schema(versionedSchema: TrackerSchemaV1.self)
        let configuration: ModelConfiguration
        if inMemory {
            configuration = ModelConfiguration("TrackerPreview", schema: schema,
                isStoredInMemoryOnly: true, allowsSave: allowsSave, cloudKitDatabase: .none)
        } else {
            let storeURL: URL
            if let url {
                storeURL = url
            } else {
                let support = try FileManager.default.url(for: .applicationSupportDirectory,
                    in: .userDomainMask, appropriateFor: nil, create: true)
                let folder = support.appendingPathComponent("CourseTracker", isDirectory: true)
                try FileManager.default.createDirectory(at: folder, withIntermediateDirectories: true)
                storeURL = folder.appendingPathComponent("tracker.store")
            }
            configuration = ModelConfiguration("Tracker", schema: schema, url: storeURL,
                allowsSave: allowsSave, cloudKitDatabase: .none)
        }
        let container = try ModelContainer(for: schema, migrationPlan: TrackerMigrationPlan.self,
                                            configurations: [configuration])
        container.mainContext.autosaveEnabled = false
        return container
    }
}

enum TrackerChangeError: LocalizedError {
    case blankTitle
    case missingItem
    case readOnlyStore

    var errorDescription: String? {
        switch self {
        case .blankTitle: "Enter an item title."
        case .missingItem: "This item is no longer available."
        case .readOnlyStore: "This store is read-only. Changes were not saved."
        }
    }
}

@MainActor
struct TrackerRepository {
    let context: ModelContext
    private let save: @MainActor (ModelContext) throws -> Void

    init(context: ModelContext,
         save: @escaping @MainActor (ModelContext) throws -> Void = { try $0.save() }) {
        self.context = context
        self.save = save
        context.autosaveEnabled = false
    }

    @discardableResult
    func add(title: String) throws -> UUID {
        let title = try validTitle(title)
        let item = TrackerRecord(title: title)
        try commit { context.insert(item) }
        return item.id
    }

    func update(id: UUID, title: String) throws {
        let title = try validTitle(title)
        let item = try requireItem(id: id)
        try commit { item.title = title }
    }

    func toggle(id: UUID) throws {
        let item = try requireItem(id: id)
        try commit { item.completed.toggle() }
    }

    func delete(ids: Set<UUID>) throws {
        let records = try context.fetch(FetchDescriptor<TrackerRecord>())
        let selected = records.filter { ids.contains($0.id) }
        guard !selected.isEmpty else { return }
        try commit {
            for item in selected { context.delete(item) }
        }
    }

    private func validTitle(_ value: String) throws -> String {
        let title = value.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !title.isEmpty else { throw TrackerChangeError.blankTitle }
        return title
    }

    private func requireItem(id: UUID) throws -> TrackerRecord {
        let request = FetchDescriptor<TrackerRecord>(predicate: #Predicate { $0.id == id })
        guard let item = try context.fetch(request).first else { throw TrackerChangeError.missingItem }
        return item
    }

    private func commit(_ mutation: () -> Void) throws {
        guard context.container.configurations.allSatisfy({ $0.allowsSave }) else {
            throw TrackerChangeError.readOnlyStore
        }
        mutation()
        do { try save(context) }
        catch {
            context.rollback()
            throw error
        }
    }
}
