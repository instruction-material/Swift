import SwiftUI
import UIKit

struct Profile {
	let name: String
	let role: String
	let hometown: String
	let bio: String
	let interests: [String]
	let goals: [String]
}

struct ContentView: View {
	private let profile = Profile(
		name: "Kai Rivera",
		role: "Student Developer",
		hometown: "Baltimore, MD",
		bio: "Kai is learning SwiftUI by building small, polished apps with strong layout and navigation habits.",
		interests: ["Photography", "Running", "Design"],
		goals: ["Ship a first portfolio app", "Practice navigation", "Learn reusable views"]
	)

	@State private var note = "Remember to keep layouts readable on small screens."

	var body: some View {
		NavigationStack {
			ScrollView {
				VStack(alignment: .leading, spacing: 24) {
					ZStack(alignment: .bottomLeading) {
						LinearGradient(
							colors: [.blue, .mint],
							startPoint: .topLeading,
							endPoint: .bottomTrailing
						)
						.frame(height: 220)
						.clipShape(RoundedRectangle(cornerRadius: 28))

						VStack(alignment: .leading, spacing: 10) {
							Text("Welcome to Swift App Development")
								.font(.title.bold())
								.foregroundStyle(.white)
							Text("Start with a real profile app, not just a single text label.")
								.foregroundStyle(.white.opacity(0.85))
							TagRow(items: profile.interests)
						}
						.padding(24)
					}

					InfoSection(title: profile.name, subtitle: profile.role) {
						Text(profile.bio)
							foregroundStyle(.secondary)
						Label(profile.hometown, systemImage: "mappin.and.ellipse")
							.font(.subheadline)
					}

					InfoSection(title: "Learning Goals", subtitle: "What this app demonstrates") {
						ForEach(profile.goals, id: \.self) { goal in
							Label(goal, systemImage: "checkmark.circle.fill")
								.foregroundStyle(.blue)
						}
					}

					InfoSection(title: "Personal Note", subtitle: "Local state example") {
						TextField("Write a note", text: $note, axis: .vertical)
							.textFieldStyle(.roundedBorder)
						Text(note)
							.font(.footnote)
							.foregroundStyle(.secondary)
					}

					NavigationLink {
						ProfileDetailView(profile: profile)
					} label: {
						Label("Open Detailed Profile", systemImage: "arrow.right.circle.fill")
							.frame(maxWidth: .infinity)
					}
					.buttonStyle(.borderedProminent)
				}
				.padding(20)
			}
			.navigationTitle("Welcome")
		}
	}
}

struct InfoSection<Content: View>: View {
	let title: String
	let subtitle: String
	@ViewBuilder var content: Content

	var body: some View {
		VStack(alignment: .leading, spacing: 12) {
			Text(title)
				.font(.headline)
			Text(subtitle)
				.font(.subheadline)
				.foregroundStyle(.secondary)
			content
		}
		.padding(18)
		.frame(maxWidth: .infinity, alignment: .leading)
		.background(Color(uiColor: UIColor.secondarySystemBackground), in: RoundedRectangle(cornerRadius: 22))
	}
}

struct TagRow: View {
	let items: [String]

	var body: some View {
		HStack(spacing: 8) {
			ForEach(items, id: \.self) { item in
				Text(item)
					.font(.caption.weight(.semibold))
					.padding(.horizontal, 10)
					.padding(.vertical, 6)
					.background(.white.opacity(0.18), in: Capsule())
			}
		}
	}
}

struct ProfileDetailView: View {
	let profile: Profile

	var body: some View {
		List {
			Section("About") {
				Text(profile.bio)
				Label(profile.role, systemImage: "person.crop.square")
				Label(profile.hometown, systemImage: "house")
			}

			Section("Interests") {
				ForEach(profile.interests, id: \.self) { interest in
					Label(interest, systemImage: "star.fill")
				}
			}

			Section("Goals") {
				ForEach(profile.goals, id: \.self) { goal in
					Label(goal, systemImage: "flag.checkered")
				}
			}
		}
		.navigationTitle(profile.name)
	}
}

#Preview {
	ContentView()
}
