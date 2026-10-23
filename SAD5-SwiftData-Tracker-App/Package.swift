// swift-tools-version: 6.0
import Foundation
import PackageDescription

let root = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
let role = FileManager.default.fileExists(atPath: root.appendingPathComponent("solution").path)
    ? "solution" : "starter"

let testExclusions = ["PersistenceContracts.swift", "test_single_role_exports.py"].filter {
    FileManager.default.fileExists(atPath: root.appendingPathComponent("tests").appendingPathComponent($0).path)
}

let package = Package(
    name: "SwiftDataTracker",
    platforms: [.macOS(.v14), .iOS(.v17)],
    targets: [
        .target(name: "TrackerPersistenceCore", path: role,
                exclude: ["ContentView.swift", "PersistentTrackerApp.swift"],
                sources: ["TrackerRecord.swift", "TrackerPersistence.swift"]),
        .testTarget(name: "TrackerPersistenceTests", dependencies: ["TrackerPersistenceCore"],
                    path: "tests", exclude: testExclusions,
                    sources: ["PersistenceTests.swift"])
    ]
)
