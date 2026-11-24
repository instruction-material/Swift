import SwiftUI

struct FavoriteEditor: View {
    @Binding var isFavorite: Bool
    @Binding var savedNote: String
    @State private var draft = ""

    var body: some View {
        Section("Edit stop") {
            Button(isFavorite ? "Unfavorite stop" : "Favorite stop") { isFavorite.toggle() }
            TextField("Draft note", text: $draft)
                .submitLabel(.done)
            Button("Save note") { savedNote = draft }
            Button("Reset") {
                draft = ""
                savedNote = ""
                isFavorite = false
            }
        }
    }
}
