import SwiftUI
import UIKit

struct HobbyActivity: Identifiable, Hashable {
	let id = UUID()
	let title: String
	let day: String
	let icon: String
	let summary: String
}

struct ContentView: View {
	private let activities = [
		HobbyActivity(title: "Photo Walk", day: "Tuesday", icon: "camera", summary: "Scout a neighborhood and collect strong compositions."),
		HobbyActivity(title: "Sketch Session", day: "Thursday", icon: "pencil", summary: "Turn references into quick concept sketches."),
		HobbyActivity(title: "Community Meetup", day: "Saturday", icon: "person.3", summary: "Share work, feedback, and next-week ideas.")
	]

	@State private var favorites = Set<UUID>()

	var body: some View {
		TabView {
			NavigationStack {
				VStack(spacing: 18) {
					HeroCard(activity: activities[0])

					List(activities) { activity in
						NavigationLink {
							ActivityDetailView(
								activity: activity,
								isFavorite: favorites.contains(activity.id)
							) {
								toggleFavorite(activity)
							}
						} label: {
							ActivityRow(activity: activity, isFavorite: favorites.contains(activity.id))
						}
					}
					.listStyle(.plain)
				}
				.padding(.horizontal)
				.navigationTitle("Home")
			}
			.tabItem {
				Label("Home", systemImage: "house")
			}

			NavigationStack {
				List(activities) { activity in
					VStack(alignment: .leading, spacing: 4) {
						Text(activity.title)
							.font(.headline)
						Text(activity.day)
							.font(.subheadline)
							.foregroundStyle(.secondary)
						Text(activity.summary)
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
				if favoriteActivities.isEmpty {
					ContentUnavailableView(
						"No Favorites Yet",
						systemImage: "heart",
						description: Text("Tap the heart on an activity to save it here.")
					)
				}
				else {
					List(favoriteActivities) { activity in
						ActivityRow(activity: activity, isFavorite: true)
					}
				}
			}
			.tabItem {
				Label("Favorites", systemImage: "heart")
			}
		}
	}

	private var favoriteActivities: [HobbyActivity] {
		activities.filter { favorites.contains($0.id) }
	}

	private func toggleFavorite(_ activity: HobbyActivity) {
		if favorites.contains(activity.id) {
			favorites.remove(activity.id)
		}
		else {
			favorites.insert(activity.id)
		}
	}
}

struct HeroCard: View {
	let activity: HobbyActivity

	var body: some View {
		VStack(alignment: .leading, spacing: 10) {
			Label("Next Up", systemImage: "sparkles")
				.font(.caption.weight(.semibold))
				.foregroundStyle(.secondary)
			Text(activity.title)
				.font(.title2.bold())
			Text(activity.summary)
				.foregroundStyle(.secondary)
			Text(activity.day)
				.font(.footnote.weight(.semibold))
				.padding(.horizontal, 10)
				.padding(.vertical, 6)
				.background(Color.blue.opacity(0.12), in: Capsule())
		}
		.padding(20)
		.frame(maxWidth: .infinity, alignment: .leading)
		.background(Color(uiColor: UIColor.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 24))
	}
}

struct ActivityRow: View {
	let activity: HobbyActivity
	let isFavorite: Bool

	var body: some View {
		HStack(spacing: 14) {
			Image(systemName: activity.icon)
				.frame(width: 38, height: 38)
				.background(Color.blue.opacity(0.14), in: RoundedRectangle(cornerRadius: 12))

			VStack(alignment: .leading, spacing: 4) {
				Text(activity.title)
				Text(activity.day)
					.font(.footnote)
					.foregroundStyle(.secondary)
			}

			Spacer()

			if isFavorite {
				Image(systemName: "heart.fill")
					.foregroundStyle(.pink)
			}
		}
	}
}

struct ActivityDetailView: View {
	let activity: HobbyActivity
	let isFavorite: Bool
	let onToggleFavorite: () -> Void

	var body: some View {
		VStack(alignment: .leading, spacing: 20) {
			Image(systemName: activity.icon)
				.font(.system(size: 54))
				.frame(maxWidth: .infinity)
				foregroundStyle(.blue)

			Text(activity.title)
				.font(.largeTitle.bold())
			Text(activity.summary)
				.foregroundStyle(.secondary)
			Text("Scheduled for \(activity.day)")
				.font(.headline)

			Button {
				onToggleFavorite()
			} label: {
				Label(isFavorite ? "Remove Favorite" : "Save Favorite", systemImage: isFavorite ? "heart.slash" : "heart.fill")
					.frame(maxWidth: .infinity)
			}
			.buttonStyle(.borderedProminent)

			Spacer()
		}
		.padding()
		.navigationTitle(activity.title)
	}
}

#Preview {
	ContentView()
}
