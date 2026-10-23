import SwiftData
import SwiftUI

struct ContentView: View {
    @Environment(\.modelContext) private var context
    @Query(sort: \TrackerRecord.createdAt) private var items: [TrackerRecord]
    @State private var draftTitle = ""
    @FocusState private var draftIsFocused: Bool
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
                        HStack {
                            Button {
                                perform { try repository.toggle(id: item.id) }
                            } label: {
                                Image(systemName: item.completed ? "checkmark.circle.fill" : "circle")
                            }
                            .buttonStyle(.plain)
                            .accessibilityLabel("Mark \(item.title) \(item.completed ? "incomplete" : "complete")")
                            Text(item.title).strikethrough(item.completed)
                            // Present a local title draft and save by ID.
                        }
                    }
                    // Map displayed offsets to IDs, then call repository.delete(ids:).
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
