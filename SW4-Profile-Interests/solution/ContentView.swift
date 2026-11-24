import SwiftUI

struct ContentView: View {
    @State private var newMember = false
    @State private var completedLessons = 3
    @State private var query = ""

    private var profile: Profile { newMember ? .newMember : .sample }

    var body: some View {
        List {
            Section("Profile") {
                Toggle("Show new member", isOn: $newMember)
                Text(profile.name)
                Text(profile.tagline ?? "No tagline yet")
            }
            Section("Session") {
                Text("Completed lessons: \(completedLessons)")
                Button("Complete a lesson") { completedLessons += 1 }
            }
            Section("Interests") {
                TextField("Search interests", text: $query)
                let matches = profile.matchingInterests(query)
                if profile.interests.isEmpty {
                    Text("No interests yet")
                } else if matches.isEmpty {
                    Text("No matches")
                } else {
                    ForEach(matches, id: \.self) { name in Text(name) }
                }
            }
        }
    }
}
