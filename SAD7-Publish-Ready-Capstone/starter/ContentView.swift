import SwiftUI

struct ReleaseTask: Identifiable {
	let id = UUID()
	let title: String
	let done: Bool
}

struct ContentView: View {
	private let checklist = [
		ReleaseTask(title: "Choose final scope", done: true),
		ReleaseTask(title: "Collect screenshots", done: false),
		ReleaseTask(title: "Write accessibility notes", done: false),
		ReleaseTask(title: "Prepare TestFlight build", done: false)
	]

	var body: some View {
		TabView {
			NavigationStack {
				VStack(alignment: .leading, spacing: 16) {
					Text("Capstone App")
						.font(.largeTitle.bold())
					Text("This starter is a publish-ready shell. Finish the missing tabs and polish it like an app someone could actually test.")
						.foregroundStyle(.secondary)
					List(checklist) { task in
						Label(task.title, systemImage: task.done ? "checkmark.circle.fill" : "circle")
					}
				}
				.padding()
				.navigationTitle("Home")
			}
			.tabItem {
				Label("Home", systemImage: "house")
			}

			NavigationStack {
				ContentUnavailableView(
					"Explore Screen Placeholder",
					systemImage: "sparkles",
					description: Text("TODO: Add one meaningful feature tab.")
				)
				.navigationTitle("Explore")
			}
			.tabItem {
				Label("Explore", systemImage: "sparkles")
			}

			NavigationStack {
				ContentUnavailableView(
					"Settings Placeholder",
					systemImage: "gear",
					description: Text("TODO: Add release notes, version info, or accessibility settings.")
				)
				.navigationTitle("Settings")
			}
			.tabItem {
				Label("Settings", systemImage: "gear")
			}
		}
	}
}

#Preview {
	ContentView()
}
