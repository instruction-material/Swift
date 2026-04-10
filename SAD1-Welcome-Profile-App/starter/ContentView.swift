import SwiftUI

struct Profile {
	let name: String
	let role: String
	let hometown: String
	let interests: [String]
}

struct ContentView: View {
	private let profile = Profile(
		name: "Kai Rivera",
		role: "Student Developer",
		hometown: "Baltimore, MD",
		interests: ["Photography", "Running", "Design"]
	)

	var body: some View {
		NavigationStack {
			ScrollView {
				VStack(alignment: .leading, spacing: 20) {
					VStack(alignment: .leading, spacing: 8) {
						Text("Welcome to Swift App Development")
							.font(.largeTitle.bold())
						Text("Build your first SwiftUI app by turning a simple profile into a real app screen.")
							.foregroundStyle(.secondary)
					}

					RoundedRectangle(cornerRadius: 24)
						.fill(Color.blue.opacity(0.15))
						.frame(height: 180)
						.overlay(alignment: .bottomLeading) {
							VStack(alignment: .leading, spacing: 8) {
								Text(profile.name)
									.font(.title.bold())
								Text(profile.role)
									.foregroundStyle(.secondary)
								Text(profile.hometown)
									.font(.subheadline)
							}
							.padding(20)
						}

					VStack(alignment: .leading, spacing: 12) {
						Text("Starter Tasks")
							.font(.headline)
						Text("1. Add a more distinctive header design.")
						Text("2. Turn the interests into reusable tag views.")
						Text("3. Improve the destination page so it feels finished.")
					}

					NavigationLink("Open Profile Detail") {
						ProfileDetailView(profile: profile)
					}
					.buttonStyle(.borderedProminent)
				}
				.padding(20)
			}
			.navigationTitle("Welcome")
		}
	}
}

struct ProfileDetailView: View {
	let profile: Profile

	var body: some View {
		List {
			Section("About") {
				Text("\(profile.name) is learning how to build apps with SwiftUI.")
				Text("Role: \(profile.role)")
				Text("Hometown: \(profile.hometown)")
			}

			Section("Interests") {
				ForEach(profile.interests, id: \.self) { interest in
					Text(interest)
				}
			}

			Section("Next Step") {
				Text("TODO: Add a favorite tools section and a more polished layout.")
			}
		}
		.navigationTitle(profile.name)
	}
}

#Preview {
	ContentView()
}
