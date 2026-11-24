import SwiftUI

struct ContentView: View {
    @State private var isFavorite = false
    @State private var savedNote = ""

    var body: some View {
        Form {
            Section("Trail stop") {
                Text(isFavorite ? "Favorites: 1" : "Favorites: 0")
                Text(savedNote.isEmpty ? "No saved note" : savedNote)
            }
            FavoriteEditor(savedNote: $savedNote)
        }
    }
}
