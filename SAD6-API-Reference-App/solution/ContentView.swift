import SwiftUI

struct ReferenceEntry: Identifiable, Decodable {
	let id: Int
	let title: String
	let body: String
}

struct ContentView: View {
	@State private var entries: [ReferenceEntry] = []
	@State private var isLoading = false
	@State private var errorMessage = ""
	@State private var query = ""

	var body: some View {
		NavigationStack {
			Group {
				if isLoading {
					ProgressView("Loading reference data...")
				}
				else if !errorMessage.isEmpty {
					ContentUnavailableView(
						"Could Not Load Data",
						systemImage: "wifi.slash",
						description: Text(errorMessage)
					)
				}
				else {
					List(filteredEntries) { entry in
						NavigationLink {
							ReferenceDetailView(entry: entry)
						} label: {
							VStack(alignment: .leading, spacing: 6) {
								Text(entry.title.capitalized)
									.font(.headline)
								Text(entry.body)
									.font(.footnote)
									.foregroundStyle(.secondary)
									.lineLimit(2)
							}
						}
					}
					.listStyle(.plain)
					.searchable(text: $query, prompt: "Search reference entries")
				}
			}
			.navigationTitle("Reference")
			.toolbar {
				ToolbarItem(placement: .topBarTrailing) {
					Button("Refresh") {
						Task {
							await load()
						}
					}
				}
			}
			.task {
				if entries.isEmpty {
					await load()
				}
			}
		}
	}

	private var filteredEntries: [ReferenceEntry] {
		let trimmed = query.trimmingCharacters(in: .whitespacesAndNewlines)
		if trimmed.isEmpty {
			return Array(entries.prefix(20))
		}

		return entries.filter {
			$0.title.localizedCaseInsensitiveContains(trimmed)
				|| $0.body.localizedCaseInsensitiveContains(trimmed)
		}
	}

	private func load() async {
		isLoading = true
		errorMessage = ""

		do {
			let url = URL(string: "https://jsonplaceholder.typicode.com/posts")!
			let (data, _) = try await URLSession.shared.data(from: url)
			entries = try JSONDecoder().decode([ReferenceEntry].self, from: data)
		}
		catch {
			errorMessage = error.localizedDescription
		}

		isLoading = false
	}
}

struct ReferenceDetailView: View {
	let entry: ReferenceEntry

	var body: some View {
		ScrollView {
			VStack(alignment: .leading, spacing: 18) {
				Text(entry.title.capitalized)
					.font(.largeTitle.bold())
				Text(entry.body)
					.foregroundStyle(.secondary)
				Label("Entry #\(entry.id)", systemImage: "doc.text")
					.font(.footnote)
			}
			.padding()
			.frame(maxWidth: .infinity, alignment: .leading)
		}
		.navigationTitle("Detail")
	}
}

#Preview {
	ContentView()
}
