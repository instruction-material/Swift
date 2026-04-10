import SwiftUI
import UIKit

struct ReleaseTask: Identifiable {
	let id = UUID()
	let title: String
	var done: Bool
}

struct ContentView: View {
	@State private var checklist = [
		ReleaseTask(title: "Choose final scope", done: true),
		ReleaseTask(title: "Collect screenshots", done: true),
		ReleaseTask(title: "Write accessibility notes", done: true),
		ReleaseTask(title: "Prepare TestFlight build", done: false)
	]

	private let highlights = [
		"Three coherent tabs",
		"Readable typography and spacing",
		"Accessibility labels on key actions",
		"Release checklist built into the app shell"
	]

	var body: some View {
		TabView {
			NavigationStack {
				ScrollView {
					VStack(alignment: .leading, spacing: 20) {
						VStack(alignment: .leading, spacing: 8) {
							Text("Capstone App")
								.font(.largeTitle.bold())
							Text("A small but ship-minded shell that keeps design, polish, and release tasks visible.")
								.foregroundStyle(.secondary)
						}

						VStack(alignment: .leading, spacing: 10) {
							ForEach(highlights, id: \.self) { highlight in
								Label(highlight, systemImage: "checkmark.seal.fill")
									.foregroundStyle(.blue)
							}
						}
						.padding()
						.background(Color(uiColor: UIColor.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 22))

						List {
							ForEach($checklist) { $task in
								Toggle(task.title, isOn: $task.done)
							}
						}
						.frame(height: 230)
						.listStyle(.plain)
					}
					.padding()
				}
				.navigationTitle("Home")
			}
			.tabItem {
				Label("Home", systemImage: "house")
			}

			NavigationStack {
				List {
					Section("Features") {
						Label("Dashboard summary", systemImage: "rectangle.grid.2x2")
						Label("Project collection", systemImage: "square.stack.3d.up")
						Label("Store readiness notes", systemImage: "doc.badge.gearshape")
					}

					Section("Testing Focus") {
						Text("Verify navigation, dynamic type, button labels, and launch state.")
					}
				}
				.navigationTitle("Explore")
			}
			.tabItem {
				Label("Explore", systemImage: "sparkles")
			}

			NavigationStack {
				List {
					Section("Metadata") {
						LabeledContent("Version", value: "1.0")
						LabeledContent("Build", value: "12")
						LabeledContent("Testing", value: "Internal TestFlight")
					}

					Section("Accessibility") {
						Label("Primary actions use clear labels", systemImage: "figure.wave")
						Label("Contrast checked for large text", systemImage: "textformat.size")
					}
				}
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
