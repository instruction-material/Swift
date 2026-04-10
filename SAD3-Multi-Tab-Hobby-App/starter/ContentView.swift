import SwiftUI

struct HobbyActivity: Identifiable {
	let id = UUID()
	let title: String
	let day: String
	let icon: String
}

struct ContentView: View {
	private let activities = [
		HobbyActivity(title: "Photo Walk", day: "Tuesday", icon: "camera"),
		HobbyActivity(title: "Sketch Session", day: "Thursday", icon: "pencil"),
		HobbyActivity(title: "Community Meetup", day: "Saturday", icon: "person.3")
	]

	var body: some View {
		TabView {
			NavigationStack {
				List(activities) { activity in
					Label(activity.title, systemImage: activity.icon)
				}
				.navigationTitle("Home")
			}
			.tabItem {
				Label("Home", systemImage: "house")
			}

			NavigationStack {
				List(activities) { activity in
					VStack(alignment: .leading) {
						Text(activity.title)
						Text(activity.day)
							.font(.footnote)
							.foregroundStyle(.secondary)
					}
				}
				.navigationTitle("Schedule")
			}
			.tabItem {
				Label("Schedule", systemImage: "calendar")
			}

			NavigationStack {
				ContentUnavailableView(
					"Favorites Coming Soon",
					systemImage: "heart",
					description: Text("TODO: Connect this tab to shared state.")
				)
				.navigationTitle("Favorites")
			}
			.tabItem {
				Label("Favorites", systemImage: "heart")
			}
		}
	}
}

#Preview {
	ContentView()
}
