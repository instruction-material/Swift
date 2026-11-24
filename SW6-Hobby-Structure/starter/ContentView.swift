import SwiftUI

struct Hobby: Identifiable {
    let id: String
    let name: String
    let supply: String
}

enum SampleData {
    static let hobbies = [
        Hobby(id: "sketch", name: "Sketching", supply: "Pencil"),
        Hobby(id: "hike", name: "Hiking", supply: "Water bottle")
    ]
}

struct HobbyCard: View {
    let hobby: Hobby

    var body: some View {
        VStack(alignment: .leading) {
            Text(hobby.name).font(.headline)
            Text("Bring: \(hobby.supply)")
        }
    }
}

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
