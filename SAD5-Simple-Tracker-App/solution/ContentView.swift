import SwiftUI

struct ContentView: View {
    let store: TrackerStore
    @State private var draftTitle = ""
    @FocusState private var draftIsFocused: Bool
    @State private var editingItem: TrackerItem?

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
                        HStack(alignment: .top) {
                            Button {
                                store.toggle(id: item.id)
                            } label: {
                                Image(systemName: item.completed ? "checkmark.circle.fill" : "circle")
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Mark \(item.title) \(item.completed ? "incomplete" : "complete")")

                            Button {
                                editingItem = item
                            } label: {
                                Text(item.title)
                                    .strikethrough(item.completed)
                                    .frame(maxWidth: .infinity, alignment: .leading)
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Edit \(item.title)")
                        }
                    }
                    .onDelete(perform: store.delete)
                }
                .listStyle(.plain)
                .overlay {
                    if store.items.isEmpty { ContentUnavailableView("No items", systemImage: "checklist") }
                }
            }
            .padding()
            .navigationTitle("Tracker")
            .sheet(item: $editingItem) { item in
                TrackerEditor(item: item) { title in
                    store.update(id: item.id, title: title)
                }
            }
        }
    }
}

private struct TrackerEditor: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title: String
    let save: (String) -> Bool
    @State private var itemUnavailable = false

    init(item: TrackerItem, save: @escaping (String) -> Bool) {
        _title = State(initialValue: item.title)
        self.save = save
    }

    var body: some View {
        NavigationStack {
            Form {
                TextField("Item title", text: $title)
            }
            .navigationTitle("Edit item")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Save") {
                        if save(title) { dismiss() }
                        else { itemUnavailable = true }
                    }
                    .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .alert("Item no longer available", isPresented: $itemUnavailable) {
                Button("Close") { dismiss() }
            }
        }
    }
}

#Preview {
    ContentView(store: TrackerStore())
}
