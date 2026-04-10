import SwiftUI

struct TrackerItem: Identifiable, Codable {
	let id: UUID
	var title: String
	var completed: Bool
}

struct ContentView: View {
	@State private var items = [
		TrackerItem(id: UUID(), title: "Sketch for 10 minutes", completed: false),
		TrackerItem(id: UUID(), title: "Review SwiftUI notes", completed: true)
	]
	@State private var draftTitle = ""

	var body: some View {
		NavigationStack {
			VStack(spacing: 16) {
				HStack {
					TextField("New tracker item", text: $draftTitle)
						.textFieldStyle(.roundedBorder)

					Button("Add") {
						guard !draftTitle.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
							return
						}

						items.append(TrackerItem(id: UUID(), title: draftTitle, completed: false))
						draftTitle = ""
					}
					.buttonStyle(.borderedProminent)
				}

				List {
					ForEach($items) { $item in
						HStack {
							Button {
								item.completed.toggle()
							} label: {
								Image(systemName: item.completed ? "checkmark.circle.fill" : "circle")
							}
							.buttonStyle(.plain)

							Text(item.title)
								.strikethrough(item.completed)
						}
					}
				}
				.listStyle(.plain)

				Text("TODO: Add delete support and save the items between launches.")
					.font(.footnote)
					.foregroundStyle(.secondary)
			}
			.padding()
			.navigationTitle("Tracker")
		}
	}
}

#Preview {
	ContentView()
}
