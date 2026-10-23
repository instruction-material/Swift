import SwiftUI

@main
struct SimpleTrackerApp: App {
    @State private var store = TrackerStore()

    var body: some Scene {
        WindowGroup {
            ContentView(store: store)
        }
    }
}
