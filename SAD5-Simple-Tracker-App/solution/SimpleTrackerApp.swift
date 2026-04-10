import SwiftUI

@main
struct SimpleTrackerApp: App {
	@StateObject private var store = TrackerStore()

	var body: some Scene {
		WindowGroup {
			ContentView()
				.environmentObject(store)
		}
	}
}
