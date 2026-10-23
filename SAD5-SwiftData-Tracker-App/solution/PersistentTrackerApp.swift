import SwiftData
import SwiftUI

@main
struct PersistentTrackerApp: App {
    var body: some Scene {
        WindowGroup {
            TrackerRootView(inMemory: false)
        }
    }
}

struct TrackerRootView: View {
    let inMemory: Bool
    let storeURL: URL?

    init(inMemory: Bool, storeURL: URL? = nil) {
        self.inMemory = inMemory
        self.storeURL = storeURL
    }
    @State private var container: ModelContainer?
    @State private var storageError: String?

    var body: some View {
        Group {
            if let container {
                ContentView()
                    .modelContainer(container)
            } else if let storageError {
                ContentUnavailableView {
                    Label("Tracker unavailable", systemImage: "externaldrive.badge.exclamationmark")
                } description: {
                    Text(storageError)
                } actions: {
                    Button("Retry", action: openStorage)
                }
            } else {
                ProgressView("Opening tracker")
            }
        }
        .task {
            if container == nil && storageError == nil { openStorage() }
        }
    }

    private func openStorage() {
        do {
            container = try TrackerPersistence.makeContainer(inMemory: inMemory, url: storeURL)
            storageError = nil
        } catch {
            storageError = error.localizedDescription
        }
    }
}

#Preview {
    TrackerRootView(inMemory: true)
}
