import SwiftUI

struct ContentView: View {
    let store: TrackerStore
    @State private var draftTitle = ""
    @FocusState private var draftIsFocused: Bool

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                HStack {
                    TextField("New tracker item", text: $draftTitle)
                        .textFieldStyle(.roundedBorder)
                        .focused($draftIsFocused)
                    Button("Add") {
                        if store.add(title: draftTitle) {
                            draftTitle = ""
                            draftIsFocused = false
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(draftTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }

                List {
                    ForEach(store.items) { item in
                        HStack {
                            Button {
                                store.toggle(id: item.id)
                            } label: {
                                Image(systemName: item.completed ? "checkmark.circle.fill" : "circle")
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Mark \(item.title) \(item.completed ? "incomplete" : "complete")")

                            Text(item.title)
                                .strikethrough(item.completed)
                        }
                    }
                    // Add deletion using the store's delete(at:) method.
                }
                .listStyle(.plain)
                .overlay {
                    if store.items.isEmpty { ContentUnavailableView("No items", systemImage: "checklist") }
                }
            }
            .padding()
            .navigationTitle("Tracker")
            // Present an editor for the selected item's ID. Keep its draft
            // separate from the store until Save; Cancel discards the draft.
        }
    }
}

#Preview {
    ContentView(store: TrackerStore())
}
