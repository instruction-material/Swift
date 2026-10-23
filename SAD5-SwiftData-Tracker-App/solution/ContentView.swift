import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \TrackerRecord.createdAt) private var items: [TrackerRecord]
    @State private var draftTitle = ""
    @FocusState private var draftIsFocused: Bool
    @State private var editingItem: TrackerRecord?
    @State private var saveError = ""
    @State private var showError = false

    private var repository: TrackerRepository { TrackerRepository(context: context) }

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                HStack {
                    TextField("New tracker item", text: $draftTitle)
                        .textFieldStyle(.roundedBorder)
                        .focused($draftIsFocused)
                    Button("Add") {
                        perform {
                            try repository.add(title: draftTitle)
                            draftTitle = ""
                            draftIsFocused = false
                        }
                    }
                    .buttonStyle(.borderedProminent)
                    .disabled(draftTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
                List {
                    ForEach(items) { item in
                        HStack(alignment: .top) {
                            Button {
                                perform { try repository.toggle(id: item.id) }
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
                    .onDelete { offsets in
                        let ids = Set(offsets.compactMap { items.indices.contains($0) ? items[$0].id : nil })
                        perform { try repository.delete(ids: ids) }
                    }
                }
                .listStyle(.plain)
                .overlay {
                    if let failure = _items.fetchError {
                        ContentUnavailableView {
                            Label("Items unavailable", systemImage: "externaldrive.badge.exclamationmark")
                        } description: {
                            Text(failure.localizedDescription)
                        }
                    } else if items.isEmpty {
                        ContentUnavailableView("No items", systemImage: "checklist")
                    }
                }
            }
            .padding()
            .navigationTitle("Tracker")
            .sheet(item: $editingItem) { item in
                PersistentTrackerEditor(item: item) { title in
                    try repository.update(id: item.id, title: title)
                }
            }
            .alert("Changes not saved", isPresented: $showError) {
                Button("OK") {}
            } message: {
                Text(saveError)
            }
        }
    }

    private func perform(_ operation: () throws -> Void) {
        do { try operation() }
        catch {
            saveError = error.localizedDescription
            showError = true
        }
    }
}

private struct PersistentTrackerEditor: View {
    @Environment(\.dismiss) private var dismiss
    @State private var title: String
    @State private var saveError = ""
    @State private var showError = false
    let save: (String) throws -> Void

    init(item: TrackerRecord, save: @escaping (String) throws -> Void) {
        _title = State(initialValue: item.title)
        self.save = save
    }

    var body: some View {
        NavigationStack {
            Form { TextField("Item title", text: $title) }
                .navigationTitle("Edit item")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Cancel") { dismiss() }
                    }
                    ToolbarItem(placement: .confirmationAction) {
                        Button("Save") {
                            do {
                                try save(title)
                                dismiss()
                            } catch {
                                saveError = error.localizedDescription
                                showError = true
                            }
                        }
                        .disabled(title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                    }
                }
                .alert("Changes not saved", isPresented: $showError) {
                    Button("OK") {}
                } message: { Text(saveError) }
        }
    }
}
