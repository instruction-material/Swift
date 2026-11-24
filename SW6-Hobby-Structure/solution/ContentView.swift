import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            List(SampleData.hobbies) { hobby in
                NavigationLink(hobby.name) {
                    HobbyCard(hobby: hobby)
                }
            }
            .navigationTitle("Hobbies")
        }
    }
}
