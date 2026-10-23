import Foundation
import SwiftData

enum TrackerSchemaV1: VersionedSchema {
    static var versionIdentifier: Schema.Version { Schema.Version(1, 0, 0) }
    static var models: [any PersistentModel.Type] { [TrackerRecord.self] }

    @Model
    final class TrackerRecord {
        @Attribute(.unique) var id: UUID
        var title: String
        var completed: Bool
        var createdAt: Date

        init(id: UUID = UUID(), title: String, completed: Bool = false,
             createdAt: Date = Date()) {
            self.id = id
            self.title = title
            self.completed = completed
            self.createdAt = createdAt
        }
    }
}

typealias TrackerRecord = TrackerSchemaV1.TrackerRecord

enum TrackerMigrationPlan: SchemaMigrationPlan {
    static var schemas: [any VersionedSchema.Type] { [TrackerSchemaV1.self] }
    static var stages: [MigrationStage] { [] }
}
