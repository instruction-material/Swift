import SwiftUI

struct ContentView: View {
    @State private var newMember = false
    @State private var completedLessons = 3

    private var profile: Profile { newMember ? .newMember : .sample }

    var body: some View {
        List {
            Section("Profile") {
                Toggle("Show new member", isOn: $newMember)
                Text(profile.name)
                // Show the tagline or a fallback here.
            }
            Section("Session") {
                Text("Completed lessons: \(completedLessons)")
                Button("Complete a lesson") { completedLessons += 1 }
            }
            Section("Interests") {
                // Add a search field, a sorted set of matches, and both empty states.
                ForEach(profile.interests, id: \.self) { name in Text(name) }
            }
        }
    }
}
