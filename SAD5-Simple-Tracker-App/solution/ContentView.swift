import SwiftUI

struct TrackerItem: Identifiable, Codable {
	let id: UUID
	var title: String
	var completed: Bool
}

final class TrackerStore: ObservableObject {
	@Published var items: [TrackerItem] = []

	private let storageKey = "simple-tracker-items"

	init() {
		load()
	}

	func add(title: String) {
		let trimmed = title.trimmingCharacters(in: .whitespacesAndNewlines)
		guard !trimmed.isEmpty else {
			return
		}

		items.append(TrackerItem(id: UUID(), title: trimmed, completed: false))
		save()
	}

	func toggle(_ item: TrackerItem) {
		guard let index = items.firstIndex(where: { $0.id == item.id }) else {
			return
		}

		items[index].completed.toggle()
		save()
	}

	func delete(at offsets: IndexSet) {
		items.remove(atOffsets: offsets)
		save()
	}

	private func load() {
		guard
			let data = UserDefaults.standard.data(forKey: storageKey),
			let decoded = try? JSONDecoder().decode([TrackerItem].self, from: data)
		else {
			items = [
				TrackerItem(id: UUID(), title: "Sketch for 10 minutes", completed: false),
				TrackerItem(id: UUID(), title: "Review SwiftUI notes", completed: true)
			]
			return
		}

		items = decoded
	}

	private func save() {
		guard let encoded = try? JSONEncoder().encode(items) else {
			return
		}

		UserDefaults.standard.set(encoded, forKey: storageKey)
	}
}

struct ContentView: View {
	@EnvironmentObject private var store: TrackerStore
	@State private var draftTitle = ""

	var body: some View {
		NavigationStack {
			VStack(spacing: 16) {
				HStack {
					TextField("New tracker item", text: $draftTitle)
						.textFieldStyle(.roundedBorder)

					Button("Add") {
						store.add(title: draftTitle)
						draftTitle = ""
					}
					.buttonStyle(.borderedProminent)
				}

				List {
					ForEach(store.items) { item in
						HStack {
							Button {
								store.toggle(item)
							} label: {
								Image(systemName: item.completed ? "checkmark.circle.fill" : "circle")
									.foregroundStyle(item.completed ? .green : .secondary)
							}
							.buttonStyle(.plain)

							Text(item.title)
								.strikethrough(item.completed)

							Spacer()
						}
						.accessibilityElement(children: .combine)
						.accessibilityLabel("\(item.title), \(item.completed ? "completed" : "not completed")")
					}
					.onDelete(perform: store.delete)
				}
				.listStyle(.plain)
			}
			.padding()
			.navigationTitle("Tracker")
		}
	}
}

#Preview {
	ContentView()
		.environmentObject(TrackerStore())
}
