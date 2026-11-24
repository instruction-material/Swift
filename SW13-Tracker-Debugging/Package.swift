// swift-tools-version: 6.0
import Foundation
import PackageDescription

let root = URL(fileURLWithPath: #filePath).deletingLastPathComponent()
let hasStarter = FileManager.default.fileExists(atPath: root.appendingPathComponent("starter").path)
let role = ProcessInfo.processInfo.environment["TRACKER_ROLE"] ?? (hasStarter ? "starter" : "solution")
precondition(["starter", "solution"].contains(role), "Choose starter or solution.")

let package = Package(
    name: "TrackerDebugging",
    platforms: [.macOS(.v13), .iOS(.v17)],
    targets: [
        .target(name: "TrackerModel", path: role,
                exclude: ["ContentView.swift", "TrackerDebugApp.swift", "Tests"],
                sources: ["Tracker.swift"]),
        .testTarget(name: "TrackerModelTests", dependencies: ["TrackerModel"],
                    path: role + "/Tests")
    ]
)
