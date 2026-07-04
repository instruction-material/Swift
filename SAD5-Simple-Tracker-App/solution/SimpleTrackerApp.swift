/**************************
*   CODING STANDARD   *
**************************/

// Use named constants, descriptive names, and purpose comments before nontrivial scopes

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
